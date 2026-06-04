import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';
import '../widgets/josi_logo.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2200),
    this.onFinished,
  });

  final Duration duration;
  final VoidCallback? onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _rise;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward();
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _rise = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('splash-screen'),
      backgroundColor: JosiColors.black,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _SpeedField()),
          Positioned(
            left: -80,
            right: -80,
            bottom: -130,
            height: 310,
            child: Transform.rotate(
              angle: -0.17,
              child: Container(color: JosiColors.red),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _rise,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        JosiLogo(width: 220, framed: true),
                        SizedBox(height: 28),
                        Text(
                          'Josi Ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Move smarter. Arrive ready.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedField extends StatelessWidget {
  const _SpeedField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SpeedFieldPainter());
  }
}

class _SpeedFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint redPaint = Paint()
      ..color = JosiColors.red.withOpacity(0.22)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final Paint whitePaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < 8; index++) {
      final double y = size.height * (0.16 + index * 0.09);
      final double start = size.width * ((index.isEven ? 0.05 : 0.18));
      canvas.drawLine(
        Offset(start, y),
        Offset(size.width * 0.46, y - 26),
        index.isEven ? redPaint : whitePaint,
      );
    }

    final Paint centerLine = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final Path path = Path()
      ..moveTo(size.width * 0.82, -20)
      ..quadraticBezierTo(size.width * 0.62, size.height * 0.36, size.width * 0.92, size.height + 20);
    canvas.drawPath(path, centerLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
