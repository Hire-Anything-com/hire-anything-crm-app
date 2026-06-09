import 'package:flutter/foundation.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/storage/secure_token_storage.dart';

/// Abstract data source for local token storage
abstract class LoginLocalDataSource {
  /// Saves tokens locally
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Retrieves stored access token
  Future<String?> getAccessToken();

  /// Retrieves stored refresh token
  Future<String?> getRefreshToken();

  /// Updates access token
  Future<void> updateAccessToken(String newAccessToken);

  /// Clears all tokens
  Future<void> clearTokens();

  /// Save user profile fields locally.
  Future<void> saveUserProfile(Map<String, dynamic> profile);

  /// Get stored user profile or null.
  Future<Map<String, dynamic>?> getUserProfile();

  /// Clears stored user profile.
  Future<void> clearUserProfile();
}

/// Implementation of login local data source
class LoginLocalDataSourceImpl implements LoginLocalDataSource {
  LoginLocalDataSourceImpl(this._secureTokenStorage);

  final SecureTokenStorage _secureTokenStorage;

  /// Helper to display full token for debugging (in debug mode only)
  String _tokenDisplay(String? token) {
    if (token == null) return 'null';
    if (kDebugMode) {
      return token; // Show full token in debug mode
    }
    // In production, show masked version
    if (token.length <= 20) return '****';
    return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    DebugLogger.storage(
      'Saving tokens: access=${_tokenDisplay(accessToken)}, '
      'refresh=${_tokenDisplay(refreshToken)}',
    );
    try {
      await _secureTokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      DebugLogger.storage('Tokens saved successfully');
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to save tokens: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureTokenStorage.getAccessToken();
      DebugLogger.storage('Retrieved access token: ${_tokenDisplay(token)}');
      return token;
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to get access token: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureTokenStorage.getRefreshToken();
      DebugLogger.storage('Retrieved refresh token: ${_tokenDisplay(token)}');
      return token;
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to get refresh token: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> updateAccessToken(String newAccessToken) async {
    DebugLogger.storage(
      'Updating access token: ${_tokenDisplay(newAccessToken)}',
    );
    try {
      await _secureTokenStorage.updateAccessToken(newAccessToken);
      DebugLogger.storage('Access token updated successfully');
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to update access token: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearTokens() async {
    DebugLogger.storage('Clearing all tokens from secure storage');
    try {
      await _secureTokenStorage.clearTokens();
      DebugLogger.storage('All tokens cleared successfully');
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to clear tokens: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    DebugLogger.storage('Saving user profile to secure storage');
    try {
      await _secureTokenStorage.saveUserProfile(profile);
      DebugLogger.storage('User profile saved');
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to save user profile: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profile = await _secureTokenStorage.getUserProfile();
      DebugLogger.storage('Retrieved user profile: ${profile != null}');
      return profile;
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to get user profile: $e');
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearUserProfile() async {
    DebugLogger.storage('Clearing user profile from secure storage');
    try {
      await _secureTokenStorage.clearUserProfile();
      DebugLogger.storage('User profile cleared');
    } catch (e) {
      DebugLogger.error('STORAGE', 'Failed to clear user profile: $e');
      throw CacheException(message: e.toString());
    }
  }
}
