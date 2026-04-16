/// Represents an exception occurring during server-side laboratory interaction.
class ServerException implements Exception {
  /// Creates a [ServerException] with an associated clinical [message].
  const ServerException({required this.message, this.statusCode});

  /// The clinical message associated with the failure.
  final String message;

  /// The associated HTTP status code.
  final int? statusCode;

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

/// Represents an exception occurring during local data caching.
class CacheException implements Exception {
  /// Creates a [CacheException] with an associated clinical [message].
  const CacheException({required this.message});

  /// The clinical message associated with the failure.
  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}
