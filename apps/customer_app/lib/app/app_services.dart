import '../features/saved_search/application/saved_search_service.dart';
import '../features/saved_search/data/saved_search_repository.dart';
import '../features/vehicles/application/vehicle_search_service.dart';
import '../features/vehicles/data/vehicle_repository.dart';

abstract final class AppServices {
  static final LocalVehicleRepository vehicleRepository =
      LocalVehicleRepository();

  static final VehicleSearchService vehicleSearchService = VehicleSearchService(
    vehicleRepository,
  );

  static final InMemorySavedSearchRepository savedSearchRepository =
      InMemorySavedSearchRepository();

  static final SavedSearchService savedSearchService = SavedSearchService(
    savedSearchRepository,
    vehicleSearchService,
  );
}
