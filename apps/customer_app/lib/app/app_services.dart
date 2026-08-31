import '../features/auth/application/auth_session_manager.dart';
import '../features/auth/application/auth_session_store.dart';
import '../features/auth/data/auth_api_client.dart';
import '../features/auth/data/authenticated_http_client.dart';
import '../features/saved_search/application/saved_search_service.dart';
import '../features/saved_search/data/saved_search_repository.dart';
import '../features/vehicles/application/vehicle_search_service.dart';
import '../features/vehicles/data/vehicle_repository.dart';

abstract final class AppServices {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static final AuthApiClient authApiClient = AuthApiClient(baseUrl: apiBaseUrl);

  static final AuthSessionStore authSessionStore = AuthSessionStore();

  static final AuthSessionManager authSessionManager = AuthSessionManager(
    authApiClient,
    authSessionStore,
  );

  static final AuthenticatedHttpClient authenticatedHttpClient =
      AuthenticatedHttpClient(
        baseUrl: apiBaseUrl,
        authSessionStore: authSessionStore,
        authSessionManager: authSessionManager,
      );

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
