import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hireanythingbooking/core/di/service_locator.dart';
import 'package:hireanythingbooking/core/routes/routes.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/storage/secure_token_storage.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  late AnimationController controller;
  late Animation<double> animation;

  Future<void> redirect(BuildContext context) async {
    if (!context.mounted) return;

    final secureTokenStorage = getIt<SecureTokenStorage>();
    final hasTokens = await secureTokenStorage.hasTokens();

    DebugLogger.auth('Splash token check — hasTokens: $hasTokens');

    if (hasTokens) {
      // Retrieve and log tokens when they exist
      final accessToken = await secureTokenStorage.getAccessToken();
      final refreshToken = await secureTokenStorage.getRefreshToken();
      DebugLogger.storage(
        'Tokens from splash: access=$accessToken, refresh=$refreshToken',
      );
    }

    if (!context.mounted) return;

    if (hasTokens) {
      DebugLogger.auth('Token found — navigating to dashboard');
      context.pushReplacement(AppRoutes.dashboard);
    } else {
      DebugLogger.auth('No token — navigating to login');
      context.pushReplacement(AppRoutes.login);
    }
  }
}
