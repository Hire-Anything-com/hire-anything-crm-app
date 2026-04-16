import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/feature/dashboard/task/model/task_model.dart';

class TaskState extends Equatable {
  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.activeTaskId,
    this.remainingSeconds = 0,
    this.isTimerRunning = false,
    this.photoPaths = const [],
    this.otpError,
    this.taskCompleted = false,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final String? activeTaskId;
  final int remainingSeconds;
  final bool isTimerRunning;
  final List<String> photoPaths;
  final String? otpError;
  final bool taskCompleted;

  List<TaskModel> get pendingTasks =>
      tasks.where((t) => t.status == TaskStatus.pending).toList();

  List<TaskModel> get acceptedTasks => tasks
      .where(
        (t) =>
            t.status == TaskStatus.accepted ||
            t.status == TaskStatus.inProgress,
      )
      .toList();

  List<TaskModel> get rejectedTasks =>
      tasks.where((t) => t.status == TaskStatus.rejected).toList();

  List<TaskModel> get completedTasks =>
      tasks.where((t) => t.status == TaskStatus.completed).toList();

  TaskModel? get activeTask => activeTaskId != null
      ? tasks.firstWhere((t) => t.id == activeTaskId)
      : null;

  String get timerDisplay {
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
    List<String>? photoPaths,
    String? otpError,
    bool? taskCompleted,
    bool clearActiveTask = false,
    bool clearPhotos = false,
    bool clearOtpError = false,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      activeTaskId: clearActiveTask
          ? null
          : (activeTaskId ?? this.activeTaskId),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      photoPaths: clearPhotos ? const [] : (photoPaths ?? this.photoPaths),
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      taskCompleted: taskCompleted ?? this.taskCompleted,
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    isLoading,
    activeTaskId,
    remainingSeconds,
    isTimerRunning,
    photoPaths,
    otpError,
    taskCompleted,
  ];
}
