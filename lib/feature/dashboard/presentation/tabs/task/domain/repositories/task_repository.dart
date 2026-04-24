import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';

abstract class TaskRepository {
  ResultFuture<List<TaskModel>> getMyAssignments();
  ResultFuture<void> respondToAssignment({
    required String id,
    required String action,
    required String reason,
  });
  ResultFuture<void> uploadTaskPhotos({
    required String id,
    required List<String> photos,
    required int startTime,
    required int endTime,
  });
  ResultFuture<void> completeTaskAssignment({
    required String id,
    required String otp,
  });
}
