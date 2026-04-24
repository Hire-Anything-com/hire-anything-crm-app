import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/errors/exceptions.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';

abstract class LeaveRemoteDataSource {
  Future<void> applyLeave({
    required String type,
    required int startDate,
    required int endDate,
    required String reason,
  });

  Future<List<LeaveModel>> getMyLeaves();
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  LeaveRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<void> applyLeave({
    required String type,
    required int startDate,
    required int endDate,
    required String reason,
  }) async {
    DebugLogger.remote(
      'Apply leave request — type: $type, '
      'startDate: $startDate, endDate: $endDate',
    );
    try {
      final response = await _dio.post<dynamic>(
        '/api/v1/leaves',
        data: {
          'type': type,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
        },
      );

      DebugLogger.remote(
        'Apply leave response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Apply leave response body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        DebugLogger.remote('Leave applied successfully');
        return;
      }

      final message = _extractMessage(response.data) ?? 'Failed to apply leave';
      DebugLogger.error('REMOTE', 'Apply leave failed — $message');
      throw ServerException(message: message, statusCode: response.statusCode);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error('REMOTE', 'DioException during apply leave: $e');
      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }

  @override
  Future<List<LeaveModel>> getMyLeaves() async {
    DebugLogger.remote('Fetching my leaves');
    try {
      final response = await _dio.get<dynamic>('/api/v1/leaves/me');

      DebugLogger.remote(
        'Get my leaves response — status: ${response.statusCode}',
      );
      DebugLogger.remote('Get my leaves body: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiResponse = response.data;
        if (apiResponse is Map<String, dynamic> &&
            apiResponse['success'] == true) {
          final data = apiResponse['data'];
          if (data is List) {
            return data
                .map((e) => LeaveModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
        return [];
      }

      final message =
          _extractMessage(response.data) ?? 'Failed to fetch leaves';
      DebugLogger.error('REMOTE', 'Get my leaves failed — $message');
      throw ServerException(message: message, statusCode: response.statusCode);
    } on ServerException {
      rethrow;
    } on DioException catch (e) {
      DebugLogger.error('REMOTE', 'DioException during get my leaves: $e');
      throw ServerException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
