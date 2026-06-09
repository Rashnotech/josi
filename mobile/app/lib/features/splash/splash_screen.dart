import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen(
      {super.key, this.duration = const Duration(milliseconds: 1600)});

  final Duration duration;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _finish);
  }

  void _finish() {
    if (!mounted) {
      return;
    }
    final AuthSession session = ref.read(authControllerProvider);
    final JosiUser? user = session.user;
    if (user == null) {
      context.go(AppRoutes.roleSelection);
      return;
    }
    switch (user.role) {
      case AppRole.customer:
        context.go(AppRoutes.customerHome);
      case AppRole.rider:
        context.go(user.applicationStatus == RiderApplicationStatus.approved
            ? AppRoutes.riderHome
            : AppRoutes.riderApplicationStatus);
      case AppRole.fleetOwner:
        context.go(AppRoutes.fleetDashboard);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('splash-screen'),
      backgroundColor: JosiColors.red,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Semantics(
            label: 'Josi splash logo',
            image: true,
            child: Image.asset(
              AppAssets.splashLogo,
              key: const ValueKey<String>('splash-logo'),
              width: 330,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
