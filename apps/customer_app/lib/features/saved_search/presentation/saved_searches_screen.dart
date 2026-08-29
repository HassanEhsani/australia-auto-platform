import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
import '../../favorites/data/favorite_store.dart';
import '../../vehicles/domain/vehicle.dart';
import '../domain/saved_search.dart';

class SavedSearchesScreen extends StatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  State<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<SavedSearchesScreen> {
  List<SavedSearch> get _savedSearches =>
      AppServices.savedSearchService.getAll();

  void _deleteSearch(SavedSearch search) {
    AppServices.savedSearchService.delete(search.id);

    setState(() {});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${search.name}" deleted.')));
  }

  void _toggleNotifications(SavedSearch search) {
    AppServices.savedSearchService.setNotificationsEnabled(
      id: search.id,
      enabled: !search.notificationsEnabled,
    );

    setState(() {});
  }

  void _showAllMatches(SavedSearch search, List<Vehicle> matches) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            _SavedSearchMatchesScreen(search: search, matches: matches),
      ),
    );
  }

  String _filterSummary(SavedSearch search) {
    final filter = search.filter;
    final parts = <String>[];

    if (filter.make != null) {
      parts.add(filter.make!);
    }

    if (filter.model != null) {
      parts.add(filter.model!);
    }

    if (filter.condition != null) {
      parts.add(switch (filter.condition!) {
        VehicleCondition.newVehicle => 'New',
        VehicleCondition.used => 'Used',
        VehicleCondition.damaged => 'Damaged',
        VehicleCondition.salvage => 'Salvage',
      });
    }

    if (filter.yearFrom != null || filter.yearTo != null) {
      final from = filter.yearFrom?.toString() ?? 'Any';
      final to = filter.yearTo?.toString() ?? 'Any';

      parts.add('$from–$to');
    }

    if (filter.priceMin != null || filter.priceMax != null) {
      final min = filter.priceMin?.toString() ?? 'Any';
      final max = filter.priceMax?.toString() ?? 'Any';

      parts.add('\$$min–\$$max');
    }

    final query = filter.query?.trim();

    if (query != null && query.isNotEmpty) {
      parts.add('"$query"');
    }

    if (parts.isEmpty) {
      return 'All vehicles';
    }

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final savedSearches = _savedSearches;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Saved Searches',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: savedSearches.isEmpty
          ? const _EmptySavedSearches()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: savedSearches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final search = savedSearches[index];

                final matches = AppServices.savedSearchService
                    .getCurrentMatches(search);

                final previewMatches = matches.take(3).toList();

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              search.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteSearch(search),
                            icon: const Icon(Icons.delete_outline_rounded),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        _filterSummary(search),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${matches.length} vehicle '
                            '${matches.length == 1 ? 'match' : 'matches'}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Notifications',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Switch(
                            value: search.notificationsEnabled,
                            onChanged: (_) {
                              _toggleNotifications(search);
                            },
                          ),
                        ],
                      ),

                      if (previewMatches.isNotEmpty) ...[
                        const Divider(height: 28),

                        const Text(
                          'Matching Vehicles',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...previewMatches.map(
                          (vehicle) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _SavedSearchVehicleCard(vehicle: vehicle),
                          ),
                        ),

                        if (matches.length > previewMatches.length)
                          Align(
                            alignment: Alignment.center,
                            child: TextButton.icon(
                              onPressed: () {
                                _showAllMatches(search, matches);
                              },
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text('View all ${matches.length} matches'),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _SavedSearchVehicleCard extends StatelessWidget {
  const _SavedSearchVehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            height: 110,
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

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      ValueListenableBuilder<Set<String>>(
                        valueListenable: FavoriteStore.favoriteVehicleIds,
                        builder: (context, favoriteIds, _) {
                          final isFavorite = favoriteIds.contains(vehicle.id);

                          return IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: isFavorite
                                ? 'Remove from favorites'
                                : 'Add to favorites',
                            onPressed: () {
                              FavoriteStore.toggle(vehicle.id);
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  Text(
                    '${vehicle.year} • ${vehicle.conditionLabel}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _formatPrice(vehicle.price),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedSearchMatchesScreen extends StatelessWidget {
  const _SavedSearchMatchesScreen({
    required this.search,
    required this.matches,
  });

  final SavedSearch search;
  final List<Vehicle> matches;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          search.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        itemCount: matches.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _SavedSearchVehicleCard(vehicle: matches[index]);
        },
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
          size: 38,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptySavedSearches extends StatelessWidget {
  const _EmptySavedSearches();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 14),
            Text(
              'No saved searches yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Save a vehicle search to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int value) {
  final text = value.toString();

  final formatted = text.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );

  return '\$$formatted';
}
