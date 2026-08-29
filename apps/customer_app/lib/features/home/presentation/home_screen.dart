import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../favorites/data/favorite_store.dart';
import '../../favorites/presentation/favorites_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../vehicles/presentation/vehicle_details_screen.dart';
import '../../vehicles/presentation/vehicle_list_screen.dart';
import '../../vehicles/presentation/widgets/vehicle_health_mini_badges.dart';
import '../../vehicles/presentation/vehicle_search_screen.dart';
import '../../vehicles/application/vehicle_search_service.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/domain/vehicle_search_filter.dart';

final ValueNotifier<String> _vehicleSearchQuery = ValueNotifier<String>('');

final ValueNotifier<String?> _vehicleCategoryFilter = ValueNotifier<String?>(
  null,
);

final LocalVehicleRepository _vehicleRepository = LocalVehicleRepository();

final VehicleSearchService _vehicleSearchService = VehicleSearchService(
  _vehicleRepository,
);

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

                  ValueListenableBuilder<String>(
                    valueListenable: _vehicleSearchQuery,
                    builder: (context, query, _) {
                      if (query.isNotEmpty) {
                        return const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: 'Search Results'),
                            SizedBox(height: 14),
                            _PopularVehicles(),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Featured Vehicle',
                            action: 'See All',
                            onActionTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const VehicleListScreen(
                                    title: 'All Vehicles',
                                    filter: VehicleSearchFilter(),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 14),
                          _FeaturedVehicle(),
                          SizedBox(height: 30),
                          _SectionHeader(
                            title: 'New Arrivals',
                            action: 'See All',
                            onActionTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const VehicleListScreen(
                                    title: 'New Arrivals',
                                    filter: VehicleSearchFilter(
                                      condition: VehicleCondition.newVehicle,
                                      newArrivalsOnly: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 14),
                          _NewArrivals(),
                          SizedBox(height: 30),
                          _SectionHeader(title: 'Browse by Category'),
                          SizedBox(height: 14),
                          _Categories(),
                          SizedBox(height: 30),
                          _SectionHeader(
                            title: 'Used Cars',
                            action: 'See All',
                            onActionTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const VehicleListScreen(
                                    title: 'Used Cars',
                                    filter: VehicleSearchFilter(
                                      condition: VehicleCondition.used,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 14),
                          _VehicleConditionPreview(
                            condition: VehicleCondition.used,
                          ),
                          SizedBox(height: 30),
                          _SectionHeader(
                            title: 'Damaged Vehicles',
                            action: 'See All',
                            onActionTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const VehicleListScreen(
                                    title: 'Damaged Vehicles',
                                    filter: VehicleSearchFilter(
                                      condition: VehicleCondition.damaged,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 14),
                          _VehicleConditionPreview(
                            condition: VehicleCondition.damaged,
                          ),
                        ],
                      );
                    },
                  ),
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

class _SearchSection extends StatefulWidget {
  const _SearchSection();

  @override
  State<_SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<_SearchSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _vehicleSearchQuery.value = value.trim().toLowerCase();
    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    _vehicleSearchQuery.value = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            controller: _controller,
            hintText: 'Search make, model or year...',
            leading: const Icon(Icons.search_rounded),
            trailing: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
            onChanged: _onSearchChanged,
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
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
  const _SectionHeader({required this.title, this.action, this.onActionTap});

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

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
            onPressed: onActionTap,
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

class _NewArrivals extends StatelessWidget {
  const _NewArrivals();

  @override
  Widget build(BuildContext context) {
    final vehicles =
        _vehicleRepository
            .getAll()
            .where((vehicle) => vehicle.isNewArrival)
            .toList()
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return SizedBox(
      height: 235,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];

          return _NewArrivalCard(
            vehicle: vehicle,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _NewArrivalCard extends StatelessWidget {
  const _NewArrivalCard({required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 230,
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
                  height: 150,
                  width: double.infinity,
                  child: Image.asset(vehicle.images.first, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${vehicle.year} • ${vehicle.conditionLabel}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
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

  void _openCategory(
    BuildContext context, {
    required String category,
    required String title,
    required VehicleCondition condition,
  }) {
    _vehicleCategoryFilter.value = category;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VehicleListScreen(
          title: title,
          filter: VehicleSearchFilter(condition: condition),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _vehicleCategoryFilter,
      builder: (context, selectedCategory, _) {
        return Row(
          children: [
            Expanded(
              child: _CategoryCard(
                icon: Icons.directions_car_rounded,
                label: 'Used Cars',
                isSelected: selectedCategory == 'used',
                onTap: () => _openCategory(
                  context,
                  category: 'used',
                  title: 'Used Cars',
                  condition: VehicleCondition.used,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryCard(
                icon: Icons.car_crash_outlined,
                label: 'Damaged',
                isSelected: selectedCategory == 'damaged',
                onTap: () => _openCategory(
                  context,
                  category: 'damaged',
                  title: 'Damaged Vehicles',
                  condition: VehicleCondition.damaged,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CategoryCard(
                icon: Icons.build_circle_outlined,
                label: 'Salvage',
                isSelected: selectedCategory == 'salvage',
                onTap: () => _openCategory(
                  context,
                  category: 'salvage',
                  title: 'Salvage Vehicles',
                  condition: VehicleCondition.salvage,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.accent : AppColors.accent,
                size: 30,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleConditionPreview extends StatelessWidget {
  const _VehicleConditionPreview({required this.condition});

  final VehicleCondition condition;

  @override
  Widget build(BuildContext context) {
    final vehicles = _vehicleSearchService.search(
      VehicleSearchFilter(condition: condition),
    );

    if (vehicles.isEmpty) {
      return Container(
        height: 150,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'No vehicles available',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return SizedBox(
      height: 340,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: vehicles.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];

          return ValueListenableBuilder<Set<String>>(
            valueListenable: FavoriteStore.favoriteVehicleIds,
            builder: (context, favoriteIds, _) {
              return _VehicleCard(
                vehicle: vehicle,
                image: vehicle.images.first,
                name: vehicle.displayName,
                details:
                    '${vehicle.year} • ${vehicle.odometerKm} km • ${vehicle.conditionLabel}',
                price: '\$${vehicle.price}',
                heroTag: 'vehicle-${vehicle.id}',
                isFavorite: favoriteIds.contains(vehicle.id),
                onFavoriteTap: () => FavoriteStore.toggle(vehicle.id),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => VehicleDetailsScreen(vehicle: vehicle),
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

class _PopularVehicles extends StatelessWidget {
  const _PopularVehicles();

  VehicleCondition? _conditionFromCategory(String? category) {
    switch (category) {
      case 'used':
        return VehicleCondition.used;
      case 'damaged':
        return VehicleCondition.damaged;
      case 'salvage':
        return VehicleCondition.salvage;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _vehicleSearchQuery,
      builder: (context, query, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _vehicleCategoryFilter,
          builder: (context, category, _) {
            final results = _vehicleSearchService.search(
              VehicleSearchFilter(
                query: query,
                condition: _conditionFromCategory(category),
              ),
            );

            final displayVehicles = query.trim().isEmpty && category == null
                ? results.where((vehicle) {
                    return vehicle.id == 'toyota-rav4-2021' ||
                        vehicle.id == 'bmw-320i-2019';
                  }).toList()
                : results;

            if (displayVehicles.isEmpty) {
              final isSalvage = category == 'salvage';

              return Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 42,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSalvage
                          ? 'No salvage vehicles available'
                          : 'No vehicles found',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isSalvage
                          ? 'New salvage stock will appear here.'
                          : 'Try another make, model, year or category.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayVehicles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final vehicle = displayVehicles[index];

                  return ValueListenableBuilder<Set<String>>(
                    valueListenable: FavoriteStore.favoriteVehicleIds,
                    builder: (context, favoriteIds, _) {
                      return _VehicleCard(
                        vehicle: vehicle,
                        image: vehicle.images.first,
                        name: vehicle.displayName,
                        details:
                            '${vehicle.year} • ${vehicle.odometerKm} km • ${vehicle.conditionLabel}',
                        price: '\$${vehicle.price}',
                        heroTag: 'vehicle-${vehicle.id}',
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
          },
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.image,
    required this.name,
    required this.details,
    required this.price,
    this.onTap,
    this.heroTag,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final Vehicle vehicle;
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
                  const SizedBox(height: 10),
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

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        height: 68,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);

          return IconThemeData(
            size: 25,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);

          return TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const VehicleSearchScreen(),
              ),
            );
            return;
          }

          if (index == 4) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car_rounded),
            label: 'Vehicles',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Reservations',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
