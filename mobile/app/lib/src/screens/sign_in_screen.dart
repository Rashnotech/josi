import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).pushReplacementNamed(RideHomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('sign-in-screen'),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 42, 30, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 36),
                  Text(
                    'Hop In - Log In to Your\nJosi Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.18,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Access your rides, track trips, manage payments,\nand travel anywhere with ease.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8C8C8C),
                          height: 1.45,
                        ),
                  ),
                  const SizedBox(height: 64),
                  _AuthField(
                    key: const ValueKey<String>('email-field'),
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Gail_santos@icloud.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  _AuthField(
                    key: const ValueKey<String>('password-field'),
                    controller: _passwordController,
                    label: 'Password',
                    hintText: '.......',
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      color: const Color(0xFF8C8C8C),
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      SizedBox.square(
                        dimension: 22,
                        child: Checkbox(
                          key: const ValueKey<String>('remember-checkbox'),
                          value: _rememberMe,
                          onChanged: (bool? value) => setState(() => _rememberMe = value ?? false),
                          side: const BorderSide(color: Color(0xFF6F6F6F), width: 1.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Remember Me',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF8C8C8C)),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: JosiColors.red,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 34),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Forgot Password ?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _DividerLabel(label: 'Or'),
                  const SizedBox(height: 22),
                  _RedSocialButton(
                    key: const ValueKey<String>('google-login-button'),
                    label: 'Continue With Google',
                    icon: Icons.g_mobiledata_rounded,
                    onPressed: _continue,
                  ),
                  const SizedBox(height: 14),
                  _RedSocialButton(
                    key: const ValueKey<String>('apple-login-button'),
                    label: 'Continue With Apple',
                    icon: Icons.apple_rounded,
                    onPressed: _continue,
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Don't have an account ! ",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF737373)),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: JosiColors.red,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFF777777)),
            filled: true,
            fillColor: const Color(0xFF111111),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(24),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: JosiColors.red, width: 1.4),
              borderRadius: BorderRadius.circular(24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      ],
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
        const Expanded(child: Divider(color: Color(0xFF1E1E1E))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8C8C8C)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF1E1E1E))),
      ],
    );
  }
}

class _RedSocialButton extends StatelessWidget {
  const _RedSocialButton({
    required this.label,
    required this.onPressed,
    required this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        backgroundColor: JosiColors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 21),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}
