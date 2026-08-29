import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/features/notifications/application/notification_matching_service.dart';
import 'package:customer_app/features/saved_search/application/saved_search_service.dart';
import 'package:customer_app/features/saved_search/data/saved_search_repository.dart';
import 'package:customer_app/features/vehicles/application/vehicle_search_service.dart';
import 'package:customer_app/features/vehicles/data/vehicle_repository.dart';
import 'package:customer_app/features/vehicles/domain/vehicle.dart';
import 'package:customer_app/features/vehicles/domain/vehicle_search_filter.dart';

void main() {
  late InMemorySavedSearchRepository savedSearchRepository;
  late SavedSearchService savedSearchService;
  late NotificationMatchingService notificationService;

  setUp(() {
    savedSearchRepository = InMemorySavedSearchRepository();

    savedSearchService = SavedSearchService(
      savedSearchRepository,
      VehicleSearchService(LocalVehicleRepository()),
    );

    notificationService = NotificationMatchingService(savedSearchService);
  });

  group('NotificationMatchingService', () {
    test('matching BMW damaged vehicle creates one candidate', () {
      savedSearchService.create(
        id: 'saved-bmw',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
      );

      final vehicle = LocalVehicleRepository().getById('bmw-320i-2019');

      expect(vehicle, isNotNull);

      final candidates = notificationService.createCandidatesForVehicle(
        vehicle!,
      );

      expect(candidates, hasLength(1));
      expect(candidates.first.savedSearchId, 'saved-bmw');
      expect(candidates.first.vehicleId, 'bmw-320i-2019');
      expect(candidates.first.title, 'New vehicle match');
    });

    test('disabled notifications create no candidates', () {
      savedSearchService.create(
        id: 'saved-bmw',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
        notificationsEnabled: false,
      );

      final vehicle = LocalVehicleRepository().getById('bmw-320i-2019');

      expect(vehicle, isNotNull);

      final candidates = notificationService.createCandidatesForVehicle(
        vehicle!,
      );

      expect(candidates, isEmpty);
    });

    test('non-matching Toyota vehicle creates no candidates', () {
      savedSearchService.create(
        id: 'saved-bmw',
        name: 'BMW Damaged',
        filter: const VehicleSearchFilter(
          make: 'BMW',
          condition: VehicleCondition.damaged,
        ),
      );

      final vehicle = LocalVehicleRepository().getById('toyota-rav4-2021');

      expect(vehicle, isNotNull);

      final candidates = notificationService.createCandidatesForVehicle(
        vehicle!,
      );

      expect(candidates, isEmpty);
    });

    test('one vehicle can match multiple saved searches', () {
      savedSearchService.create(
        id: 'saved-bmw',
        name: 'BMW Vehicles',
        filter: const VehicleSearchFilter(make: 'BMW'),
      );

      savedSearchService.create(
        id: 'saved-damaged',
        name: 'Damaged Vehicles',
        filter: const VehicleSearchFilter(condition: VehicleCondition.damaged),
      );

      final vehicle = LocalVehicleRepository().getById('bmw-320i-2019');

      expect(vehicle, isNotNull);

      final candidates = notificationService.createCandidatesForVehicle(
        vehicle!,
      );

      expect(candidates, hasLength(2));

      final savedSearchIds = candidates
          .map((candidate) => candidate.savedSearchId)
          .toSet();

      expect(savedSearchIds, containsAll(['saved-bmw', 'saved-damaged']));
    });
  });
}
