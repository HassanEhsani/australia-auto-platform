import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../favorites/data/favorite_store.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../vehicles/presentation/vehicle_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const _BottomNavigation(),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _Header(),
                  const SizedBox(height: 24),
                  const _SearchSection(),
                  const SizedBox(height: 30),
                  const _SectionHeader(
                    title: 'Featured Vehicle',
                    action: 'See All',
                  ),
                  const SizedBox(height: 14),
                  const _FeaturedVehicle(),
                  const SizedBox(height: 30),
                  const _SectionHeader(title: 'Browse by Category'),
                  const SizedBox(height: 14),
                  const _Categories(),
                  const SizedBox(height: 30),
                  const _SectionHeader(
                    title: 'Popular Vehicles',
                    action: 'See All',
                  ),
                  const SizedBox(height: 14),
                  const _PopularVehicles(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFFFFE6D8),
          child: Icon(Icons.person, color: AppColors.accent, size: 30),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Hassan',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Welcome back',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FavoritesScreen()),
            );
          },
          icon: const Icon(Icons.favorite_border_rounded),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const Positioned(
              right: 8,
              top: 7,
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.accent),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: SearchBar(
            hintText: 'Search make, model or year...',
            leading: Icon(Icons.search_rounded),
            elevation: WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 56,
          height: 56,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Icon(Icons.tune_rounded, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () {},
            child: Text(
              action!,
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _FeaturedVehicle extends StatelessWidget {
  const _FeaturedVehicle();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E9ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/offers/featured_car.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Featured Vehicle',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(Icons.star_rounded, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text('4.8', style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                  'Available now at King Auto',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _VehicleStat(icon: Icons.speed_rounded, label: 'Automatic'),
                    _VehicleStat(
                      icon: Icons.local_gas_station_outlined,
                      label: 'Petrol',
                    ),
                    _VehicleStat(
                      icon: Icons.event_seat_outlined,
                      label: '5 Seats',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleStat extends StatelessWidget {
  const _VehicleStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 24),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _CategoryCard(
            icon: Icons.directions_car_rounded,
            label: 'Used Cars',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _CategoryCard(
            icon: Icons.car_crash_outlined,
            label: 'Damaged',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _CategoryCard(
            icon: Icons.build_circle_outlined,
            label: 'Salvage',
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E9ED)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.accent, size: 30),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularVehicles extends StatelessWidget {
  const _PopularVehicles();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 275,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: FavoriteStore.toyotaRav4,
            builder: (context, isFavorite, _) {
              return _VehicleCard(
                image: 'assets/images/vehicles/toyota_rav4.jpg',
                name: 'Toyota RAV4',
                details: '2021 • 48,000 km',
                price: '\$24,900',
                heroTag: 'toyota-rav4',
                isFavorite: isFavorite,
                onFavoriteTap: FavoriteStore.toggleToyotaRav4,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VehicleDetailsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 14),
          ValueListenableBuilder<bool>(
            valueListenable: FavoriteStore.bmw320i,
            builder: (context, isFavorite, _) {
              return _VehicleCard(
                image: 'assets/images/vehicles/damaged_bmw.jpg',
                name: 'BMW 320i',
                details: '2019 • Damaged',
                price: '\$22,500',
                heroTag: 'bmw-320i',
                isFavorite: isFavorite,
                onFavoriteTap: FavoriteStore.toggleBmw320i,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VehicleDetailsScreen(isBmw: true),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.image,
    required this.name,
    required this.details,
    required this.price,
    this.onTap,
    this.heroTag,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final String image;
  final String name;
  final String details;
  final String price;
  final VoidCallback? onTap;
  final String? heroTag;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 210,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8E9ED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 145,
                  width: double.infinity,
                  child: Image.asset(image, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onFavoriteTap,
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
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
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_car_outlined),
          label: 'Vehicles',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Reservations',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}
