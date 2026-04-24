import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';
import 'package:hireanythingbooking/core/utils/network/interceptors/auth_interceptor.dart';
import 'package:hireanythingbooking/core/utils/storage/secure_token_storage.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/datasources/leave_remote_datasource.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/data/repositories/leave_repository_impl.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/repositories/leave_repository.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/usecases/apply_leave_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/domain/usecases/get_my_leaves_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/leave/presentation/cubit/leave_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/datasources/task_remote_datasource.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/data/repositories/task_repository_impl.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/repositories/task_repository.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/complete_task_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/get_my_assignments_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/respond_to_assignment_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/domain/usecases/upload_task_photos_usecase.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/forgot_password/data/datasources/forgot_password_remote_datasource.dart';
import 'package:hireanythingbooking/feature/forgot_password/data/repositories/forgot_password_repository_impl.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/repositories/forgot_password_repository.dart';
import 'package:hireanythingbooking/feature/forgot_password/domain/usecases/forgot_password_usecase.dart';
import 'package:hireanythingbooking/feature/login/data/datasources/login_local_datasource.dart';
import 'package:hireanythingbooking/feature/login/data/datasources/login_remote_datasource.dart';
import 'package:hireanythingbooking/feature/login/data/repositories/login_repository_impl.dart';
import 'package:hireanythingbooking/feature/login/domain/repositories/login_repository.dart';
import 'package:hireanythingbooking/feature/login/domain/usecases/login_usecase.dart';
import 'package:hireanythingbooking/feature/login/presentation/presentation.dart';

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

    // ============ Task Feature ============
    DebugLogger.core('Setting up Task feature dependencies');
    _setupTaskFeature();

    // ============ Leave Feature ============
    DebugLogger.core('Setting up Leave feature dependencies');
    _setupLeaveFeature();

    // ============ Setup Auth Interceptor (after repository is registered) ====
    DebugLogger.core('Registering AuthInterceptor');
    dio.interceptors.add(
      AuthInterceptor(
        getAccessToken: () async => secureTokenStorage.getAccessToken(),
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
    getIt..registerSingleton<LoginRemoteDataSource>(
      LoginRemoteDataSourceImpl(dio),
    )

    // Local Data Source
    ..registerSingleton<LoginLocalDataSource>(
      LoginLocalDataSourceImpl(secureTokenStorage),
    )

    // Repository
    ..registerSingleton<LoginRepository>(
      LoginRepositoryImpl(
        remoteDataSource: getIt<LoginRemoteDataSource>(),
        localDataSource: getIt<LoginLocalDataSource>(),
      ),
    )

    // Use Cases
    ..registerSingleton<LoginUseCase>(
      LoginUseCase(getIt<LoginRepository>()),
    )
    ..registerSingleton<RefreshTokenUseCase>(
      RefreshTokenUseCase(getIt<LoginRepository>()),
    )
    ..registerSingleton<LogoutUseCase>(
      LogoutUseCase(getIt<LoginRepository>()),
    )

    // Cubit
    ..registerSingleton<LoginCubit>(
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
        validateStatus: (status) => true,
      );

    // Remote Data Source
    getIt..registerSingleton<ForgotPasswordRemoteDataSource>(
      ForgotPasswordRemoteDataSourceImpl(plainDio),
    )

    // Repository
    ..registerSingleton<ForgotPasswordRepository>(
      ForgotPasswordRepositoryImpl(
        remoteDataSource: getIt<ForgotPasswordRemoteDataSource>(),
      ),
    )

    // Use Cases
    ..registerSingleton<ForgotPasswordUseCase>(
      ForgotPasswordUseCase(getIt<ForgotPasswordRepository>()),
    )
    ..registerSingleton<ResetPasswordUseCase>(
      ResetPasswordUseCase(getIt<ForgotPasswordRepository>()),
    );
  }

  /// Sets up task feature dependencies
  static void _setupTaskFeature() {
    final dio = getIt<Dio>();

    // Remote Data Source
    getIt..registerSingleton<TaskRemoteDataSource>(
      TaskRemoteDataSourceImpl(dio),
    )

    // Repository
    ..registerSingleton<TaskRepository>(
      TaskRepositoryImpl(remoteDataSource: getIt<TaskRemoteDataSource>()),
    )

    // Use Cases
    ..registerSingleton<GetMyAssignmentsUseCase>(
      GetMyAssignmentsUseCase(getIt<TaskRepository>()),
    )
    ..registerSingleton<RespondToAssignmentUseCase>(
      RespondToAssignmentUseCase(getIt<TaskRepository>()),
    )
    ..registerSingleton<UploadTaskPhotosUseCase>(
      UploadTaskPhotosUseCase(getIt<TaskRepository>()),
    )
    ..registerSingleton<CompleteTaskUseCase>(
      CompleteTaskUseCase(getIt<TaskRepository>()),
    )

    // Cubit
    ..registerFactory<TaskCubit>(
      () => TaskCubit(
        getMyAssignmentsUseCase: getIt<GetMyAssignmentsUseCase>(),
        respondToAssignmentUseCase: getIt<RespondToAssignmentUseCase>(),
        uploadTaskPhotosUseCase: getIt<UploadTaskPhotosUseCase>(),
        completeTaskUseCase: getIt<CompleteTaskUseCase>(),
      ),
    );
  }

  /// Sets up leave feature dependencies
  static void _setupLeaveFeature() {
    final dio = getIt<Dio>();

    // Remote Data Source
    getIt..registerSingleton<LeaveRemoteDataSource>(
      LeaveRemoteDataSourceImpl(dio),
    )

    // Repository
    ..registerSingleton<LeaveRepository>(
      LeaveRepositoryImpl(remoteDataSource: getIt<LeaveRemoteDataSource>()),
    )

    // Use Cases
    ..registerSingleton<ApplyLeaveUseCase>(
      ApplyLeaveUseCase(getIt<LeaveRepository>()),
    )
    ..registerSingleton<GetMyLeavesUseCase>(
      GetMyLeavesUseCase(getIt<LeaveRepository>()),
    )

    // Cubit
    ..registerFactory<LeaveCubit>(
      () => LeaveCubit(
        applyLeaveUseCase: getIt<ApplyLeaveUseCase>(),
        getMyLeavesUseCase: getIt<GetMyLeavesUseCase>(),
      ),
    );
  }
}
