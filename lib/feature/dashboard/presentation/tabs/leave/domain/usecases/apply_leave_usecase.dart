import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/repositories/leave_repository.dart';

class ApplyLeaveUseCase {
  ApplyLeaveUseCase(this._repository);

  final LeaveRepository _repository;

  ResultFuture<void> call({
    required String type,
    required int startDate,
    required int endDate,
    required String reason,
  }) {
    DebugLogger.log('📋', 'USECASE', 'ApplyLeaveUseCase called — type: $type');
    return _repository.applyLeave(
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
    );
  }
}
