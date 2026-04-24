---
description: "Use when creating or editing Dart model classes, JSON serialization, data models, or DTOs. Enforces json_serializable conventions and entity-model relationship."
applyTo: "**/models/**"
---

# Dart Model Conventions

- Models use `*Model` suffix and **extend** the matching `*Entity` from `domain/entities/`
- Annotate with `@JsonSerializable()` from `json_annotation`
- Include `factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);`
- Include `Map<String, dynamic> toJson() => _$ModelToJson(this);`
- Add `part '*.g.dart';` for generated code
- Response wrapper models (e.g. `LoginResponseModel`) follow the same pattern
- After adding or changing models, run: `dart run build_runner build --delete-conflicting-outputs`
- Use `@JsonKey(name: 'api_field')` when API field names differ from Dart properties
- Create barrel export in `data.dart` including all models
