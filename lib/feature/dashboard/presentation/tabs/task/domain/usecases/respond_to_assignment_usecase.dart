import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';

class RespondToAssignmentUseCase {
  RespondToAssignmentUseCase(this._repository);

  final TaskRepository _repository;

  ResultFuture<void> call({
    required String id,
    required String action,
    required String reason,
  }) {
    DebugLogger.log(
      '📋',
      'USECASE',
      'RespondToAssignmentUseCase called — id: $id, action: $action',
    );
    return _repository.respondToAssignment(
      id: id,
      action: action,
      reason: reason,
    );
  }
}
