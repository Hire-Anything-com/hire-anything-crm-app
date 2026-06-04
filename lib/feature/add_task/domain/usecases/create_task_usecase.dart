import 'package:hireanythingbooking/feature/add_task/domain/repositories/add_task_repository.dart';

class CreateTaskUseCase {
  final AddTaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<void> call(Map<String, dynamic> payload) async {
    return repository.createTask(payload);
  }
}
