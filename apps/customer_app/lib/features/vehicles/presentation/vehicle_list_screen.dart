import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../favorites/data/favorite_store.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_search_filter.dart';
import 'vehicle_details_screen.dart';
import 'widgets/vehicle_health_mini_badges.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({
    super.key,
    required this.title,
    required this.filter,
  });

  final String title;
  final VehicleSearchFilter filter;

  @override
  Widget build(BuildContext context) {
    final vehicles = AppServices.vehicleSearchService.search(filter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: vehicles.isEmpty
          ? const _EmptyVehicleList()
          : ValueListenableBuilder<Set<String>>(
              valueListenable: FavoriteStore.favoriteVehicleIds,
              builder: (context, favoriteIds, _) {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  itemCount: vehicles.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];

                    return _VehicleListCard(
                      vehicle: vehicle,
                      isFavorite: favoriteIds.contains(vehicle.id),
                      onFavoriteTap: () => FavoriteStore.toggle(vehicle.id),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                VehicleDetailsScreen(vehicle: vehicle),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

class _VehicleListCard extends StatelessWidget {
  const _VehicleListCard({
    required this.vehicle,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final Vehicle vehicle;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: Image.asset(vehicle.images.first, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onFavoriteTap,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${vehicle.year} • ${vehicle.odometerKm} km • ${vehicle.conditionLabel}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\$${vehicle.price}',
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
      ),
    );
  }
}

class _EmptyVehicleList extends StatelessWidget {
  const _EmptyVehicleList();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14),
            Text(
              'No vehicles available',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
