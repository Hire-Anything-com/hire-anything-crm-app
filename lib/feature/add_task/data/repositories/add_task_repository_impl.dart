import 'package:hireanythingbooking/feature/add_task/data/datasources/add_task_remote_datasource.dart';
import 'package:hireanythingbooking/feature/add_task/domain/entities/entities.dart';
import 'package:hireanythingbooking/feature/add_task/domain/repositories/add_task_repository.dart';

class AddTaskRepositoryImpl implements AddTaskRepository {
  AddTaskRepositoryImpl({required this.remoteDataSource});

  final AddTaskRemoteDataSource remoteDataSource;

  @override
  Future<List<ServiceItem>> getMyServices() async {
    final models = await remoteDataSource.getMyServices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createTask(Map<String, dynamic> payload) async {
    await remoteDataSource.createTask(payload);
  }
}
