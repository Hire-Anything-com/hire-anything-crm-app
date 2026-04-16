import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/feature/dashboard/leave/cubit/leave_state.dart';
import 'package:hireanythingbooking/feature/dashboard/leave/model/leave_model.dart';

class LeaveCubit extends Cubit<LeaveState> {
  LeaveCubit() : super(const LeaveState());

  int _nextId = 1;

  void selectDay(DateTime day) {
    emit(state.copyWith(selectedDay: day, focusedDay: day));
  }

  void changeFocusedDay(DateTime day) {
    emit(state.copyWith(focusedDay: day));
  }

  void applyLeave({
    required List<DateTime> dates,
    required LeaveType type,
    required String reason,
  }) {
    final newLeaves = dates.map((date) {
      return LeaveModel(
        id: '${_nextId++}',
        date: DateTime(date.year, date.month, date.day),
        type: type,
        reason: reason,
      );
    }).toList();
    emit(state.copyWith(leaves: [...state.leaves, ...newLeaves]));
  }

  void cancelLeave(String id) {
    final updated = state.leaves.where((l) => l.id != id).toList();
    emit(state.copyWith(leaves: updated));
  }
}
