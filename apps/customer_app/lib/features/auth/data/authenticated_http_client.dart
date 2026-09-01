import 'package:http/http.dart' as http;

import '../application/auth_session_manager.dart';
import '../application/auth_session_store.dart';

class AuthenticatedHttpClient {
  AuthenticatedHttpClient({
    required this._baseUrl,
    required this._authSessionStore,
    required this._authSessionManager,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String _baseUrl;
  final AuthSessionStore _authSessionStore;
  final AuthSessionManager _authSessionManager;
  final http.Client _client;

  Future<http.Response> get(String path, {Map<String, String>? headers}) {
    return _send(method: 'GET', path: path, headers: headers);
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send(method: 'POST', path: path, headers: headers, body: body);
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send(method: 'PUT', path: path, headers: headers, body: body);
  }

  Future<http.Response> patch(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send(method: 'PATCH', path: path, headers: headers, body: body);
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _send(method: 'DELETE', path: path, headers: headers, body: body);
  }

  Future<http.Response> _send({
    required String method,
    required String path,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final accessToken = await _authSessionStore.readAccessToken();

    final firstResponse = await _performRequest(
      method: method,
      path: path,
      accessToken: accessToken,
      headers: headers,
      body: body,
    );

    if (firstResponse.statusCode != 401) {
      return firstResponse;
    }

    final refreshedAccessToken = await _authSessionManager.refreshAccessToken();

    if (refreshedAccessToken == null) {
      return firstResponse;
    }

    return _performRequest(
      method: method,
      path: path,
      accessToken: refreshedAccessToken,
      headers: headers,
      body: body,
    );
  }

  Future<http.Response> _performRequest({
    required String method,
    required String path,
    required String? accessToken,
    Map<String, String>? headers,
    Object? body,
  }) {
    final requestHeaders = <String, String>{...?headers};

    if (accessToken != null && accessToken.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $accessToken';
    }

    final uri = Uri.parse('$_baseUrl$path');

    switch (method) {
      case 'GET':
        return _client.get(uri, headers: requestHeaders);
      case 'POST':
        return _client.post(uri, headers: requestHeaders, body: body);
      case 'PUT':
        return _client.put(uri, headers: requestHeaders, body: body);
      case 'PATCH':
        return _client.patch(uri, headers: requestHeaders, body: body);
      case 'DELETE':
        return _client.delete(uri, headers: requestHeaders, body: body);
      default:
        throw UnsupportedError('Unsupported HTTP method: $method');
    }
  }
}
