import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hireanythingbooking/core/di/service_locator.dart';
import 'package:hireanythingbooking/core/routes/route_observer.dart';
import 'package:hireanythingbooking/core/routes/routes.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/usecases/forgot_password_usecase.dart';
import 'package:hireanythingbooking/feature/forgot_password/presentation/presentation.dart';
import 'package:hireanythingbooking/feature/login/presentation/presentation.dart';
import 'package:hireanythingbooking/feature/splash/cubit/splash_cubit.dart';
import 'package:hireanythingbooking/feature/splash/pages/splash_page.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final AppRouteObserver routeObserver = AppRouteObserver();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    observers: [routeObserver],
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => BlocProvider(
          create: (_) => SplashCubit(),
          child: const SplashPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => BlocProvider<LoginCubit>.value(
          value: getIt<LoginCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordEmail,
        name: AppRoutes.resetPasswordEmail,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => ResetPasswordEmailCubit(
              forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
            ),
            child: const ResetPasswordEmailPage(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1, 0);
            const end = Offset.zero;
            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRoutes.forgotPassword,
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => ForgotPasswordCubit(
                forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
                resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
                email: email,
              ),
              child: const ForgotPasswordPage(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1, 0);
                  const end = Offset.zero;
                  final tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: Curves.easeInOut));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            transitionDuration: const Duration(milliseconds: 400),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: AppRoutes.dashboard,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: BlocProvider<LoginCubit>.value(
            value: getIt<LoginCubit>(),
            child: BlocProvider(
              create: (_) => DashboardCubit(),
              child: const DashboardPage(),
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: AppRoutes.history,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('History'))),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.profile,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Profile'))),
      ),
    ],
  );
}

