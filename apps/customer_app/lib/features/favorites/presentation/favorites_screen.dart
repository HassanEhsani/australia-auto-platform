import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../vehicles/presentation/vehicle_details_screen.dart';
import '../data/favorite_store.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: FavoriteStore.toyotaRav4,
        builder: (context, isToyotaFavorite, _) {
          return ValueListenableBuilder<bool>(
            valueListenable: FavoriteStore.bmw320i,
            builder: (context, isBmwFavorite, _) {
              if (!isToyotaFavorite && !isBmwFavorite) {
                return const _EmptyFavorites();
              }

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (isToyotaFavorite) ...[
                    _FavoriteVehicleCard(
                      image: 'assets/images/vehicles/toyota_rav4.jpg',
                      heroTag: 'toyota-rav4',
                      name: 'Toyota RAV4',
                      details: '2021 • 48,000 km • Used',
                      price: '\$24,900',
                      onFavoriteTap: FavoriteStore.toggleToyotaRav4,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const VehicleDetailsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                  if (isToyotaFavorite && isBmwFavorite)
                    const SizedBox(height: 18),
                  if (isBmwFavorite) ...[
                    _FavoriteVehicleCard(
                      image: 'assets/images/vehicles/damaged_bmw.jpg',
                      heroTag: 'bmw-320i',
                      name: 'BMW 320i',
                      details: '2019 • Damaged',
                      price: '\$22,500',
                      onFavoriteTap: FavoriteStore.toggleBmw320i,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                const VehicleDetailsScreen(isBmw: true),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteVehicleCard extends StatelessWidget {
  const _FavoriteVehicleCard({
    required this.image,
    required this.heroTag,
    required this.name,
    required this.details,
    required this.price,
    required this.onFavoriteTap,
    required this.onTap,
  });

  final String image;
  final String heroTag;
  final String name;
  final String details;
  final String price;
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
                Hero(
                  tag: heroTag,
                  child: Image.asset(
                    image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
