import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';

class LeaveState extends Equatable {
  const LeaveState({
    this.leaves = const [],
    this.selectedDay,
    this.focusedDay,
    this.isLoading = false,
    this.isSubmitting = false,
    this.submitError = '',
  });

  final List<LeaveModel> leaves;
  final DateTime? selectedDay;
  final DateTime? focusedDay;
  final bool isLoading;
  final bool isSubmitting;
  final String submitError;

  DateTime get currentFocusedDay => focusedDay ?? DateTime.now();

  List<LeaveModel> get upcomingLeaves {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return leaves.where((l) => !l.endDateTime.isBefore(today)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  List<LeaveModel> get pastLeaves {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return leaves.where((l) => l.endDateTime.isBefore(today)).toList()
      ..sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
  }

  List<LeaveModel> leavesForDay(DateTime day) {
    return leaves.where((l) => l.coversDay(day)).toList();
  }

  bool hasLeaveOnDay(DateTime day) => leavesForDay(day).isNotEmpty;

  LeaveState copyWith({
    List<LeaveModel>? leaves,
    DateTime? selectedDay,
    DateTime? focusedDay,
    bool clearSelectedDay = false,
    bool? isLoading,
    bool? isSubmitting,
    String? submitError,
  }) {
    return LeaveState(
      leaves: leaves ?? this.leaves,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      focusedDay: focusedDay ?? this.focusedDay,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError ?? this.submitError,
    );
  }

  @override
  List<Object?> get props => [
    leaves,
    selectedDay,
    focusedDay,
    isLoading,
    isSubmitting,
    submitError,
  ];
}
