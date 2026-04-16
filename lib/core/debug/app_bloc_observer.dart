import 'package:hireanythingbooking/core/constants/imports.dart';

/// Custom BlocObserver for observing and logging Bloc events and state changes.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    if (kDebugMode) {
      debugPrint('onCreate -- ${bloc.runtimeType}');
    }
    super.onCreate(bloc);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    if (kDebugMode) {
      debugPrint('onChange -- ${bloc.runtimeType}, $change');
    }
    super.onChange(bloc, change);
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    if (kDebugMode) {
      debugPrint('onEvent -- ${bloc.runtimeType}, $event');
    }
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    if (kDebugMode) {
      debugPrint('onTransition -- ${bloc.runtimeType}, $transition');
    }
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('onError -- ${bloc.runtimeType}, $error');
    }
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    if (kDebugMode) {
      debugPrint('onClose -- ${bloc.runtimeType}');
    }
    super.onClose(bloc);
  }
}
