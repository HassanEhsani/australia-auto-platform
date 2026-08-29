import '../../notifications/application/notification_matching_service.dart';
import '../../notifications/domain/notification_candidate.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle.dart';

final class VehiclePublishResult {
  const VehiclePublishResult({
    required this.vehicle,
    required this.notificationCandidates,
  });

  final Vehicle vehicle;
  final List<NotificationCandidate> notificationCandidates;
}

final class VehiclePublishService {
  const VehiclePublishService(
    this._vehicleRepository,
    this._notificationMatchingService,
  );

  final VehicleRepository _vehicleRepository;
  final NotificationMatchingService _notificationMatchingService;

  VehiclePublishResult publish(Vehicle vehicle) {
    _vehicleRepository.add(vehicle);

    final candidates = _notificationMatchingService.createCandidatesForVehicle(
      vehicle,
    );

    return VehiclePublishResult(
      vehicle: vehicle,
      notificationCandidates: candidates,
    );
  }
}
