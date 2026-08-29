import '../../vehicles/application/vehicle_search_service.dart';
import '../../vehicles/domain/vehicle.dart';
import '../../vehicles/domain/vehicle_search_filter.dart';
import '../data/saved_search_repository.dart';
import '../domain/saved_search.dart';

final class SavedSearchService {
  const SavedSearchService(this._repository, this._vehicleSearchService);

  final SavedSearchRepository _repository;
  final VehicleSearchService _vehicleSearchService;

  List<SavedSearch> getAll() {
    return _repository.getAll();
  }

  SavedSearch create({
    required String id,
    required String name,
    required VehicleSearchFilter filter,
    bool notificationsEnabled = true,
  }) {
    final search = SavedSearch(
      id: id,
      name: name,
      filter: filter,
      notificationsEnabled: notificationsEnabled,
      createdAt: DateTime.now(),
    );

    _repository.save(search);

    return search;
  }

  void delete(String id) {
    _repository.delete(id);
  }

  SavedSearch? setNotificationsEnabled({
    required String id,
    required bool enabled,
  }) {
    final existing = _repository.getById(id);

    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(notificationsEnabled: enabled);

    _repository.save(updated);

    return updated;
  }

  List<Vehicle> getCurrentMatches(SavedSearch search) {
    return _vehicleSearchService.search(search.filter);
  }

  bool matchesVehicle({
    required SavedSearch savedSearch,
    required Vehicle vehicle,
  }) {
    final filter = savedSearch.filter;

    if (!_matchesQuery(vehicle, filter.query)) {
      return false;
    }

    if (!_matchesText(vehicle.make, filter.make)) {
      return false;
    }

    if (!_matchesText(vehicle.model, filter.model)) {
      return false;
    }

    if (filter.yearFrom != null && vehicle.year < filter.yearFrom!) {
      return false;
    }

    if (filter.yearTo != null && vehicle.year > filter.yearTo!) {
      return false;
    }

    if (filter.condition != null && vehicle.condition != filter.condition) {
      return false;
    }

    if (filter.priceMin != null && vehicle.price < filter.priceMin!) {
      return false;
    }

    if (filter.priceMax != null && vehicle.price > filter.priceMax!) {
      return false;
    }

    if (!_matchesText(vehicle.bodyType, filter.bodyType)) {
      return false;
    }

    if (!_matchesText(vehicle.transmission, filter.transmission)) {
      return false;
    }

    if (!_matchesText(vehicle.fuelType, filter.fuelType)) {
      return false;
    }

    if (filter.newArrivalsOnly && !vehicle.isNewArrival) {
      return false;
    }

    return true;
  }

  bool _matchesQuery(Vehicle vehicle, String? query) {
    final normalizedQuery = query?.trim().toLowerCase();

    if (normalizedQuery == null || normalizedQuery.isEmpty) {
      return true;
    }

    final searchableText = [
      vehicle.make,
      vehicle.model,
      vehicle.year.toString(),
      vehicle.conditionLabel,
      vehicle.bodyType,
      vehicle.transmission,
      vehicle.fuelType,
      vehicle.location,
      vehicle.odometerKm.toString(),
      vehicle.price.toString(),
    ].join(' ').toLowerCase();

    return searchableText.contains(normalizedQuery);
  }

  bool _matchesText(String value, String? filterValue) {
    final normalizedFilter = filterValue?.trim().toLowerCase();

    if (normalizedFilter == null || normalizedFilter.isEmpty) {
      return true;
    }

    return value.toLowerCase() == normalizedFilter;
  }
}
