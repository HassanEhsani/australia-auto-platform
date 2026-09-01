import 'dart:convert';

import '../../auth/data/authenticated_http_client.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.status,
    required this.roles,
    required this.sessionId,
  });

  final String id;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String status;
  final List<String> roles;
  final String sessionId;

  String get displayName {
    final parts = [
      firstName?.trim(),
      lastName?.trim(),
    ].whereType<String>().where((part) => part.isNotEmpty).toList();

    return parts.isEmpty ? email : parts.join(' ');
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((role) => role as String)
          .toList(),
      sessionId: json['sessionId'] as String,
    );
  }
}

class ProfileApiException implements Exception {
  const ProfileApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ProfileApiClient {
  const ProfileApiClient(this._client);

  final AuthenticatedHttpClient _client;

  Future<UserProfile> getCurrentUser() async {
    final response = await _client.get('/api/v1/auth/me');

    if (response.statusCode != 200) {
      throw ProfileApiException(
        'Unable to load your profile.',
        statusCode: response.statusCode,
      );
    }

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfile.fromJson(json);
    } catch (_) {
      throw const ProfileApiException(
        'The server returned an invalid profile response.',
      );
    }
  }
}
