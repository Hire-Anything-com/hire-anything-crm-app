import 'package:flutter/foundation.dart';

/// Centralized logging utility for the Rehab Insight platform.
/// Standardizes clinical debug output with emojis and uppercase branding.
class DebugLogger {
  /// Logs a clinical event with the specified module and message.
  /// Format: `[emoji MODULE: message]`
  static void log(String emoji, String module, String message) {
    if (kDebugMode) {
      debugPrint('[$emoji ${module.toUpperCase()}: $message]');
    }
  }

  /// Logs an authentication-related event.
  static void auth(String message) => log('🔐', 'AUTH', message);

  /// Logs a remote data source event.
  static void remote(String message) => log('🌐', 'REMOTE', message);

  /// Logs a repository-level event.
  static void repository(String message) => log('📦', 'REPOSITORY', message);

  /// Logs a core initialization event.
  static void core(String message) => log('⚙️', 'CORE', message);

  /// Logs a Firebase-specific event.
  static void firebase(String message) => log('🔥', 'FIREBASE', message);

  /// Logs a local storage event.
  static void storage(String message) => log('💾', 'STORAGE', message);

  /// Logs an error event.
  static void error(String module, String message) => log('❌', module, message);
}
