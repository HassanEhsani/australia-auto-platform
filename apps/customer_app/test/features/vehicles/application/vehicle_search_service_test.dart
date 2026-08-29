import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/vehicles/application/vehicle_search_service.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:customer_app/features/vehicles/domain/vehicle.dart';
import 'package:customer_app/features/vehicles/domain/vehicle_search_filter.dart';
import '../../../support/vehicle_test_fixtures.dart';

void main() {
  final repository = LocalVehicleRepository(
    initialVehicles: buildVehicleTestVehicles(),
  );
  final service = VehicleSearchService(repository);

  group('VehicleSearchService', () {
    test('search by BMW returns BMW 320i only', () {
      final results = service.search(const VehicleSearchFilter(query: 'BMW'));

      expect(results, hasLength(1));
      expect(results.first.id, 'bmw-320i-2019');
    });

    test('search by year 2019 returns BMW 320i', () {
      final results = service.search(const VehicleSearchFilter(query: '2019'));

      expect(results, hasLength(1));
      expect(results.first.id, 'bmw-320i-2019');
    });

    test('damaged condition returns BMW only', () {
      final results = service.search(
        const VehicleSearchFilter(condition: VehicleCondition.damaged),
      );

      expect(results, hasLength(1));
      expect(results.first.id, 'bmw-320i-2019');
    });

    test('Toyota + used returns RAV4 only', () {
      final results = service.search(
        const VehicleSearchFilter(
          make: 'Toyota',
          condition: VehicleCondition.used,
        ),
      );

      expect(results, hasLength(1));
      expect(results.first.id, 'toyota-rav4-2021');
    });

    test('new arrivals only returns Land Cruiser and Audi', () {
      final results = service.search(
        const VehicleSearchFilter(newArrivalsOnly: true),
      );

      expect(results, hasLength(2));

      final ids = results.map((vehicle) => vehicle.id).toSet();

      expect(ids, containsAll(['toyota-land-cruiser-2025', 'audi-suv-2025']));
    });

    test('price range filters correctly', () {
      final results = service.search(
        const VehicleSearchFilter(priceMin: 20000, priceMax: 30000),
      );

      final ids = results.map((vehicle) => vehicle.id).toSet();

      expect(ids, containsAll(['toyota-rav4-2021', 'bmw-320i-2019']));

      expect(results, hasLength(2));
    });

    test('year range filters correctly', () {
      final results = service.search(
        const VehicleSearchFilter(yearFrom: 2020, yearTo: 2022),
      );

      expect(results, hasLength(1));
      expect(results.first.id, 'toyota-rav4-2021');
    });

    test('combined filters return exact match', () {
      final results = service.search(
        const VehicleSearchFilter(
          make: 'BMW',
          yearFrom: 2018,
          yearTo: 2020,
          condition: VehicleCondition.damaged,
          transmission: 'Automatic',
        ),
      );

      expect(results, hasLength(1));
      expect(results.first.id, 'bmw-320i-2019');
    });

    test('invalid combination returns empty list', () {
      final results = service.search(
        const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.used,
        ),
      );

      expect(results, isEmpty);
    });

    test('results are sorted by newest published first', () {
      final results = service.search(const VehicleSearchFilter());

      expect(results, hasLength(4));

      for (var i = 0; i < results.length - 1; i++) {
        expect(
          results[i].publishedAt.isAfter(results[i + 1].publishedAt) ||
              results[i].publishedAt == results[i + 1].publishedAt,
          isTrue,
        );
      }
    });
  });
}
