import 'package:hireanythingbooking/feature/add_task/domain/entities/entities.dart';
import 'package:hireanythingbooking/feature/add_task/domain/repositories/add_task_repository.dart';

class GetMyServicesUseCase {
  final AddTaskRepository repository;

  GetMyServicesUseCase(this.repository);

  Future<List<ServiceItem>> call() async {
    return repository.getMyServices();
  }
}
