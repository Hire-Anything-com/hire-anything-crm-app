import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/constants/app_assets.dart';
import 'package:hireanythingbooking/feature/splash/cubit/splash_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final SplashCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<SplashCubit>()
      ..controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
    cubit.animation = Tween<double>(begin: 0, end: 1).animate(cubit.controller);
    cubit.controller.forward().whenComplete(() => cubit.redirect(context));
  }

  @override
  void dispose() {
    cubit.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: cubit.animation,
            child: Image.asset(
              AppAssets.logo,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
