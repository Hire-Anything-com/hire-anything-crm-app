---
description: "Scaffold a new Flutter feature with full Clean Architecture layers (data, domain, presentation), barrel exports, DI registration, and routing"
agent: "agent"
argument-hint: "Feature name (e.g. booking, profile, notifications)"
---

Scaffold a complete new feature called `{{input}}` following the project's Clean Architecture conventions defined in [AGENTS.md](../../AGENTS.md).

## Steps

1. **Create folder structure** under `lib/feature/{{input}}/`:
   - `data/datasources/` — remote data source (abstract + `*Impl` using Dio)
   - `data/models/` — model with `json_serializable` annotations extending the entity
   - `data/repositories/` — repository impl catching exceptions → `Failure`
   - `domain/entities/` — entity extending `Equatable` with `*Entity` suffix
   - `domain/repositories/` — abstract repository returning `Either<Failure, T>`
   - `domain/usecases/` — use case with `*UseCase` suffix
   - `presentation/cubit/` — Cubit + State (`part` file) with `Equatable` & `copyWith`
   - `presentation/pages/` — page widget with `BlocProvider`
   - `presentation/pages/widgets/` — page-specific widgets

2. **Create barrel exports** at each layer: `data.dart`, `domain.dart`, `presentation.dart`

3. **Register dependencies** in `lib/core/di/service_locator.dart`:
   - Add a `_setup{{Input}}Feature` method following the existing pattern
   - Order: DataSource → Repository → UseCase → Cubit
   - Use authenticated Dio unless this is a public endpoint

4. **Add route** in `lib/core/routes/router.dart` and constant in `lib/core/routes/routes.dart`

5. **Run code generation** if models were added:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

Use existing features like `login` or `dashboard/presentation/tabs/task` as reference for patterns.
