import 'package:dio/dio.dart';
import 'package:hireanythingbooking/feature/add_task/data/models/service_model.dart';

abstract class AddTaskRemoteDataSource {
  Future<List<ServiceModel>> getMyServices();
  Future<void> createTask(Map<String, dynamic> payload);
}

class AddTaskRemoteDataSourceImpl implements AddTaskRemoteDataSource {
  AddTaskRemoteDataSourceImpl(this.dio);
  final Dio dio;

  @override
  Future<List<ServiceModel>> getMyServices() async {
    final resp = await dio.get<Map<String, dynamic>>(
      '/api/v1/workers/me/services',
    );
    if (resp.statusCode == 200 && resp.data != null) {
      final data = resp.data!['data'] as List<dynamic>?;
      return data
              ?.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }
    return [];
  }

  @override
  Future<void> createTask(Map<String, dynamic> payload) async {
    await dio.post<void>('/api/v1/tasks', data: payload);
  }
}
