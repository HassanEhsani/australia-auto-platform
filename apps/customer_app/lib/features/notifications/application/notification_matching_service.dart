import '../../saved_search/application/saved_search_service.dart';
import '../../saved_search/domain/saved_search.dart';
import '../../vehicles/domain/vehicle.dart';
import '../domain/notification_candidate.dart';

final class NotificationMatchingService {
  const NotificationMatchingService(this._savedSearchService);

  final SavedSearchService _savedSearchService;

  List<NotificationCandidate> createCandidatesForVehicle(Vehicle vehicle) {
    final candidates = <NotificationCandidate>[];

    for (final savedSearch in _savedSearchService.getAll()) {
      if (!savedSearch.notificationsEnabled) {
        continue;
      }

      if (!_savedSearchService.matchesVehicle(
        savedSearch: savedSearch,
        vehicle: vehicle,
      )) {
        continue;
      }

      candidates.add(
        _createCandidate(savedSearch: savedSearch, vehicle: vehicle),
      );
    }

    return candidates;
  }

  NotificationCandidate _createCandidate({
    required SavedSearch savedSearch,
    required Vehicle vehicle,
  }) {
    return NotificationCandidate(
      id: '${savedSearch.id}-${vehicle.id}',
      savedSearchId: savedSearch.id,
      vehicleId: vehicle.id,
      title: 'New vehicle match',
      body:
          '${vehicle.displayName} ${vehicle.year} matches '
          '"${savedSearch.name}".',
      createdAt: DateTime.now(),
    );
  }
}
