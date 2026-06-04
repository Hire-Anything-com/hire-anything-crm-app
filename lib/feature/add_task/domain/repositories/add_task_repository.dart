import 'package:hireanythingbooking/feature/add_task/domain/entities/entities.dart';

abstract class AddTaskRepository {
  Future<List<ServiceItem>> getMyServices();
  Future<void> createTask(Map<String, dynamic> payload);
}
