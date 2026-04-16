import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

enum SnackBarType { success, error, info, warning }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final (color, icon) = switch (type) {
      SnackBarType.success => (AppColors.success, Icons.check_circle_rounded),
      SnackBarType.error => (AppColors.error, Icons.error_rounded),
      SnackBarType.warning => (AppColors.warning, Icons.warning_rounded),
      SnackBarType.info => (AppColors.info, Icons.info_rounded),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: AppColors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: duration,
        ),
      );
  }
}
