import 'package:dartz/dartz.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/errors/failure.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/datasources/task_remote_datasource.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/assignment_detail_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({required TaskRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final TaskRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<List<TaskModel>> getMyAssignments() async {
    DebugLogger.repository('Fetching my assignments');
    try {
      final tasks = await _remoteDataSource.getMyAssignments();
      DebugLogger.repository('Assignments fetched — count: ${tasks.length}');
      return Right(tasks);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException fetching assignments: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error fetching assignments: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> respondToAssignment({
    required String id,
    required String action,
    required String reason,
  }) async {
    DebugLogger.repository('Responding to assignment $id with action: $action');
    try {
      await _remoteDataSource.respondToAssignment(
        id: id,
        action: action,
        reason: reason,
      );
      DebugLogger.repository('Assignment responded successfully');
      return const Right(null);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException responding to assignment: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error responding to assignment: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> uploadTaskPhotos({
    required String id,
    required List<String> photos,
    required int startTime,
    required int endTime,
  }) async {
    DebugLogger.repository(
      'Uploading task photos — id: $id, count: ${photos.length}',
    );
    try {
      await _remoteDataSource.uploadTaskPhotos(
        id: id,
        photos: photos,
        startTime: startTime,
        endTime: endTime,
      );
      DebugLogger.repository('Task photos uploaded successfully');
      return const Right(null);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException uploading task photos: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error uploading task photos: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<void> completeTaskAssignment({
    required String id,
    required String otp,
  }) async {
    DebugLogger.repository('Completing task — id: $id');
    try {
      await _remoteDataSource.completeTaskAssignment(id: id, otp: otp);
      DebugLogger.repository('Task completed successfully');
      return const Right(null);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException completing task: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error('REPOSITORY', 'Unexpected error completing task: $e');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<AssignmentDetailModel> getAssignmentById(String id) async {
    DebugLogger.repository('Fetching assignment details — id: $id');
    try {
      final assignment = await _remoteDataSource.getAssignmentById(id);
      DebugLogger.repository('Assignment fetched — id: ${assignment.id}');
      return Right(assignment);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException fetching assignment: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error fetching assignment: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
