import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';
import '../domain/vehicle_search_filter.dart';

final class VehicleSearchService {
  const VehicleSearchService(this._repository);

  final VehicleRepository _repository;

  List<Vehicle> search(VehicleSearchFilter filter) {
    final vehicles = _repository.getAll();

    final results = vehicles.where((vehicle) {
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
    }).toList();

    results.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return results;
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
