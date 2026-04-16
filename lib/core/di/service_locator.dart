import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/network/dio_client.dart';
import 'package:hireanythingbooking/core/utils/network/interceptors/auth_interceptor.dart';
import 'package:hireanythingbooking/core/utils/storage/secure_token_storage.dart';
import 'package:hireanythingbooking/feature/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import 'package:hireanythingbooking/feature/forgot_password/data/repositories/forgot_password_repository_impl.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/usecases/forgot_password_usecase.dart';
import 'package:hireanythingbooking/feature/login/presentation/presentation.dart';
import 'package:hireanythingbooking/feature/login/data/datasources/login_local_datasource.dart';
import 'package:hireanythingbooking/feature/login/data/datasources/login_remote_datasource.dart';
import 'package:hireanythingbooking/feature/login/data/repositories/login_repository_impl.dart';
import 'package:hireanythingbooking/feature/login/domain/repositories/login_repository.dart';
import 'package:hireanythingbooking/feature/login/domain/usecases/login_usecase.dart';

final getIt = GetIt.instance;

/// Service locator for dependency injection
class ServiceLocator {
  /// Initializes all dependencies for the application
  static Future<void> setupServiceLocator({required String baseUrl}) async {
    DebugLogger.core('Setting up ServiceLocator with baseUrl: $baseUrl');
    // ============ Core ============

    // Storage
    final secureTokenStorage = SecureTokenStorage();
    getIt.registerSingleton<SecureTokenStorage>(secureTokenStorage);
    DebugLogger.core('SecureTokenStorage registered');

    // Network - Setup Dio first without interceptor callback
    final dio = Dio()
      ..options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (status) => true,
      );

    getIt.registerSingleton<Dio>(dio);
    DebugLogger.core('Dio client registered');

    // ============ Login Feature ============
    DebugLogger.core('Setting up Login feature dependencies');
    await _setupLoginFeature();

    // ============ Forgot Password Feature ============
    DebugLogger.core('Setting up Forgot Password feature dependencies');
    _setupForgotPasswordFeature();

    // ============ Setup Auth Interceptor (after repository is registered) ============
    DebugLogger.core('Registering AuthInterceptor');
    dio.interceptors.add(
      AuthInterceptor(
        getAccessToken: () async => await secureTokenStorage.getAccessToken(),
        onTokenRefresh: () async {
          final loginRepository = getIt<LoginRepository>();
          final result = await loginRepository.refreshAccessToken();
          return result.fold((failure) => false, (token) => true);
        },
      ),
    );
    DebugLogger.core('ServiceLocator setup complete ✅');
  }

  /// Sets up login feature dependencies
  static Future<void> _setupLoginFeature() async {
    final dio = getIt<Dio>();
    final secureTokenStorage = getIt<SecureTokenStorage>();

    // Remote Data Source
    getIt.registerSingleton<LoginRemoteDataSource>(
      LoginRemoteDataSourceImpl(dio),
    );

    // Local Data Source
    getIt.registerSingleton<LoginLocalDataSource>(
      LoginLocalDataSourceImpl(secureTokenStorage),
    );

    // Repository
    getIt.registerSingleton<LoginRepository>(
      LoginRepositoryImpl(
        remoteDataSource: getIt<LoginRemoteDataSource>(),
        localDataSource: getIt<LoginLocalDataSource>(),
      ),
    );

    // Use Cases
    getIt.registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<LoginRepository>()),
    );
    getIt.registerSingleton<RefreshTokenUseCase>(
      RefreshTokenUseCase(getIt<LoginRepository>()),
    );
    getIt.registerSingleton<LogoutUseCase>(
      LogoutUseCase(getIt<LoginRepository>()),
    );

    // Cubit
    getIt.registerSingleton<LoginCubit>(
      LoginCubit(
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
      ),
    );
  }

  /// Clears all registered dependencies (useful for testing)
  static Future<void> reset() async {
    await getIt.reset();
  }

  /// Sets up forgot password feature dependencies
  static void _setupForgotPasswordFeature() {
    // Use a plain Dio without AuthInterceptor — these endpoints are public
    final plainDio = Dio()
      ..options = BaseOptions(
        baseUrl: getIt<Dio>().options.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        validateStatus: (status) => true,
      );

    // Remote Data Source
    getIt.registerSingleton<ForgotPasswordRemoteDataSource>(
      ForgotPasswordRemoteDataSourceImpl(plainDio),
    );

    // Repository
    getIt.registerSingleton<ForgotPasswordRepository>(
      ForgotPasswordRepositoryImpl(
        remoteDataSource: getIt<ForgotPasswordRemoteDataSource>(),
      ),
    );

    // Use Cases
    getIt.registerSingleton<ForgotPasswordUseCase>(
      ForgotPasswordUseCase(getIt<ForgotPasswordRepository>()),
    );
    getIt.registerSingleton<ResetPasswordUseCase>(
      ResetPasswordUseCase(getIt<ForgotPasswordRepository>()),
    );
  }
}
