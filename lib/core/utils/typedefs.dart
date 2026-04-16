import 'package:dartz/dartz.dart';
import 'package:hireanythingbooking/core/errors/failure.dart';

/// A standard clinical result type for asynchronous operations.
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// A standard clinical result type for operations returning void.
typedef ResultVoid = ResultFuture<void>;

/// A generic map type for managing clinical JSON data structures.
typedef DataMap = Map<String, dynamic>;
