import '../../vehicles/domain/vehicle_search_filter.dart';

class SavedSearch {
  const SavedSearch({
    required this.id,
    required this.name,
    required this.filter,
    required this.notificationsEnabled,
    required this.createdAt,
  });

  final String id;
  final String name;
  final VehicleSearchFilter filter;
  final bool notificationsEnabled;
  final DateTime createdAt;

  SavedSearch copyWith({
    String? id,
    String? name,
    VehicleSearchFilter? filter,
    bool? notificationsEnabled,
    DateTime? createdAt,
  }) {
    return SavedSearch(
      id: id ?? this.id,
      name: name ?? this.name,
      filter: filter ?? this.filter,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
