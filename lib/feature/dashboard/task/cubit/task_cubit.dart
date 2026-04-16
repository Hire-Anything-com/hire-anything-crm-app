import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/task/model/task_model.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(const TaskState()) {
    _loadDummyTasks();
  }

  Timer? _timer;
  static const _dummyOtp = '111111';

  void _loadDummyTasks() {
    final now = DateTime.now();
    final tasks = [
      TaskModel(
        id: '1',
        title: 'Haircut - Men\'s Classic',
        description: 'Regular men\'s haircut with beard trim and styling.',
        customerName: 'Ahmed Khan',
        location: '123 Main Street, Block A',
        scheduledAt: now.add(const Duration(minutes: 30)),
        durationMinutes: 45,
      ),
      TaskModel(
        id: '2',
        title: 'Hair Coloring',
        description: 'Full hair coloring with premium dye and treatment.',
        customerName: 'Sara Ali',
        location: '456 Park Avenue, Suite 2B',
        scheduledAt: now.add(const Duration(hours: 2)),
        durationMinutes: 90,
      ),
      TaskModel(
        id: '3',
        title: 'Bridal Makeup',
        description: 'Complete bridal makeup with hairstyling package.',
        customerName: 'Fatima Noor',
        location: '789 Garden Road, House 5',
        scheduledAt: now.add(const Duration(hours: 4)),
        durationMinutes: 120,
      ),
      TaskModel(
        id: '4',
        title: 'Facial Treatment',
        description: 'Deep cleansing facial with hydration therapy.',
        customerName: 'Usman Raza',
        location: '321 Lake View, Apt 3C',
        scheduledAt: now.add(const Duration(hours: 1)),
        durationMinutes: 60,
      ),
      TaskModel(
        id: '5',
        title: 'Kids Haircut',
        description: 'Fun kids haircut with wash and style.',
        customerName: 'Hina Malik',
        location: '654 Sunset Blvd, Floor 2',
        scheduledAt: now.add(const Duration(minutes: 15)),
        durationMinutes: 30,
      ),
    ];

    emit(state.copyWith(tasks: tasks));
  }

  void acceptTask(String taskId) {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(status: TaskStatus.accepted);
      return t;
    }).toList();
    emit(state.copyWith(tasks: updated));
  }

  void rejectTask(String taskId) {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(status: TaskStatus.rejected);
      return t;
    }).toList();
    emit(state.copyWith(tasks: updated));
  }

  /// Returns true if task is being started before scheduled time.
  bool isStartingEarly(String taskId) {
    final task = state.tasks.firstWhere((t) => t.id == taskId);
    return DateTime.now().isBefore(task.scheduledAt);
  }

  void startTask(String taskId) {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) return t.copyWith(status: TaskStatus.inProgress);
      return t;
    }).toList();

    final task = updated.firstWhere((t) => t.id == taskId);
    final totalSeconds = task.durationMinutes * 60;

    emit(
      state.copyWith(
        tasks: updated,
        activeTaskId: taskId,
        remainingSeconds: totalSeconds,
        isTimerRunning: true,
        clearPhotos: true,
        clearOtpError: true,
        taskCompleted: false,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        emit(state.copyWith(remainingSeconds: 0, isTimerRunning: false));
      } else {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    emit(state.copyWith(isTimerRunning: false));
  }

  void addPhoto(String path) {
    if (state.photoPaths.length >= 3) return;
    emit(state.copyWith(photoPaths: [...state.photoPaths, path]));
  }

  void removePhoto(int index) {
    final updated = List<String>.from(state.photoPaths)..removeAt(index);
    emit(state.copyWith(photoPaths: updated));
  }

  bool verifyOtp(String otp) {
    if (otp == _dummyOtp) {
      _completeActiveTask();
      return true;
    }
    emit(state.copyWith(otpError: 'Incorrect OTP. Please try again.'));
    return false;
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
