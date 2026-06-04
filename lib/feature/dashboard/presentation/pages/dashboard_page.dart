import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/di/service_locator.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/presentation/cubit/leave_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/presentation/pages/leave_page.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/history/pages/history_page.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_list_page.dart';
import 'package:hireanythingbooking/feature/add_task/presentation/pages/add_task_page.dart';
import 'package:hireanythingbooking/feature/add_task/presentation/cubit/add_task_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TaskCubit>()),
        BlocProvider(create: (_) => getIt<AddTaskCubit>()),
        BlocProvider(create: (_) => getIt<LeaveCubit>()),
      ],
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            body: IndexedStack(
              index: state.selectedIndex,
              children: const [
                TaskListPage(),
                LeavePage(),
                AddTaskPage(),
                HistoryPage(),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(10),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: BottomNavigationBar(
                  currentIndex: state.selectedIndex,
                  onTap: context.read<DashboardCubit>().changeTab,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: AppColors.white,
                  elevation: 0,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.grey500,
                  selectedLabelStyle: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(
                        AppIcons.task,
                        false,
                        state.selectedIndex == 0,
                      ),
                      activeIcon: _buildNavIcon(AppIcons.task, true, true),
                      label: AppStrings.tasks,
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(
                        AppIcons.leave,
                        false,
                        state.selectedIndex == 1,
                      ),
                      activeIcon: _buildNavIcon(AppIcons.leave, true, true),
                      label: AppStrings.leaves,
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(
                        AppIcons.add,
                        false,
                        state.selectedIndex == 2,
                      ),
                      activeIcon: _buildNavIcon(AppIcons.add, true, true),
                      label: AppStrings.addTask,
                    ),
                    BottomNavigationBarItem(
                      icon: _buildNavIcon(
                        AppIcons.history,
                        false,
                        state.selectedIndex == 3,
                      ),
                      activeIcon: _buildNavIcon(AppIcons.history, true, true),
                      label: AppStrings.history,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, bool isActive, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withAlpha(20)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 22,
        color: isSelected ? AppColors.primary : AppColors.grey500,
      ),
    );
  }
}
