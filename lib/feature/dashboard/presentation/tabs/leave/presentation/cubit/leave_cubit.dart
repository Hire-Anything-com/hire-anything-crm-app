import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/model/leave_model.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/usecases/apply_leave_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/usecases/get_my_leaves_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/presentation/cubit/leave_state.dart';

class LeaveCubit extends Cubit<LeaveState> {
  LeaveCubit({
    required ApplyLeaveUseCase applyLeaveUseCase,
    required GetMyLeavesUseCase getMyLeavesUseCase,
  }) : _applyLeaveUseCase = applyLeaveUseCase,
       _getMyLeavesUseCase = getMyLeavesUseCase,
       super(const LeaveState());

  final ApplyLeaveUseCase _applyLeaveUseCase;
  final GetMyLeavesUseCase _getMyLeavesUseCase;

  Future<void> fetchMyLeaves() async {
    emit(state.copyWith(isLoading: true, submitError: ''));

    final result = await _getMyLeavesUseCase();

    result.fold(
      (failure) {
        DebugLogger.error('CUBIT', 'Fetch leaves failed: ${failure.message}');
        emit(state.copyWith(isLoading: false, submitError: failure.message));
      },
      (leaves) {
        DebugLogger.log('📋', 'CUBIT', 'Fetched ${leaves.length} leaves');
        emit(state.copyWith(leaves: leaves, isLoading: false, submitError: ''));
      },
    );
  }

  void selectDay(DateTime day) {
    emit(state.copyWith(selectedDay: day, focusedDay: day));
  }

  void changeFocusedDay(DateTime day) {
    emit(state.copyWith(focusedDay: day));
  }

  Future<void> applyLeave({
    required List<DateTime> dates,
    required LeaveType type,
    required String reason,
  }) async {
    emit(state.copyWith(isSubmitting: true, submitError: ''));

    final startDate = dates.first;
    final endDate = dates.last;
    final startEpoch = startDate.millisecondsSinceEpoch ~/ 1000;
    // API requires endDate > startDate; for single day, use end-of-day
    final endEpoch = dates.length == 1
        ? startEpoch + 86399
        : endDate.millisecondsSinceEpoch ~/ 1000;
    final typeString = _leaveTypeToString(type);

    DebugLogger.log(
      '📋',
      'CUBIT',
      'applyLeave — type: $typeString, '
          'startDate: $startEpoch, endDate: $endEpoch',
    );

    final result = await _applyLeaveUseCase(
      type: typeString,
      startDate: startEpoch,
      endDate: endEpoch,
      reason: reason,
    );

    result.fold(
      (failure) {
        DebugLogger.error('CUBIT', 'Apply leave failed: ${failure.message}');
        emit(state.copyWith(isSubmitting: false, submitError: failure.message));
      },
      (_) {
        DebugLogger.log('📋', 'CUBIT', 'Leave applied successfully');
        emit(state.copyWith(isSubmitting: false, submitError: ''));
        // Refresh leaves list from server
        fetchMyLeaves();
      },
    );
  }

  void cancelLeave(String id) {
    final updated = state.leaves.where((l) => l.id != id).toList();
    emit(state.copyWith(leaves: updated));
  }

  String _leaveTypeToString(LeaveType type) {
    return switch (type) {
      LeaveType.casual => 'CASUAL',
      LeaveType.sick => 'SICK',
      LeaveType.annual => 'ANNUAL',
    };
  }
}
