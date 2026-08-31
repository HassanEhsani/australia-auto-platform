import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthUser {
  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.status,
    required this.roles,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String status;
  final List<String> roles;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String,
      status: json['status'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role as String)
          .toList(),
    );
  }
}

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class RefreshTokenResponse {
  const RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthApiClient {
  AuthApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );

    final body = _decodeBody(response.body);

    if (response.statusCode != 200) {
      throw AuthApiException(
        _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    }

    return LoginResponse.fromJson(body);
  }

  Future<RefreshTokenResponse> refresh({required String refreshToken}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/refresh'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final body = _decodeBody(response.body);

    if (response.statusCode != 200) {
      throw AuthApiException(
        _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    }

    return RefreshTokenResponse.fromJson(body);
  }

  Future<void> logout({required String refreshToken}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/v1/auth/logout'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 204) {
      return;
    }

    var message = 'Unable to sign out. Please try again.';

    if (response.body.isNotEmpty) {
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final serverMessage = body['message'];

        if (serverMessage is String && serverMessage.isNotEmpty) {
          message = serverMessage;
        } else if (serverMessage is List && serverMessage.isNotEmpty) {
          message = serverMessage.join('\n');
        }
      } catch (_) {
        // Keep the generic logout error message.
      }
    }

    throw AuthApiException(message, statusCode: response.statusCode);
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      throw const AuthApiException('The server returned an invalid response.');
    }
  }

  String _extractErrorMessage(Map<String, dynamic> body) {
    final message = body['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    if (message is List && message.isNotEmpty) {
      return message.join('\n');
    }

    return 'Unable to sign in. Please try again.';
  }
}
