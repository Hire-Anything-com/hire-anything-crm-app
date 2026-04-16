import 'package:equatable/equatable.dart';

/// Represents a failure in the Rehab Insight clinical platform.
abstract class Failure extends Equatable {
  /// Creates a [Failure] with an associated clinical [message].
  const Failure({required this.message, this.statusCode});

  /// The clinical message associated with the failure.
  final String message;

  /// The associated HTTP status code, if any.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure occurring during server-side interaction.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with the specified clinical parameters.
  const ServerFailure({required super.message, super.statusCode});
}

/// Represents a failure occurring during local data caching.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] with the specified clinical parameters.
  const CacheFailure({required super.message});
}
