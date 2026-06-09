import 'package:dartz/dartz.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/errors/failure.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/datasources/leave_remote_datasource.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/repositories/leave_repository.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl({required LeaveRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final LeaveRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<void> applyLeave({
    required String type,
    required int startDate,
    required int endDate,
    required String reason,
  }) async {
    DebugLogger.repository('Apply leave initiated — type: $type');
    try {
      await _remoteDataSource.applyLeave(
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      DebugLogger.repository('Leave applied successfully');
      return const Right(null);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException during apply leave: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error during apply leave: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<LeaveModel>> getMyLeaves() async {
    DebugLogger.repository('Fetching my leaves');
    try {
      final leaves = await _remoteDataSource.getMyLeaves();
      DebugLogger.repository('Fetched ${leaves.length} leaves');
      return Right(leaves);
    } on ServerException catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'ServerException during get my leaves: ${e.message}',
      );
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on Exception catch (e) {
      DebugLogger.error(
        'REPOSITORY',
        'Unexpected error during get my leaves: $e',
      );
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
