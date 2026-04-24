import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';

abstract class LeaveRepository {
  ResultFuture<void> applyLeave({
    required String type,
    required int startDate,
    required int endDate,
    required String reason,
  });

  ResultFuture<List<LeaveModel>> getMyLeaves();
}
