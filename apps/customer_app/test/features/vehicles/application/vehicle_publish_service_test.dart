import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/notifications/application/notification_matching_service.dart';
import 'package:customer_app/features/saved_search/application/saved_search_service.dart';
import 'package:customer_app/features/saved_search/data/saved_search_repository.dart';
import 'package:customer_app/features/vehicles/application/vehicle_publish_service.dart';
import 'package:customer_app/features/vehicles/application/vehicle_search_service.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:customer_app/features/vehicles/domain/vehicle.dart';
import 'package:customer_app/features/vehicles/domain/vehicle_search_filter.dart';

void main() {
  group('VehiclePublishService', () {
    test('publishing matching vehicle adds it and creates notification', () {
      final vehicleRepository = LocalVehicleRepository(initialVehicles: []);

      final savedSearchRepository = InMemorySavedSearchRepository();

      final vehicleSearchService = VehicleSearchService(vehicleRepository);

      final savedSearchService = SavedSearchService(
        savedSearchRepository,
        vehicleSearchService,
      );

      savedSearchService.create(
        id: 'saved-bmw-damaged',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
      );

      final notificationMatchingService = NotificationMatchingService(
        savedSearchService,
      );

      final publishService = VehiclePublishService(
        vehicleRepository,
        notificationMatchingService,
      );

      final vehicle = Vehicle(
        id: 'bmw-330i-2021-damaged',
        make: 'BMW',
        model: '330i',
        year: 2021,
        condition: VehicleCondition.damaged,
        price: 31900,
        odometerKm: 54000,
        bodyType: 'Sedan',
        transmission: 'Automatic',
        fuelType: 'Petrol',
        location: 'King Auto - Rocklea, QLD 4106',
        images: const ['assets/images/vehicles/damaged_bmw.jpg'],
        isNewArrival: true,
        publishedAt: DateTime(2026, 8, 27, 10, 0),
      );

      final result = publishService.publish(vehicle);

      expect(vehicleRepository.getById('bmw-330i-2021-damaged'), isNotNull);

      expect(result.vehicle.id, 'bmw-330i-2021-damaged');

      expect(result.notificationCandidates, hasLength(1));

      expect(
        result.notificationCandidates.first.savedSearchId,
        'saved-bmw-damaged',
      );

      expect(
        result.notificationCandidates.first.vehicleId,
        'bmw-330i-2021-damaged',
      );
    });

    test('publishing non matching vehicle creates no notification', () {
      final vehicleRepository = LocalVehicleRepository(initialVehicles: []);

      final savedSearchRepository = InMemorySavedSearchRepository();

      final vehicleSearchService = VehicleSearchService(vehicleRepository);

      final savedSearchService = SavedSearchService(
        savedSearchRepository,
        vehicleSearchService,
      );

      savedSearchService.create(
        id: 'saved-bmw',
        name: 'BMW Only',
        filter: const VehicleSearchFilter(make: 'BMW'),
      );

      final publishService = VehiclePublishService(
        vehicleRepository,
        NotificationMatchingService(savedSearchService),
      );

      final vehicle = Vehicle(
        id: 'toyota-corolla-2024',
        make: 'Toyota',
        model: 'Corolla',
        year: 2024,
        condition: VehicleCondition.used,
        price: 28900,
        odometerKm: 12000,
        bodyType: 'Sedan',
        transmission: 'Automatic',
        fuelType: 'Petrol',
        location: 'King Auto - Rocklea, QLD 4106',
        images: const ['assets/images/vehicles/toyota_rav4.jpg'],
        isNewArrival: true,
        publishedAt: DateTime(2026, 8, 27, 11, 0),
      );

      final result = publishService.publish(vehicle);

      expect(vehicleRepository.getById('toyota-corolla-2024'), isNotNull);

      expect(result.notificationCandidates, isEmpty);
    });
  });
}
