# Project Guidelines

## Code Style
- Developed in Dart with standard Flutter linting (`package:flutter_lints/flutter.yaml`).
- Strongly typed and favor immutability. Models use `json_serializable` and `json_annotation` for JSON parsing.
- Use `equatable` for Bloc states and model equality.

## Architecture
- Feature-driven folder structure inside `lib/`:
  - `core/`: Common components including models, services (API, shared preferences), utilities, and extensions.
  - `features/`: Specific app features (e.g., drug_search, pharmacy_search), each containing its UI (`view/`) and state management (`bloc/` or `cubit/`).
- State management strictly uses `flutter_bloc` (both Blocs and Cubits) with streams supplemented by `rxdart`. Dependency injection is managed via `get_it`.
- **API Reference:** The API used is specified in github.com/dimeskigj/drugregistry.api's README.

## Build and Test
- Run `flutter pub get` to install dependencies.
- Models requiring code generation (`.g.dart`) should be built using:
  `dart run build_runner build --delete-conflicting-outputs`
- Execute tests with `flutter test`.

## Conventions
- Follow separation of concerns: Widgets in `view/` should strictly rely on `BlocProvider`/`BlocBuilder` rather than holding complex state.
- External data sources (like the Drug Registry) should be accessed via services defined in `lib/core/services/` and injected via `get_it`.
