import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';

class GetMyAssignmentsUseCase {
  GetMyAssignmentsUseCase(this._repository);

  final TaskRepository _repository;

  ResultFuture<List<TaskModel>> call() {
    DebugLogger.log('📋', 'USECASE', 'GetMyAssignmentsUseCase called');
    return _repository.getMyAssignments();
  }
}
