import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing secure token storage
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userProfileKey = 'user_profile';

  /// Stores both access and refresh tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: accessToken),
      _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Retrieves the stored access token
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Retrieves the stored refresh token
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  /// Updates the access token
  Future<void> updateAccessToken(String newAccessToken) async {
    await _secureStorage.write(key: _accessTokenKey, value: newAccessToken);
  }

  /// Clears all stored tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
  }

  /// Saves a user profile map as JSON in secure storage.
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final jsonStr = jsonEncode(profile);
    await _secureStorage.write(key: _userProfileKey, value: jsonStr);
  }

  /// Retrieves the stored user profile as a map, or null if not present.
  Future<Map<String, dynamic>?> getUserProfile() async {
    final jsonStr = await _secureStorage.read(key: _userProfileKey);
    if (jsonStr == null) return null;
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return decoded;
    } on Exception catch (_) {
      return null;
    }
  }

  /// Clears stored user profile
  Future<void> clearUserProfile() async {
    await _secureStorage.delete(key: _userProfileKey);
  }

  /// Checks if tokens exist
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
