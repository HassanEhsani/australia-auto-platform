import 'dart:convert';

import 'package:customer_app/features/auth/application/auth_session_manager.dart';
import 'package:customer_app/features/auth/application/auth_session_store.dart';
import 'package:customer_app/features/auth/data/auth_api_client.dart';
import 'package:customer_app/features/auth/data/authenticated_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class FakeAuthSessionStore extends AuthSessionStore {
  String? accessToken;
  String? refreshToken;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

void main() {
  test(
    'refreshes once after 401 and retries with the new access token',
    () async {
      final store = FakeAuthSessionStore()
        ..accessToken = 'expired-access-token'
        ..refreshToken = 'refresh-token-1';

      var refreshRequests = 0;

      final authApiClient = AuthApiClient(
        baseUrl: 'http://test.local',
        client: MockClient((request) async {
          refreshRequests++;

          expect(request.url.path, '/api/v1/auth/refresh');

          return http.Response(
            jsonEncode({
              'accessToken': 'new-access-token',
              'refreshToken': 'refresh-token-2',
            }),
            200,
            headers: const {'content-type': 'application/json'},
          );
        }),
      );

      final sessionManager = AuthSessionManager(authApiClient, store);

      var protectedRequests = 0;

      final protectedClient = MockClient((request) async {
        protectedRequests++;

        if (protectedRequests == 1) {
          expect(
            request.headers['Authorization'],
            'Bearer expired-access-token',
          );

          return http.Response('Unauthorized', 401);
        }

        expect(request.headers['Authorization'], 'Bearer new-access-token');

        return http.Response('OK', 200);
      });

      final client = AuthenticatedHttpClient(
        baseUrl: 'http://test.local',
        authSessionStore: store,
        authSessionManager: sessionManager,
        client: protectedClient,
      );

      final response = await client.get('/api/v1/auth/me');

      expect(response.statusCode, 200);
      expect(protectedRequests, 2);
      expect(refreshRequests, 1);

      expect(store.accessToken, 'new-access-token');
      expect(store.refreshToken, 'refresh-token-2');
    },
  );

  test(
    'retries only once when the protected endpoint keeps returning 401',
    () async {
      final store = FakeAuthSessionStore()
        ..accessToken = 'expired-access-token'
        ..refreshToken = 'refresh-token-1';

      var refreshRequests = 0;

      final authApiClient = AuthApiClient(
        baseUrl: 'http://test.local',
        client: MockClient((request) async {
          refreshRequests++;

          return http.Response(
            jsonEncode({
              'accessToken': 'new-access-token',
              'refreshToken': 'refresh-token-2',
            }),
            200,
            headers: const {'content-type': 'application/json'},
          );
        }),
      );

      final sessionManager = AuthSessionManager(authApiClient, store);

      var protectedRequests = 0;

      final protectedClient = MockClient((request) async {
        protectedRequests++;
        return http.Response('Unauthorized', 401);
      });

      final client = AuthenticatedHttpClient(
        baseUrl: 'http://test.local',
        authSessionStore: store,
        authSessionManager: sessionManager,
        client: protectedClient,
      );

      final response = await client.get('/api/v1/auth/me');

      expect(response.statusCode, 401);
      expect(protectedRequests, 2);
      expect(refreshRequests, 1);
    },
  );
}
