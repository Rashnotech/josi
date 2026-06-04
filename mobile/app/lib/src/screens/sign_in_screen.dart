import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/josi_colors.dart';
import '../widgets/josi_logo.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_button.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '8114510020');
  bool _acceptedTerms = false;
  bool _showError = false;

  String get _digitsOnly => _phoneController.text.replaceAll(RegExp('[^0-9]'), '');

  bool get _canContinue => _digitsOnly.length >= 10 && _acceptedTerms;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_canContinue) {
      setState(() => _showError = true);
      return;
    }
    Navigator.of(context).pushReplacementNamed(RideHomeScreen.routeName);
  }

  void _toggleTerms(bool? value) {
    setState(() {
      _acceptedTerms = value ?? false;
      if (_canContinue) {
        _showError = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    return Scaffold(
      key: const ValueKey<String>('sign-in-screen'),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: _Header(height: screen.height < 720 ? 238 : 286)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Enter your number', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 10),
                        Text(
                          'Sign in or create your rider account with a Nigerian phone number.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JosiColors.muted),
                        ),
                        const SizedBox(height: 24),
                        _PhoneInput(controller: _phoneController),
                        if (_showError && _digitsOnly.length < 10) ...<Widget>[
                          const SizedBox(height: 8),
                          const _FieldError('Enter at least 10 phone digits.'),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Checkbox(
                              key: const ValueKey<String>('terms-checkbox'),
                              value: _acceptedTerms,
                              onChanged: _toggleTerms,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to Josi Ride ',
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: 'Terms',
                                        style: TextStyle(
                                          color: JosiColors.red,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: JosiColors.red,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: JosiColors.muted),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_showError && !_acceptedTerms) ...<Widget>[
                          const SizedBox(height: 4),
                          const _FieldError('Accept the terms to continue.'),
                        ],
                        const SizedBox(height: 22),
                        PrimaryButton(
                          key: const ValueKey<String>('continue-button'),
                          label: 'Sign in',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _continue,
                        ),
                        const SizedBox(height: 26),
                        const _DividerLabel(label: 'Or'),
                        const SizedBox(height: 20),
                        SocialButton(
                          label: 'Sign in with Google',
                          mark: 'G',
                          markColor: const Color(0xFF4285F4),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 14),
                        SocialButton(
                          label: 'Sign in with Facebook',
                          mark: 'f',
                          markColor: const Color(0xFF1877F2),
                          onPressed: () {},
                        ),
                        const SizedBox(height: 28),
                      ],
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

class _Header extends StatelessWidget {
  const _Header({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ColoredBox(color: JosiColors.black),
          Positioned(
            left: -60,
            right: -60,
            bottom: -74,
            height: 150,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(color: JosiColors.red),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _PickupPatternPainter())),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const JosiLogo(width: 126, framed: true),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.shield_outlined, color: Colors.white, size: 17),
                          const SizedBox(width: 7),
                          Text(
                            'Secure',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Ride through your city with Josi.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fast pickups, scheduled trips, and logistics support in one account.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey<String>('phone-field'),
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.allow(RegExp('[0-9 ]')),
      ],
      style: Theme.of(context).textTheme.titleMedium,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 36,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: JosiColors.line),
                ),
                child: const Text(
                  'NG',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '+234',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: JosiColors.muted),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 132),
        hintText: 'Phone number',
      ),
      onChanged: (_) {},
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: JosiColors.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: JosiColors.muted),
          ),
        ),
        const Expanded(child: Divider(color: JosiColors.line)),
      ],
    );
  }
}

class _FieldError extends StatelessWidget {
  const _FieldError(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: JosiColors.redDark,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _PickupPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final Paint point = Paint()
      ..color = JosiColors.red.withOpacity(0.34)
      ..style = PaintingStyle.fill;

    for (int index = 0; index < 7; index++) {
      final double x = size.width * (0.08 + index * 0.16);
      final Path path = Path()
        ..moveTo(x, size.height * 0.2)
        ..quadraticBezierTo(x + 28, size.height * 0.46, x - 18, size.height * 0.76);
      canvas.drawPath(path, line);
      canvas.drawCircle(Offset(x, size.height * (0.26 + (index % 3) * 0.17)), 3.5, point);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
