class AppConstants {
  AppConstants._();

  static const String appName = 'Hire Anything Booking';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API
  static const String baseUrl = 'https://crm-api.hireanything.com';
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String refreshTokenEndpoint = '/api/v1/auth/refresh';
  static const String logoutEndpoint = '/api/v1/auth/logout';
  static const String forgotPasswordEndpoint = '/api/v1/auth/forgot-password';
  static const String resetPasswordEndpoint = '/api/v1/auth/reset-password';

  // Dummy credentials (mutable password for forgot password flow)
  static const String dummyEmail = 'khanfeshan2324@gmail.com';
  static String dummyPassword = 'Test@123';
  static const String dummyOtp = '111111';
  static const int otpLength = 6;
}
