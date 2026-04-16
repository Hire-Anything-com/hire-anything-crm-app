import 'package:hireanythingbooking/core/enums/enums.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String resetPasswordEmail = '/reset-password-email';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String profile = '/profile';

  static String getRoute(Pages page) {
    switch (page) {
      case Pages.splash:
        return splash;
      case Pages.login:
        return login;
      case Pages.resetPasswordEmail:
        return resetPasswordEmail;
      case Pages.forgotPassword:
        return forgotPassword;
      case Pages.dashboard:
        return dashboard;
      case Pages.history:
        return history;
      case Pages.profile:
        return profile;
    }
  }
}
