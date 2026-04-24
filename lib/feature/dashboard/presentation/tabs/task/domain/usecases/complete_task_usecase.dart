import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';

class CompleteTaskUseCase {
  CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  ResultFuture<void> call({required String id, required String otp}) {
    DebugLogger.log('📋', 'USECASE', 'CompleteTaskUseCase called — id: $id');
    return _repository.completeTaskAssignment(id: id, otp: otp);
  }
}
