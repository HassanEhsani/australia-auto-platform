import 'package:flutter/material.dart';

import '../../../app/app_services.dart';
import '../../../app/theme/app_theme.dart';
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
                      const SizedBox(height: 18),
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
                    ],
                  ),
                );
              },
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
