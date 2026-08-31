import '../data/auth_api_client.dart';
import 'auth_session_store.dart';

class AuthSessionManager {
  AuthSessionManager(this._authApiClient, this._authSessionStore);

  final AuthApiClient _authApiClient;
  final AuthSessionStore _authSessionStore;

  Future<String?>? _refreshInFlight;

  Future<String?> refreshAccessToken() {
    final existingRefresh = _refreshInFlight;

    if (existingRefresh != null) {
      return existingRefresh;
    }

    final refresh = _performRefresh();
    _refreshInFlight = refresh;

    return refresh.whenComplete(() {
      if (identical(_refreshInFlight, refresh)) {
        _refreshInFlight = null;
      }
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _authSessionStore.readRefreshToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _authApiClient.refresh(refreshToken: refreshToken);

      await _authSessionStore.save(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      return response.accessToken;
    } on AuthApiException {
      await _authSessionStore.clear();
      return null;
    }
  }
}
