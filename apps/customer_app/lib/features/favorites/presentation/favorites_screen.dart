import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/presentation/vehicle_details_screen.dart';
import '../../vehicles/presentation/widgets/vehicle_health_mini_badges.dart';
import '../data/favorite_store.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: FavoriteStore.favoriteVehicleIds,
        builder: (context, favoriteIds, _) {
          final vehicles = AppServices.vehicleRepository
              .getAll()
              .where((vehicle) => favoriteIds.contains(vehicle.id))
              .toList();

          if (vehicles.isEmpty) {
            return const _EmptyFavorites();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];

              return _FavoriteVehicleCard(
                vehicle: vehicle,
                onFavoriteTap: () {
                  FavoriteStore.toggle(vehicle.id);
                },
                onTap: () {
                  _openVehicleDetails(context, vehicle);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openVehicleDetails(BuildContext context, Vehicle vehicle) {
    if (vehicle.id == FavoriteStore.toyotaRav4Id) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const VehicleDetailsScreen()),
      );
      return;
    }

    if (vehicle.id == FavoriteStore.bmw320iId) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const VehicleDetailsScreen(isBmw: true),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vehicle.displayName} details will be connected next.'),
      ),
    );
  }
}

class _FavoriteVehicleCard extends StatelessWidget {
  const _FavoriteVehicleCard({
    required this.vehicle,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final Vehicle vehicle;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: vehicle.images.isEmpty
                      ? const _VehicleImageFallback()
                      : Image.asset(
                          vehicle.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return const _VehicleImageFallback();
                          },
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: onFavoriteTap,
                      tooltip: 'Remove from favorites',
                      icon: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _vehicleDetails(vehicle),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _formatPrice(vehicle.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  VehicleHealthMiniBadges(vehicle: vehicle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleImageFallback extends StatelessWidget {
  const _VehicleImageFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.border,
      child: Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 54,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 72,
              color: AppColors.primary,
            ),
            SizedBox(height: 20),
            Text(
              'No favorites yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Save vehicles you like and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

String _vehicleDetails(Vehicle vehicle) {
  final parts = <String>[vehicle.year.toString()];

  if (vehicle.odometerKm > 0) {
    parts.add('${_formatNumber(vehicle.odometerKm)} km');
  }

  parts.add(vehicle.conditionLabel);

  return parts.join(' • ');
}

String _formatPrice(int value) {
  return '\$${_formatNumber(value)}';
}

String _formatNumber(int value) {
  return value.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
}
