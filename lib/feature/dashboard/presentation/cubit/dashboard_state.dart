import 'package:equatable/equatable.dart';

class DashboardState extends Equatable {
  const DashboardState({this.selectedIndex = 0});
  final int selectedIndex;

  DashboardState copyWith({int? selectedIndex}) {
    return DashboardState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }

  @override
  List<Object?> get props => [selectedIndex];
}
