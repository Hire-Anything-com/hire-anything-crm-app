import 'package:equatable/equatable.dart';
import 'package:hireanythingbooking/feature/dashboard/leave/model/leave_model.dart';

class LeaveState extends Equatable {
  const LeaveState({this.leaves = const [], this.selectedDay, this.focusedDay});

  final List<LeaveModel> leaves;
  final DateTime? selectedDay;
  final DateTime? focusedDay;

  DateTime get currentFocusedDay => focusedDay ?? DateTime.now();

  List<LeaveModel> get upcomingLeaves {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return leaves.where((l) => !l.date.isBefore(today)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<LeaveModel> get pastLeaves {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return leaves.where((l) => l.date.isBefore(today)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  List<LeaveModel> leavesForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return leaves
        .where(
          (l) =>
              l.date.year == normalized.year &&
              l.date.month == normalized.month &&
              l.date.day == normalized.day,
        )
        .toList();
  }

  bool hasLeaveOnDay(DateTime day) => leavesForDay(day).isNotEmpty;

  LeaveState copyWith({
    List<LeaveModel>? leaves,
    DateTime? selectedDay,
    DateTime? focusedDay,
    bool clearSelectedDay = false,
  }) {
    return LeaveState(
      leaves: leaves ?? this.leaves,
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      focusedDay: focusedDay ?? this.focusedDay,
    );
  }

  @override
  List<Object?> get props => [leaves, selectedDay, focusedDay];
}
