import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/get_my_assignments_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/respond_to_assignment_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/get_assignment_details_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/upload_task_photos_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/complete_task_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/model/task_model.dart';
import 'package:hireanythingbooking/core/di/service_locator.dart';
import 'package:hireanythingbooking/feature/login/domain/usecases/login_usecase.dart';
import 'package:hireanythingbooking/core/routes/router.dart';
import 'package:hireanythingbooking/core/routes/routes.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit({
    required GetMyAssignmentsUseCase getMyAssignmentsUseCase,
    required GetAssignmentDetailsUseCase getAssignmentDetailsUseCase,
    required RespondToAssignmentUseCase respondToAssignmentUseCase,
    required UploadTaskPhotosUseCase uploadTaskPhotosUseCase,
    required CompleteTaskUseCase completeTaskUseCase,
  }) : _getMyAssignmentsUseCase = getMyAssignmentsUseCase,
       _getAssignmentDetailsUseCase = getAssignmentDetailsUseCase,
       _respondToAssignmentUseCase = respondToAssignmentUseCase,
       _uploadTaskPhotosUseCase = uploadTaskPhotosUseCase,
       _completeTaskUseCase = completeTaskUseCase,
       super(const TaskState()) {
    fetchMyAssignments();
  }

  final GetMyAssignmentsUseCase _getMyAssignmentsUseCase;
  final GetAssignmentDetailsUseCase _getAssignmentDetailsUseCase;
  final RespondToAssignmentUseCase _respondToAssignmentUseCase;
  final UploadTaskPhotosUseCase _uploadTaskPhotosUseCase;
  final CompleteTaskUseCase _completeTaskUseCase;
  Timer? _timer;

  Future<void> fetchMyAssignments() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getMyAssignmentsUseCase();
    await result.fold(
      (failure) async {
        // If unauthorized, attempt a silent retry (interceptor may refresh token)
        if (failure.statusCode == 401) {
          DebugLogger.error('TASK', '401 received — attempting silent retry');
          final retry = await _getMyAssignmentsUseCase();
          await retry.fold(
            (f2) async {
              // If still unauthorized, force logout and navigate to login
              if (f2.statusCode == 401) {
                DebugLogger.error('TASK', '401 after retry — logging out');
                try {
                  final logoutUseCase = getIt<LogoutUseCase>();
                  await logoutUseCase();
                } catch (e) {
                  DebugLogger.error('AUTH', 'Logout failed: $e');
                }
                try {
                  AppRouter.router.go(AppRoutes.login);
                } catch (e) {
                  DebugLogger.error('AUTH', 'Navigation to login failed: $e');
                }
                // clear loading without showing retry UI
                emit(state.copyWith(isLoading: false));
              } else {
                emit(
                  state.copyWith(isLoading: false, errorMessage: f2.message),
                );
              }
            },
            (tasks) async {
              emit(state.copyWith(isLoading: false, tasks: tasks));
            },
          );
        } else {
          emit(state.copyWith(isLoading: false, errorMessage: failure.message));
        }
      },
      (tasks) async {
        emit(state.copyWith(isLoading: false, tasks: tasks));
      },
    );
  }

  Future<void> fetchAssignmentDetails(String id) async {
    if (id.isEmpty) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _getAssignmentDetailsUseCase(id);
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (assignment) {
        emit(state.copyWith(isLoading: false, selectedAssignment: assignment));
      },
    );
  }

  Future<void> acceptTask(String taskId) async {
    emit(state.copyWith(respondingTaskId: taskId));
    final result = await _respondToAssignmentUseCase(
      id: taskId,
      action: 'ACCEPT',
      reason: '',
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          clearRespondingTask: true,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updated = state.tasks.map((t) {
          if (t.id == taskId) return t.copyWith(status: TaskStatus.accepted);
          return t;
        }).toList();
        emit(state.copyWith(tasks: updated, clearRespondingTask: true));
      },
    );
  }

  Future<void> rejectTask(String taskId, String reason) async {
    emit(state.copyWith(respondingTaskId: taskId));
    final result = await _respondToAssignmentUseCase(
      id: taskId,
      action: 'REJECT',
      reason: reason,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          clearRespondingTask: true,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updated = state.tasks.map((t) {
          if (t.id == taskId) return t.copyWith(status: TaskStatus.cancelled);
          return t;
        }).toList();
        emit(state.copyWith(tasks: updated, clearRespondingTask: true));
      },
    );
  }

  bool isStartingEarly(String taskId) {
    final task = state.tasks.firstWhere((t) => t.id == taskId);
    final scheduled = task.scheduledAt;
    if (scheduled == null) return false;
    return DateTime.now().isBefore(scheduled);
  }

  void startTask(String taskId) {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(status: TaskStatus.inProgress);
      return t;
    }).toList();

    final task = updated.firstWhere((t) => t.id == taskId);
    final totalSeconds = task.durationMinutes * 60;
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    DebugLogger.log(
      '⏱️',
      'TASK',
      'Task started — id: $taskId, startTime: $nowEpoch',
    );

    emit(
      state.copyWith(
        tasks: updated,
        activeTaskId: taskId,
        remainingSeconds: totalSeconds,
        isTimerRunning: true,
        isOvertime: false,
        overtimeSeconds: 0,
        taskStartTimeEpoch: nowEpoch,
        clearPhotos: true,
        clearCloudinaryUrls: true,
        clearOtpError: true,
        taskCompleted: false,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isOvertime) {
        // Overtime: count up like a stopwatch
        emit(state.copyWith(overtimeSeconds: state.overtimeSeconds + 1));
      } else if (state.remainingSeconds <= 1) {
        // Time's up — switch to overtime mode, keep timer running
        emit(
          state.copyWith(
            remainingSeconds: 0,
            isOvertime: true,
            overtimeSeconds: 0,
          ),
        );
      } else {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    final nowEpoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    DebugLogger.log('⏹️', 'TASK', 'Timer stopped — endTime: $nowEpoch');
    emit(state.copyWith(isTimerRunning: false, taskEndTimeEpoch: nowEpoch));
  }

  void setCloudinaryUploading({required bool value, String? path}) {
    emit(
      state.copyWith(
        isCloudinaryUploading: value,
        pendingPhotoPath: value ? path : null,
        clearPendingPhoto: !value,
      ),
    );
  }

  /// Atomically adds the local preview path and its Cloudinary URL together.
  /// Only call this after a successful Cloudinary upload.
  void addPhotoWithCloudinaryUrl(String path, String url) {
    if (state.photoPaths.length >= 3) return;
    DebugLogger.log('☁️', 'TASK', 'Photo accepted — url: $url');
    emit(
      state.copyWith(
        photoPaths: [...state.photoPaths, path],
        cloudinaryUrls: [...state.cloudinaryUrls, url],
        isCloudinaryUploading: false,
        clearPendingPhoto: true,
      ),
    );
  }

  void removePhoto(int index) {
    final updatedPaths = List<String>.from(state.photoPaths)..removeAt(index);
    // Also remove corresponding cloudinary URL at the same index
    final updatedUrls = List<String>.from(state.cloudinaryUrls);
    if (index < updatedUrls.length) updatedUrls.removeAt(index);
    emit(state.copyWith(photoPaths: updatedPaths, cloudinaryUrls: updatedUrls));
  }

  Future<void> submitTaskPhotos() async {
    final taskId = state.activeTaskId;
    if (taskId == null) {
      DebugLogger.error('TASK', 'submitTaskPhotos called with no activeTaskId');
      return;
    }

    final urls = state.cloudinaryUrls;
    if (urls.isEmpty) {
      DebugLogger.error(
        'TASK',
        'submitTaskPhotos called but no Cloudinary URLs in state',
      );
      emit(
        state.copyWith(
          photoUploadError: 'Photo upload is still in progress. Please wait.',
        ),
      );
      return;
    }

    final startTime =
        state.taskStartTimeEpoch ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final endTime =
        state.taskEndTimeEpoch ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

    DebugLogger.log(
      '📤',
      'TASK',
      'Submitting photos — id: $taskId, startTime: $startTime, endTime: $endTime, '
          'urls: $urls',
    );

    emit(state.copyWith(isUploadingPhotos: true, clearPhotoUploadError: true));

    final result = await _uploadTaskPhotosUseCase(
      id: taskId,
      photos: urls,
      startTime: startTime,
      endTime: endTime,
    );

    result.fold(
      (failure) {
        DebugLogger.error(
          'TASK',
          'Photo submission failed: ${failure.message}',
        );
        emit(
          state.copyWith(
            isUploadingPhotos: false,
            photoUploadError: failure.message,
          ),
        );
      },
      (_) {
        DebugLogger.log(
          '✅',
          'TASK',
          'Photos submitted successfully for task: $taskId',
        );
        emit(state.copyWith(isUploadingPhotos: false));
      },
    );
  }

  /// Submit photos when there are no photos to upload (skipped UI flow).
  /// Returns true on success, false on failure.
  Future<bool> submitPhotosSkippingUI({int? startTime, int? endTime}) async {
    final taskId = state.activeTaskId;
    if (taskId == null) {
      DebugLogger.error('TASK', 'submitPhotosSkippingUI with no activeTaskId');
      return false;
    }

    final start =
        startTime ??
        state.taskStartTimeEpoch ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final end =
        endTime ??
        state.taskEndTimeEpoch ??
        DateTime.now().millisecondsSinceEpoch ~/ 1000;

    DebugLogger.log(
      '📤',
      'TASK',
      'Submitting empty photos payload — id: $taskId, startTime: $start, endTime: $end',
    );

    emit(state.copyWith(isUploadingPhotos: true, clearPhotoUploadError: true));

    final result = await _uploadTaskPhotosUseCase(
      id: taskId,
      photos: const [],
      startTime: start,
      endTime: end,
    );

    return result.fold(
      (failure) {
        DebugLogger.error(
          'TASK',
          'Photo submission (skipped) failed: ${failure.message}',
        );
        emit(
          state.copyWith(
            isUploadingPhotos: false,
            photoUploadError: failure.message,
          ),
        );
        return false;
      },
      (_) {
        DebugLogger.log(
          '✅',
          'TASK',
          'Empty photo payload submitted successfully for task: $taskId',
        );
        emit(state.copyWith(isUploadingPhotos: false));
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    final taskId = state.activeTaskId;
    if (taskId == null) {
      DebugLogger.error('TASK', 'verifyOtp called with no activeTaskId');
      emit(state.copyWith(otpError: 'No active task to complete.'));
      return false;
    }

    emit(state.copyWith(isCompletingTask: true, clearOtpError: true));

    final result = await _completeTaskUseCase(id: taskId, otp: otp);

    return result.fold(
      (failure) {
        DebugLogger.error('TASK', 'Task completion failed: ${failure.message}');
        emit(
          state.copyWith(isCompletingTask: false, otpError: failure.message),
        );
        return false;
      },
      (_) {
        DebugLogger.log('✅', 'TASK', 'Task completed — id: $taskId');
        _completeActiveTask();
        return true;
      },
    );
  }

  void clearOtpError() {
    emit(state.copyWith(clearOtpError: true));
  }

  void _completeActiveTask() {
    if (state.activeTaskId == null) return;
    final updated = state.tasks.map((t) {
      if (t.id == state.activeTaskId) {
        return t.copyWith(status: TaskStatus.completed);
      }
      return t;
    }).toList();

    emit(
      state.copyWith(
        tasks: updated,
        clearActiveTask: true,
        isTimerRunning: false,
        remainingSeconds: 0,
        isOvertime: false,
        overtimeSeconds: 0,
        clearCloudinaryUrls: true,
        isCompletingTask: false,
        taskCompleted: true,
      ),
    );
  }

  void resetTaskCompletion() {
    emit(state.copyWith(taskCompleted: false));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
