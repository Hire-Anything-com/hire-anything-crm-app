import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/typedefs.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';

class UploadTaskPhotosUseCase {
  UploadTaskPhotosUseCase(this._repository);

  final TaskRepository _repository;

  ResultFuture<void> call({
    required String id,
    required List<String> photos,
    required int startTime,
    required int endTime,
  }) {
    DebugLogger.log(
      '📋',
      'USECASE',
      'UploadTaskPhotosUseCase called — id: $id, '
          'photos: ${photos.length}, startTime: $startTime, endTime: $endTime',
    );
    return _repository.uploadTaskPhotos(
      id: id,
      photos: photos,
      startTime: startTime,
      endTime: endTime,
    );
  }
}
