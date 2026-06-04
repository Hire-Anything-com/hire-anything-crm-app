import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/constants/app_constants.dart';
import 'package:hireanythingbooking/core/debug/app_bloc_observer.dart';
import 'package:hireanythingbooking/core/di/service_locator.dart';
import 'package:hireanythingbooking/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  // Initialize service locator with API base URL
  await ServiceLocator.setupServiceLocator(baseUrl: AppConstants.baseUrl);

  // Minor debug print added for CI verification on branch dev/feshan
  debugPrint('CI check: dev/feshan - debug print added');

  runApp(const MyApp());
}
