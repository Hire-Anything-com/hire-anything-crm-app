import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/constants/app_constants.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/assignment_detail_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getMyAssignments();
  Future<AssignmentDetailModel> getAssignmentById(String id);
  Future<void> respondToAssignment({
    required String id,
    required String action,
    required String reason,
  });
  Future<void> uploadTaskPhotos({
    required String id,
    required List<String> photos,
    required int startTime,
    required int endTime,
  });
  Future<void> completeTaskAssignment({
    required String id,
    required String otp,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  TaskRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TaskModel>> getMyAssignments() async {
    DebugLogger.remote('Fetching my assignments');
    try {
      final response = await _dio.get<dynamic>(
        AppConstants.myAssignmentsEndpoint,
      );

      DebugLogger.remote(
        'My assignments response — status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true &&
            apiResponse['data'] != null) {
          final dataList = apiResponse['data'] as List<dynamic>;
          DebugLogger.remote('Assignments fetched — count: ${dataList.length}');
          return dataList.map((e) => TaskModel.fromJson(e as DataMap)).toList();
        }
      }

      if (response.statusCode == 401) {
        final msg = _extractMessage(response.data) ?? 'Unauthorized';
        throw ServerException(message: msg, statusCode: 401);
      }

      throw ServerException(
        message: _extractMessage(response.data) ?? 'Failed to fetch tasks',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException fetching assignments: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error fetching assignments: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AssignmentDetailModel> getAssignmentById(String id) async {
    DebugLogger.remote('Fetching assignment details — id: $id');
    try {
      final response = await _dio.get<dynamic>(
        '${AppConstants.taskAssignmentsEndpoint}/$id',
      );

      DebugLogger.remote(
        'Assignment details response — status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true &&
            apiResponse['data'] != null) {
          return AssignmentDetailModel.fromJson(apiResponse['data'] as DataMap);
        }
      }

      if (response.statusCode == 401) {
        final msg = _extractMessage(response.data) ?? 'Unauthorized';
        throw ServerException(message: msg, statusCode: 401);
      }

      throw ServerException(
        message: _extractMessage(response.data) ?? 'Failed to fetch assignment',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException fetching assignment: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error fetching assignment: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> respondToAssignment({
    required String id,
    required String action,
    required String reason,
  }) async {
    DebugLogger.remote('Responding to assignment $id with action: $action');
    try {
      final response = await _dio.patch<dynamic>(
        '${AppConstants.taskAssignmentsEndpoint}/$id/respond',
        data: {'action': action, 'reason': reason},
      );

      DebugLogger.remote(
        'Respond assignment response — status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 401) {
        final msg = _extractMessage(response.data) ?? 'Unauthorized';
        throw ServerException(message: msg, statusCode: 401);
      }

      throw ServerException(
        message: _extractMessage(response.data) ?? 'Failed to respond to task',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException responding to assignment: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error(
        'REMOTE',
        'Unexpected error responding to assignment: $e',
      );
      throw ServerException(message: e.toString());
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error']) as String?;
    }
    return null;
  }

  @override
  Future<void> uploadTaskPhotos({
    required String id,
    required List<String> photos,
    required int startTime,
    required int endTime,
  }) async {
    final url = '${AppConstants.taskAssignmentsEndpoint}/$id/photos';
    final body = <String, dynamic>{
      'photos': photos,
      'startTime': startTime,
      'endTime': endTime,
    };
    DebugLogger.remote(
      'Uploading task photos — id: $id, photoCount: ${photos.length}, '
      'startTime: $startTime, endTime: $endTime',
    );
    DebugLogger.remote('PATCH $url');
    DebugLogger.remote('Request body: $body');
    try {
      final response = await _dio.patch<dynamic>(url, data: body);

      DebugLogger.remote(
        'Upload task photos response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        DebugLogger.remote('Task photos uploaded successfully — id: $id');
        return;
      }

      if (response.statusCode == 401) {
        final msg = _extractMessage(response.data) ?? 'Unauthorized';
        throw ServerException(message: msg, statusCode: 401);
      }

      throw ServerException(
        message:
            _extractMessage(response.data) ?? 'Failed to upload task photos',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error(
        'REMOTE',
        'DioException uploading task photos: ${e.type}',
      );
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error uploading task photos: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> completeTaskAssignment({
    required String id,
    required String otp,
  }) async {
    final url = '${AppConstants.taskAssignmentsEndpoint}/$id/complete';
    final body = <String, dynamic>{'otp': otp};
    DebugLogger.remote('PATCH $url');
    DebugLogger.remote('Request body: $body');
    try {
      final response = await _dio.patch<dynamic>(url, data: body);

      DebugLogger.remote(
        'Complete task response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      if (response.statusCode == 401) {
        final msg = _extractMessage(response.data) ?? 'Unauthorized';
        throw ServerException(message: msg, statusCode: 401);
      }

      throw ServerException(
        message: _extractMessage(response.data) ?? 'Failed to complete task',
        statusCode: response.statusCode,
      );
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error('REMOTE', 'DioException completing task: ${e.type}');
      throw _handleDioException(e);
    } catch (e) {
      DebugLogger.error('REMOTE', 'Unexpected error completing task: $e');
      throw ServerException(message: e.toString());
    }
  }

  ServerException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(
          message: 'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const ServerException(message: 'No internet connection.');
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled.');
      case DioExceptionType.badResponse:
        return ServerException(message: e.message ?? 'Network error occurred.');
      case DioExceptionType.unknown:
        return ServerException(message: e.message ?? 'Network error occurred.');
      case DioExceptionType.badCertificate:
        return ServerException(message: e.message ?? 'Network error occurred.');
    }
  }
}
