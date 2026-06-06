import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';
import '../widgets/josi_logo.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 4200),
    this.onFinished,
  });

  final Duration duration;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }
    Navigator.of(context).pushReplacementNamed(SignInScreen.routeName);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: ValueKey<String>('splash-screen'),
      backgroundColor: JosiColors.red,
      body: Center(
        child: JosiLogo(width: 238),
      ),
    );
  }
}
