import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/routes/router.dart';
import 'package:hireanythingbooking/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hire Anything Booking',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
