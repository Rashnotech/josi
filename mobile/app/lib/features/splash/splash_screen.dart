import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
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
      context.go(AppRoutes.onboarding);
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Semantics(
                label: 'Josi logo',
                image: true,
                child: Image.asset('assets/images/josi-logo.png', width: 184),
              ),
              const SizedBox(height: 16),
              Text(
                'City rides. Clean logistics.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white.withAlpha(219)),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
