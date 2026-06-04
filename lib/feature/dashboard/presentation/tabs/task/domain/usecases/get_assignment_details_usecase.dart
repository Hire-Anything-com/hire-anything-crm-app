import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/assignment_detail_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';

class GetAssignmentDetailsUseCase {
  GetAssignmentDetailsUseCase(this._repository);

  final TaskRepository _repository;

  ResultFuture<AssignmentDetailModel> call(String id) {
    DebugLogger.log(
      '📋',
      'USECASE',
      'GetAssignmentDetailsUseCase called — id: $id',
    );
    return _repository.getAssignmentById(id);
  }
}
