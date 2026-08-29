import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/saved_search/application/saved_search_service.dart';
import 'package:customer_app/features/saved_search/data/saved_search_repository.dart';
import 'package:customer_app/features/vehicles/application/vehicle_search_service.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:customer_app/features/vehicles/domain/vehicle.dart';
import 'package:customer_app/features/vehicles/domain/vehicle_search_filter.dart';

void main() {
  late InMemorySavedSearchRepository savedSearchRepository;
  late SavedSearchService service;

  setUp(() {
    savedSearchRepository = InMemorySavedSearchRepository();

    service = SavedSearchService(
      savedSearchRepository,
      VehicleSearchService(LocalVehicleRepository()),
    );
  });

  group('SavedSearchService', () {
    test('creates and stores a saved search', () {
      final savedSearch = service.create(
        id: 'saved-1',
        name: 'Damaged BMW',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
      );

      expect(savedSearch.id, 'saved-1');
      expect(service.getAll(), hasLength(1));
      expect(service.getAll().first.name, 'Damaged BMW');
    });

    test('BMW damaged vehicle matches saved search', () {
      final savedSearch = service.create(
        id: 'saved-1',
        name: 'BMW Damaged 2018-2022',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          yearFrom: 2018,
          yearTo: 2022,
          condition: VehicleCondition.damaged,
        ),
      );

      final vehicle = LocalVehicleRepository().getById('bmw-320i-2019');

      expect(vehicle, isNotNull);

      final matches = service.matchesVehicle(
        savedSearch: savedSearch,
        vehicle: vehicle!,
      );

      expect(matches, isTrue);
    });

    test('Toyota used vehicle does not match BMW damaged search', () {
      final savedSearch = service.create(
        id: 'saved-1',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
      );

      final vehicle = LocalVehicleRepository().getById('toyota-rav4-2021');

      expect(vehicle, isNotNull);

      final matches = service.matchesVehicle(
        savedSearch: savedSearch,
        vehicle: vehicle!,
      );

      expect(matches, isFalse);
    });

    test('new arrivals saved search returns two current matches', () {
      final savedSearch = service.create(
        id: 'saved-new',
        name: 'New Arrivals',
        filter: const VehicleSearchFilter(newArrivalsOnly: true),
      );

      final matches = service.getCurrentMatches(savedSearch);

      expect(matches, hasLength(2));

      final ids = matches.map((vehicle) => vehicle.id).toSet();

      expect(ids, containsAll(['toyota-land-cruiser-2025', 'audi-suv-2025']));
    });

    test('notification preference can be disabled', () {
      service.create(
        id: 'saved-1',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
      );

      final updated = service.setNotificationsEnabled(
        id: 'saved-1',
        enabled: false,
      );

      expect(updated, isNotNull);
      expect(updated!.notificationsEnabled, isFalse);
    });

    test('saved search can be deleted', () {
      service.create(
        id: 'saved-1',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(make: 'BMW'),
      );

      service.delete('saved-1');

      expect(service.getAll(), isEmpty);
    });
  });
}
