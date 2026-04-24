# Project Guidelines

## Architecture

Clean Architecture with feature-first folder structure:

```
lib/
  core/           → Shared: DI, routing, theme, constants, utils, errors
  feature/
    <name>/
      data/       → Models, DataSources (remote/local), RepositoryImpl
      domain/     → Entities, abstract Repositories, UseCases
      presentation/ → Cubits, States, Pages, Widgets
```

Sub-features (e.g. dashboard tabs `task/`, `leave/`) nest full `data/domain/presentation` layers inside `presentation/tabs/`.

## Build and Test

```bash
# Install dependencies
flutter pub get

# Code generation (models with json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Analyze
flutter analyze

# Run tests
flutter test

# Generate launcher icons
dart run flutter_launcher_icons
```

## Conventions

### Naming

| Element           | Convention                           | Example                                           |
| ----------------- | ------------------------------------ | ------------------------------------------------- |
| Files             | `snake_case`                         | `login_cubit.dart`                                |
| Abstractions      | No `I` prefix                        | `LoginRepository`                                 |
| Implementations   | `*Impl` suffix                       | `LoginRepositoryImpl`                             |
| Entities          | `*Entity` suffix, extend `Equatable` | `UserEntity`                                      |
| Models            | `*Model` suffix, extend Entity       | `UserModel extends UserEntity`                    |
| Use cases         | `*UseCase` suffix                    | `LoginUseCase`                                    |
| Constants classes | `App*` prefix, private constructor   | `AppColors._()`                                   |
| Shared widgets    | `App*` prefix                        | `AppButton`, `AppTextField`                       |
| Extensions        | `*Ext` class in `*_ext.dart`         | `ContextExt` in `context_ext.dart`                |
| State files       | `part of` cubit file                 | `login_state.dart` → `part of 'login_cubit.dart'` |

### Barrel Exports

Every layer folder has a barrel file matching its name (`data.dart`, `domain.dart`, `presentation.dart`, `core.dart`). Use these for imports.

### State Management — Cubit Only

- Use **Cubit** (not Bloc with events) via `flutter_bloc`
- States use `Equatable` with `copyWith` pattern, defined as `part` files
- Cubits own form controllers (`TextEditingController`, `FocusNode`, `GlobalKey<FormState>`)
- Navigation is performed inside cubits via `BuildContext`

### Dependency Injection

- `get_it` service locator in [lib/core/di/service_locator.dart](lib/core/di/service_locator.dart)
- Registration order: Storage → Dio → DataSources → Repositories → UseCases → Cubits
- **AuthInterceptor must be added AFTER repository registration**
- Singleton cubits use `BlocProvider.value(value: getIt<XCubit>())`; factory cubits use `BlocProvider(create: (_) => getIt<XCubit>())`

### Error Handling

`DioException` → `ServerException` (in DataSource) → `Failure` (in Repository) → `Either<Failure, T>` (dartz) → Cubit folds and emits state

### Routing

`go_router` with route constants in [lib/core/routes/routes.dart](lib/core/routes/routes.dart). Use `context.pushReplacement()` for auth flows.

## Code Style

- Linting: `very_good_analysis` (v7.0.0) — strict rules, `public_member_api_docs` disabled
- Fonts: Google Fonts Poppins via [lib/core/theme/app_typography.dart](lib/core/theme/app_typography.dart)
- Icons: `hugeicons` package, constants in [lib/core/constants/app_icons.dart](lib/core/constants/app_icons.dart)
- Colors: [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart)
- Spacing: Pre-built `EdgeInsets`/`SizedBox` in [lib/core/constants/app_spacing.dart](lib/core/constants/app_spacing.dart) — use `AppSpacing.p8`, `AppSpacing.h16`, etc.
- Strings: Centralized in [lib/core/constants/app_strings.dart](lib/core/constants/app_strings.dart)

## Networking

- `Dio` with `AuthInterceptor` for authenticated endpoints
- Public endpoints (e.g. forgot password) use a separate plain Dio without the interceptor
- API base URL and endpoints in [lib/core/constants/app_constants.dart](lib/core/constants/app_constants.dart)
- Token storage: `flutter_secure_storage` via `SecureTokenStorage`

## Adding a New Feature

1. Create `lib/feature/<name>/` with `data/`, `domain/`, `presentation/` subdirectories
2. Add entities in `domain/entities/`, abstract repo in `domain/repositories/`, use cases in `domain/usecases/`
3. Add models (with `json_serializable`) in `data/models/`, data sources in `data/datasources/`, repo impl in `data/repositories/`
4. Add cubit + state (`part` file) in `presentation/cubit/`, pages in `presentation/pages/`
5. Create barrel exports at each layer (`data.dart`, `domain.dart`, `presentation.dart`)
6. Register all dependencies in `service_locator.dart` following the existing pattern
7. Add route in [lib/core/routes/router.dart](lib/core/routes/router.dart) and constant in `routes.dart`
8. Run `dart run build_runner build --delete-conflicting-outputs` if models were added
