import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';

class TaskState extends Equatable {
  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.activeTaskId,
    this.remainingSeconds = 0,
    this.isTimerRunning = false,
    this.isOvertime = false,
    this.overtimeSeconds = 0,
    this.photoPaths = const [],
    this.cloudinaryUrls = const [],
    this.taskStartTimeEpoch,
    this.taskEndTimeEpoch,
    this.isUploadingPhotos = false,
    this.isCloudinaryUploading = false,
    this.pendingPhotoPath,
    this.photoUploadError,
    this.otpError,
    this.isCompletingTask = false,
    this.taskCompleted = false,
    this.respondingTaskId,
    String? errorMessage,
  }) : _errorMessage = errorMessage;

  final List<TaskModel> tasks;
  final bool isLoading;
  final String? activeTaskId;
  final int remainingSeconds;
  final bool isTimerRunning;
  final bool isOvertime;
  final int overtimeSeconds;
  final List<String> photoPaths;

  /// Cloudinary secure URLs for the photos uploaded during the active task.
  final List<String> cloudinaryUrls;

  /// Unix epoch seconds when the active task timer was started.
  final int? taskStartTimeEpoch;

  /// Unix epoch seconds when the active task timer was stopped.
  final int? taskEndTimeEpoch;

  /// True while the photo-upload API call is in flight.
  final bool isUploadingPhotos;

  /// True while a Cloudinary upload is in progress (before photo is added).
  final bool isCloudinaryUploading;

  /// Local file path of the photo currently being uploaded to Cloudinary.
  final String? pendingPhotoPath;

  /// Non-null when the photo-upload API call failed.
  final String? photoUploadError;

  final String? otpError;
  final bool isCompletingTask;
  final bool taskCompleted;
  final String? respondingTaskId;

  String? get errorMessage => _errorMessage;
  final String? _errorMessage;

  List<TaskModel> get assignedTasks =>
      tasks.where((t) => t.status == TaskStatus.assigned).toList();

  List<TaskModel> get acceptedTasks =>
      tasks.where((t) => t.status == TaskStatus.accepted).toList();

  List<TaskModel> get inProgressTasks =>
      tasks.where((t) => t.status == TaskStatus.inProgress).toList();

  List<TaskModel> get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();

  List<TaskModel> get cancelledTasks =>
      tasks.where((t) => t.status == TaskStatus.cancelled).toList();

  TaskModel? get activeTask => activeTaskId != null
      ? tasks.firstWhere((t) => t.id == activeTaskId)
      : null;

  String get timerDisplay {
    if (isOvertime) {
      final minutes = overtimeSeconds ~/ 60;
      final seconds = overtimeSeconds % 60;
      return '+${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  TaskState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? activeTaskId,
    int? remainingSeconds,
    bool? isTimerRunning,
    bool? isOvertime,
    int? overtimeSeconds,
    List<String>? photoPaths,
    List<String>? cloudinaryUrls,
    int? taskStartTimeEpoch,
    int? taskEndTimeEpoch,
    bool? isUploadingPhotos,
    bool? isCloudinaryUploading,
    String? pendingPhotoPath,
    String? photoUploadError,
    String? otpError,
    bool? isCompletingTask,
    bool? taskCompleted,
    String? respondingTaskId,
    String? errorMessage,
    bool clearActiveTask = false,
    bool clearPhotos = false,
    bool clearCloudinaryUrls = false,
    bool clearOtpError = false,
    bool clearError = false,
    bool clearRespondingTask = false,
    bool clearPhotoUploadError = false,
    bool clearPendingPhoto = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      activeTaskId: clearActiveTask
          ? null
          : (activeTaskId ?? this.activeTaskId),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      isOvertime: isOvertime ?? this.isOvertime,
      overtimeSeconds: overtimeSeconds ?? this.overtimeSeconds,
      photoPaths: clearPhotos ? const [] : (photoPaths ?? this.photoPaths),
      cloudinaryUrls: clearCloudinaryUrls
          ? const []
          : (cloudinaryUrls ?? this.cloudinaryUrls),
      taskStartTimeEpoch: taskStartTimeEpoch ?? this.taskStartTimeEpoch,
      taskEndTimeEpoch: taskEndTimeEpoch ?? this.taskEndTimeEpoch,
      isUploadingPhotos: isUploadingPhotos ?? this.isUploadingPhotos,
      isCloudinaryUploading:
          isCloudinaryUploading ?? this.isCloudinaryUploading,
      pendingPhotoPath: clearPendingPhoto
          ? null
          : (pendingPhotoPath ?? this.pendingPhotoPath),
      photoUploadError: clearPhotoUploadError
          ? null
          : (photoUploadError ?? this.photoUploadError),
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      isCompletingTask: isCompletingTask ?? this.isCompletingTask,
      taskCompleted: taskCompleted ?? this.taskCompleted,
      respondingTaskId: clearRespondingTask
          ? null
          : (respondingTaskId ?? this.respondingTaskId),
      errorMessage: clearError ? null : (errorMessage ?? _errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    isLoading,
    activeTaskId,
    remainingSeconds,
    isTimerRunning,
    isOvertime,
    overtimeSeconds,
    photoPaths,
    cloudinaryUrls,
    taskStartTimeEpoch,
    taskEndTimeEpoch,
    isUploadingPhotos,
    isCloudinaryUploading,
    pendingPhotoPath,
    photoUploadError,
    otpError,
    isCompletingTask,
    taskCompleted,
    respondingTaskId,
    _errorMessage,
  ];
}
