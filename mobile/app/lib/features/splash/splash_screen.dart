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
      {super.key, this.duration = const Duration(milliseconds: 2000)});

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
    if (session.isLoading) {
      _timer = Timer(const Duration(milliseconds: 250), _finish);
      return;
    }

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
            ? AppRoutes.riderLocationAccess
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Semantics(
                  label: 'Josi splash logo',
                  image: true,
                  child: Image.asset(
                    AppAssets.splashLogo,
                    key: const ValueKey<String>('splash-logo'),
                    width: 260,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Fast city rides. Trusted riders.',
                  key: const ValueKey<String>('splash-tagline'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.white.withValues(alpha: 0.92),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  key: const ValueKey<String>('splash-loader'),
                  width: 112,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 4,
                      backgroundColor: JosiColors.white.withValues(alpha: 0.26),
                      color: JosiColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
