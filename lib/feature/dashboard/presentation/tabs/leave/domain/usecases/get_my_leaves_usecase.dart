import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/repositories/leave_repository.dart';

class GetMyLeavesUseCase {
  GetMyLeavesUseCase(this._repository);

  final LeaveRepository _repository;

  ResultFuture<List<LeaveModel>> call() {
    DebugLogger.log('📋', 'USECASE', 'GetMyLeavesUseCase called');
    return _repository.getMyLeaves();
  }
}
