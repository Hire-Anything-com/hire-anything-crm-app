import 'package:hireanythingbooking/core/di/di.dart';
import 'package:hireanythingbooking/feature/login/domain/entities/login_entity.dart';

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

    // ============ Add Task Feature ============
    DebugLogger.core('Setting up Add Task feature dependencies');
    _setupAddTaskFeature();

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

          // Determine whether refresh succeeded
          final refreshed = result.fold((failure) {
            DebugLogger.error(
              'AUTH',
              'Token refresh failed: ${failure.message}',
            );
            return false;
          }, (token) => true);

          // If refresh failed, perform logout (clears tokens) and navigate
          if (!refreshed) {
            try {
              final logoutUseCase = getIt<LogoutUseCase>();
              await logoutUseCase();
            } on Exception catch (e) {
              DebugLogger.error(
                'AUTH',
                'Logout during refresh-failure failed: $e',
              );
            }

            try {
              AppRouter.router.go(AppRoutes.login);
            } on Exception catch (e) {
              DebugLogger.error('AUTH', 'Navigation to login failed: $e');
            }
          }

          return refreshed;
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
    getIt
      ..registerSingleton<LoginRemoteDataSource>(LoginRemoteDataSourceImpl(dio))
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
      ..registerSingleton<LoginUseCase>(LoginUseCase(getIt<LoginRepository>()))
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

    // Load cached user profile and tokens (if present) into LoginCubit
    try {
      final profile = await secureTokenStorage.getUserProfile();
      final access = await secureTokenStorage.getAccessToken();
      final refresh = await secureTokenStorage.getRefreshToken();

      if (profile != null && access != null && refresh != null) {
        final user = UserEntity(
          id: profile['id'] as String,
          email: profile['email'] as String,
          name: profile['name'] as String,
          role: profile['role'] as String,
          businessId: profile['businessId'] as String?,
        );

        final loginResponse = LoginResponseEntity(
          user: user,
          accessToken: access,
          refreshToken: refresh,
          message: profile['message'] as String? ?? 'Cached login',
        );

        getIt<LoginCubit>().loadCachedLogin(loginResponse);
        DebugLogger.core('Loaded cached login into LoginCubit');
      }
    } on Exception catch (e) {
      DebugLogger.error('DI', 'Failed to load cached login: $e');
    }
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
    getIt
      ..registerSingleton<ForgotPasswordRemoteDataSource>(
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
    getIt
      ..registerSingleton<TaskRemoteDataSource>(TaskRemoteDataSourceImpl(dio))
      // Repository
      ..registerSingleton<TaskRepository>(
        TaskRepositoryImpl(remoteDataSource: getIt<TaskRemoteDataSource>()),
      )
      // Use Cases
      ..registerSingleton<GetMyAssignmentsUseCase>(
        GetMyAssignmentsUseCase(getIt<TaskRepository>()),
      )
      ..registerSingleton<GetAssignmentDetailsUseCase>(
        GetAssignmentDetailsUseCase(getIt<TaskRepository>()),
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
          getAssignmentDetailsUseCase: getIt<GetAssignmentDetailsUseCase>(),
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
    getIt
      ..registerSingleton<LeaveRemoteDataSource>(LeaveRemoteDataSourceImpl(dio))
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

  /// Sets up add task feature dependencies
  static void _setupAddTaskFeature() {
    final dio = getIt<Dio>();

    // Remote Data Source
    getIt
      ..registerSingleton<AddTaskRemoteDataSource>(
        AddTaskRemoteDataSourceImpl(dio),
      )
      // Repository
      ..registerSingleton<AddTaskRepository>(
        AddTaskRepositoryImpl(
          remoteDataSource: getIt<AddTaskRemoteDataSource>(),
        ),
      )
      // Use Case
      ..registerSingleton<GetMyServicesUseCase>(
        GetMyServicesUseCase(getIt<AddTaskRepository>()),
      )
      ..registerSingleton<CreateTaskUseCase>(
        CreateTaskUseCase(getIt<AddTaskRepository>()),
      )
      // Cubit
      ..registerFactory<AddTaskCubit>(
        () => AddTaskCubit(
          getMyServicesUseCase: getIt<GetMyServicesUseCase>(),
          createTaskUseCase: getIt<CreateTaskUseCase>(),
        ),
      );
  }
}
