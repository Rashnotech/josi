import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('role-selection-screen'),
      backgroundColor: JosiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(27, 24, 27, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackSquareButton(
                      onPressed: () {
                        if (GoRouter.of(context).canPop()) {
                          context.pop();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(child: _LogoCard(size: 82, innerSize: 58)),
                  const SizedBox(height: 22),
                  Text(
                    'Welcome to Josi Ride',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your experience',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.muted,
                          fontSize: 16,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 28),
                  _RoleCard(
                    title: 'Continue as Customer',
                    subtitle:
                        'Book rides, track your driver, and\nmanage your trips.',
                    buttonLabel: 'Get Started',
                    icon: const _SvgIcon(asset: AppAssets.profile, size: 30),
                    onTap: () => context.go(AppRoutes.loginFor('customer')),
                  ),
                  const SizedBox(height: 18),
                  _RoleCard(
                    title: 'Continue as Rider',
                    subtitle:
                        'Accept requests, navigate routes, and\nmanage your earnings.',
                    buttonLabel: 'Drive with Us',
                    isPrimary: false,
                    icon: const _SvgIcon(asset: AppAssets.bikeLane, size: 30),
                    onTap: () => context.go(AppRoutes.loginFor('rider')),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'POWERED BY JOSI RIDE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: JosiColors.outline,
                          letterSpacing: 2.6,
                          fontSize: 11,
                        ),
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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.role = 'customer',
  });

  final String role;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get _isRider => widget.role.toLowerCase() == 'rider';

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authControllerProvider.notifier).signIn(
          identity: _identityController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) {
      return;
    }
    if (_isRider) {
      context.go(AppRoutes.riderApplicationStatus);
      return;
    }
    context.go(AppRoutes.customerHome);
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);
    final String title = _isRider ? 'Rider Login' : 'Customer Login';
    final String subtitle = _isRider
        ? 'Rider Dashboard Access'
        : 'Secure your ride. Enter your details below.';
    final String emailLabel = _isRider ? 'EMAIL' : 'EMAIL ADDRESS';
    final String buttonLabel = _isRider ? 'Login' : 'LOGIN';

    return Scaffold(
      key: const ValueKey<String>('login-screen'),
      backgroundColor: JosiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(29, 24, 29, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackSquareButton(
                      outlined: !_isRider,
                      onPressed: () => context.go(AppRoutes.roleSelection),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _isRider
                        ? const _LogoCard(
                            size: 72, innerSize: 58, framed: false)
                        : const _LogoCard(
                            size: 78, innerSize: 72, framed: false),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: _isRider ? TextAlign.left : TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: _isRider ? 30 : 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: _isRider ? TextAlign.left : TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.softMuted,
                          fontSize: _isRider ? 17 : 16,
                          height: 1.18,
                        ),
                  ),
                  const SizedBox(height: 28),
                  _RedlineTextField(
                    key: const ValueKey<String>('login-identity-field'),
                    label: emailLabel,
                    hintText: 'name@example.com',
                    controller: _identityController,
                    svgAsset: AppAssets.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _RedlineTextField(
                    key: const ValueKey<String>('login-password-field'),
                    label: 'PASSWORD',
                    hintText: '•••••••••',
                    controller: _passwordController,
                    svgAsset: AppAssets.padlock,
                    obscureText: true,
                    trailingLabel: 'Forgot Password?',
                    onTrailingTap: () =>
                        context.go(AppRoutes.forgotPasswordFor(widget.role)),
                    textInputAction: TextInputAction.done,
                  ),
                  if (session.errorMessage != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      session.errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: JosiColors.redDark),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      key: const ValueKey<String>('login-button'),
                      onPressed: session.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isRider ? JosiColors.red : JosiColors.redDark,
                        foregroundColor: JosiColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        textStyle:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: JosiColors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  letterSpacing: 1.2,
                                ),
                      ),
                      child: session.isLoading
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: JosiColors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(buttonLabel),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 25),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _OrDivider(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _submit,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: JosiColors.white,
                        side: BorderSide(
                            color: _isRider
                                ? JosiColors.outlineVariant
                                : JosiColors.outline),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox.square(
                            dimension: 24,
                            child: SvgPicture.asset(AppAssets.google),
                          ),
                          const SizedBox(width: 14),
                          Flexible(
                            child: Text(
                              'Continue with Google',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: JosiColors.ink,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'New here?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: JosiColors.softMuted,
                                    fontSize: 17,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => context.go(_isRider
                              ? AppRoutes.riderRegister
                              : AppRoutes.customerRegister),
                          child: Text(
                            'Create account',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: _isRider
                                          ? JosiColors.ink
                                          : JosiColors.redDark,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
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

class CustomerRegistrationScreen extends ConsumerStatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  ConsumerState<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends ConsumerState<CustomerRegistrationScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authControllerProvider.notifier).registerCustomer();
    if (mounted) {
      context.go(AppRoutes.customerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);

    return _SignupScaffold(
      key: const ValueKey<String>('customer-register-screen'),
      title: 'Create Account',
      subtitle: 'Join Josi Ride today',
      onBack: () => context.go(AppRoutes.loginFor('customer')),
      children: <Widget>[
        _SignupTextField(
          key: const ValueKey<String>('customer-name-field'),
          label: 'Full Name',
          hintText: 'e.g. Alex Josi',
          controller: _fullNameController,
        ),
        const SizedBox(height: 12),
        _SignupTextField(
          label: 'Email Address',
          hintText: 'name@example.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _SignupTextField(
          label: 'Phone Number',
          hintText: '+1 (555) 000-0000',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
        _SignupTextField(
          label: 'Password',
          hintText: '••••••••',
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 28),
        _SignupPrimaryButton(
          key: const ValueKey<String>('customer-sign-up-button'),
          label: 'Sign Up',
          isLoading: session.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 26),
        const _SignupOrDivider(),
        const SizedBox(height: 18),
        _SignupGoogleButton(onPressed: _submit),
        const SizedBox(height: 32),
        _SignupLoginLink(
          onTap: () => context.go(AppRoutes.loginFor('customer')),
        ),
      ],
    );
  }
}

class RiderRegistrationScreen extends ConsumerStatefulWidget {
  const RiderRegistrationScreen({super.key});

  @override
  ConsumerState<RiderRegistrationScreen> createState() =>
      _RiderRegistrationScreenState();
}

class _RiderRegistrationScreenState
    extends ConsumerState<RiderRegistrationScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _vehicleType = 'Select vehicle type';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authControllerProvider.notifier).registerRider();
    if (mounted) {
      context.go(AppRoutes.riderApplicationStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);

    return _SignupScaffold(
      key: const ValueKey<String>('rider-register-screen'),
      title: 'Drive with Josi Ride',
      subtitle: 'Start earning on your own schedule',
      logoSize: 60,
      logoInnerSize: 60,
      titleFontSize: 26,
      topSpacing: 0,
      titleSpacing: 12,
      fieldSpacing: 14,
      onBack: () => context.go(AppRoutes.loginFor('rider')),
      children: <Widget>[
        _SignupTextField(
          key: const ValueKey<String>('rider-name-field'),
          label: 'Full Name',
          hintText: 'Alex Josi',
          controller: _fullNameController,
          filled: false,
          borderColor: const Color(0xFF536178),
        ),
        const SizedBox(height: 6),
        _SignupTextField(
          label: 'Email Address',
          hintText: 'alex@example.com',
          controller: _emailController,
          filled: false,
          borderColor: const Color(0xFF536178),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 6),
        _SignupTextField(
          label: 'Phone Number',
          hintText: '+1 (555) 000-0000',
          controller: _phoneController,
          filled: false,
          borderColor: const Color(0xFF536178),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 6),
        _SignupDropdownField(
          label: 'Vehicle Type',
          value: _vehicleType,
          items: const <String>[
            'Select vehicle type',
            'Motorcycle',
            'Car',
            'Tricycle',
            'Van',
          ],
          onChanged: (String? value) =>
              setState(() => _vehicleType = value ?? _vehicleType),
        ),
        const SizedBox(height: 6),
        _SignupTextField(
          label: 'Password',
          hintText: '••••••••',
          controller: _passwordController,
          obscureText: true,
          filled: false,
          borderColor: const Color(0xFF536178),
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        _SignupPrimaryButton(
          key: const ValueKey<String>('rider-sign-up-button'),
          label: 'Sign Up to Drive',
          isLoading: session.isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 16),
        const _SignupOrDivider(),
        const SizedBox(height: 12),
        _SignupGoogleButton(onPressed: _submit),
        const SizedBox(height: 14),
        _SignupLoginLink(
          onTap: () => context.go(AppRoutes.loginFor('rider')),
        ),
      ],
    );
  }
}

class _SignupScaffold extends StatelessWidget {
  const _SignupScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onBack,
    super.key,
    this.logoSize = 68,
    this.logoInnerSize = 68,
    this.titleFontSize = 27,
    this.topSpacing = 8,
    this.titleSpacing = 18,
    this.fieldSpacing = 24,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onBack;
  final double logoSize;
  final double logoInnerSize;
  final double titleFontSize;
  final double topSpacing;
  final double titleSpacing;
  final double fieldSpacing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(27, 22, 27, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: onBack,
                      icon: SvgPicture.asset(
                        AppAssets.arrowLeft,
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                            JosiColors.muted, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  SizedBox(height: topSpacing),
                  Center(
                    child: _LogoCard(
                      size: logoSize,
                      innerSize: logoInnerSize,
                      framed: false,
                    ),
                  ),
                  SizedBox(height: titleSpacing),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.muted,
                          fontSize: 16,
                          height: 1.2,
                        ),
                  ),
                  SizedBox(height: fieldSpacing),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupTextField extends StatefulWidget {
  const _SignupTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    super.key,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.filled = true,
    this.borderColor = JosiColors.line,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool filled;
  final Color borderColor;

  @override
  State<_SignupTextField> createState() => _SignupTextFieldState();
}

class _SignupTextFieldState extends State<_SignupTextField> {
  late bool _obscure = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return _SignupFieldShell(
      label: widget.label,
      child: SizedBox(
        height: 52,
        child: TextField(
          controller: widget.controller,
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.muted,
                fontSize: 15,
                letterSpacing: widget.obscureText ? 2.8 : 0,
              ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.filled
                      ? JosiColors.muted
                      : const Color(0xFFC6C4C6),
                  fontSize: 15,
                  letterSpacing: widget.obscureText ? 2.8 : 0,
                ),
            filled: true,
            fillColor:
                widget.filled ? const Color(0xFFF7F9FB) : JosiColors.white,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: JosiColors.muted,
                      size: 20,
                    ),
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: widget.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: widget.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: JosiColors.redDark, width: 1.3),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupDropdownField extends StatelessWidget {
  const _SignupDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SignupFieldShell(
      label: label,
      child: SizedBox(
        height: 52,
        child: DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: JosiColors.muted, size: 24),
          items: items
              .map((String item) =>
                  DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.ink,
                fontSize: 15,
              ),
          decoration: InputDecoration(
            filled: true,
            fillColor: JosiColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: JosiColors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: JosiColors.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide:
                  const BorderSide(color: JosiColors.redDark, width: 1.3),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupFieldShell extends StatelessWidget {
  const _SignupFieldShell({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: JosiColors.black,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class _SignupPrimaryButton extends StatelessWidget {
  const _SignupPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: JosiColors.red,
          foregroundColor: JosiColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
        ),
        child: isLoading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: JosiColors.white),
              )
            : Text(label),
      ),
    );
  }
}

class _SignupOrDivider extends StatelessWidget {
  const _SignupOrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: JosiColors.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.muted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Expanded(child: Divider(color: JosiColors.line)),
      ],
    );
  }
}

class _SignupGoogleButton extends StatelessWidget {
  const _SignupGoogleButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: JosiColors.white,
          side: const BorderSide(color: JosiColors.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.square(
              dimension: 22,
              child: SvgPicture.asset(AppAssets.google),
            ),
            const SizedBox(width: 14),
            Flexible(
              child: Text(
                'Continue with Google',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupLoginLink extends StatelessWidget {
  const _SignupLoginLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            'Already have an account?',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.muted,
                  fontSize: 16,
                ),
          ),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Log in',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.redDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.role = 'customer',
  });

  final String role;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _identityController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _identityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecoveryScaffold(
      screenKey: const ValueKey<String>('forgot-password-screen'),
      title: 'Forgot Password',
      subtitle: 'Reset access safely',
      onBack: () => context.go(AppRoutes.loginFor(widget.role)),
      children: <Widget>[
        Text(
          'Enter your email or phone number and Josi will send a 6-digit reset code.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.muted,
                fontSize: 15,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 20),
        _RedlineTextField(
          key: const ValueKey<String>('forgot-identity-field'),
          label: 'EMAIL OR PHONE',
          hintText: 'name@example.com',
          controller: _identityController,
          svgAsset: AppAssets.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 24),
        _RecoveryButton(
          key: const ValueKey<String>('send-reset-code-button'),
          label: 'SEND CODE',
          onPressed: () => setState(() => _sent = true),
        ),
        if (_sent) ...<Widget>[
          const SizedBox(height: 16),
          const _RecoveryStatusCard(
            message: 'If this account exists, a reset code has been sent.',
          ),
          const SizedBox(height: 12),
          _RecoveryButton(
            label: 'ENTER CODE',
            isPrimary: false,
            onPressed: () =>
                context.go(AppRoutes.verifyResetCodeFor(widget.role)),
          ),
        ],
      ],
    );
  }
}

class VerifyResetCodeScreen extends StatelessWidget {
  const VerifyResetCodeScreen({
    super.key,
    this.role = 'customer',
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    return _RecoveryScaffold(
      screenKey: const ValueKey<String>('verify-reset-code-screen'),
      title: 'Verify Code',
      subtitle: 'Enter the 6-digit code sent to your account.',
      onBack: () => context.go(AppRoutes.forgotPasswordFor(role)),
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int index = 0; index < 6; index++) ...<Widget>[
              Expanded(child: _OtpCodeField(index: index)),
              if (index < 5) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Code expires in 02:00',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: JosiColors.muted,
                      fontSize: 14,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Resend code'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _RecoveryButton(
          key: const ValueKey<String>('verify-reset-code-button'),
          label: 'VERIFY',
          onPressed: () => context.go(AppRoutes.resetPasswordFor(role)),
        ),
      ],
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.role = 'customer',
  });

  final String role;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _reset = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecoveryScaffold(
      screenKey: const ValueKey<String>('reset-password-screen'),
      title: 'Reset Password',
      subtitle: 'Choose a new secure password.',
      onBack: () => context.go(AppRoutes.verifyResetCodeFor(widget.role)),
      children: <Widget>[
        _RedlineTextField(
          key: const ValueKey<String>('new-password-field'),
          label: 'NEW PASSWORD',
          hintText: '••••••••',
          controller: _passwordController,
          svgAsset: AppAssets.padlock,
          obscureText: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        _RedlineTextField(
          key: const ValueKey<String>('confirm-password-field'),
          label: 'CONFIRM PASSWORD',
          hintText: '••••••••',
          controller: _confirmPasswordController,
          svgAsset: AppAssets.padlock,
          obscureText: true,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 16),
        const _RecoveryStatusCard(
          message:
              'Use at least 8 characters with letters, numbers, and symbols.',
          icon: Icons.info_outline_rounded,
          foregroundColor: JosiColors.warning,
          backgroundColor: JosiColors.warningSoft,
        ),
        const SizedBox(height: 22),
        _RecoveryButton(
          key: const ValueKey<String>('reset-password-button'),
          label: 'RESET PASSWORD',
          onPressed: () => setState(() => _reset = true),
        ),
        if (_reset) ...<Widget>[
          const SizedBox(height: 16),
          const _RecoveryStatusCard(
            message: 'Password reset. You can now log in securely.',
          ),
          const SizedBox(height: 12),
          _RecoveryButton(
            label: 'BACK TO LOGIN',
            isPrimary: false,
            onPressed: () => context.go(AppRoutes.loginFor(widget.role)),
          ),
        ],
      ],
    );
  }
}

class _RecoveryScaffold extends StatelessWidget {
  const _RecoveryScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onBack,
    required this.screenKey,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onBack;
  final Key screenKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      backgroundColor: JosiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(29, 24, 29, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackSquareButton(
                      outlined: true,
                      onPressed: onBack,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: _LogoCard(
                      size: 76,
                      innerSize: 70,
                      framed: false,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.softMuted,
                          fontSize: 16,
                          height: 1.22,
                        ),
                  ),
                  const SizedBox(height: 30),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryButton extends StatelessWidget {
  const _RecoveryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isPrimary = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: JosiColors.redDark,
                foregroundColor: JosiColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: JosiColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(label),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward_rounded, size: 24),
                ],
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: JosiColors.white,
                foregroundColor: JosiColors.ink,
                side: const BorderSide(color: JosiColors.outline),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
              ),
              child: Text(label),
            ),
    );
  }
}

class _RecoveryStatusCard extends StatelessWidget {
  const _RecoveryStatusCard({
    required this.message,
    this.icon = Icons.check_circle_outline_rounded,
    this.foregroundColor = JosiColors.success,
    this.backgroundColor = JosiColors.successSoft,
  });

  final String message;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: foregroundColor, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor,
                    fontSize: 14,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpCodeField extends StatelessWidget {
  const _OtpCodeField({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: TextField(
        key: ValueKey<String>('otp-$index'),
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: JosiColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: JosiColors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: JosiColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: JosiColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: JosiColors.redDark, width: 1.3),
          ),
        ),
      ),
    );
  }
}

class FleetDashboardPlaceholderScreen extends StatelessWidget {
  const FleetDashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Fleet dashboard',
      subtitle: 'Web/admin first for MVP',
      child: AppScreenBody(
        children: <Widget>[
          EmptyState(
            title: 'Fleet tools are web based',
            message:
                'Fleet owners will manage vehicles, drivers, and reporting from the admin dashboard for now.',
            icon: Icons.apartment_rounded,
          ),
        ],
      ),
    );
  }
}

class _BackSquareButton extends StatelessWidget {
  const _BackSquareButton({
    required this.onPressed,
    this.outlined = false,
  });

  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Material(
        color: outlined ? JosiColors.white : const Color(0xFFF0F2F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
              color: outlined ? JosiColors.outlineVariant : Colors.transparent),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.arrowLeft,
              width: 24,
              height: 24,
              colorFilter:
                  const ColorFilter.mode(JosiColors.ink, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard({
    required this.size,
    required this.innerSize,
    this.framed = true,
  });

  final double size;
  final double innerSize;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final Widget mark = Container(
      width: innerSize,
      height: innerSize,
      decoration: BoxDecoration(
        color: JosiColors.red,
        borderRadius: BorderRadius.circular(innerSize * 0.18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        AppAssets.loginLogo,
        key: const ValueKey<String>('login-logo'),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );

    if (!framed) {
      return mark;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: mark,
    );
  }
}

class _SvgIcon extends StatelessWidget {
  const _SvgIcon({
    required this.asset,
    required this.size,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(JosiColors.ink, BlendMode.srcIn),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.icon,
    required this.onTap,
    this.isPrimary = true,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final Widget icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          icon,
          const SizedBox(height: 22),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.muted,
                  fontSize: 15,
                  height: 1.34,
                ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: isPrimary
                ? ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JosiColors.red,
                      foregroundColor: JosiColors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      textStyle:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                    ),
                    child: Text(buttonLabel),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: JosiColors.white,
                      foregroundColor: JosiColors.ink,
                      side: const BorderSide(color: JosiColors.outline),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      textStyle:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                    ),
                    child: Text(buttonLabel),
                  ),
          ),
        ],
      ),
    );
  }
}

class _RedlineTextField extends StatelessWidget {
  const _RedlineTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    super.key,
    this.svgAsset,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? svgAsset;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.4,
                    ),
              ),
            ),
            if (trailingLabel != null)
              GestureDetector(
                onTap: onTrailingTap,
                child: Text(
                  trailingLabel!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.redDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 58,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.outline,
                  fontSize: 16,
                  letterSpacing: obscureText ? 3.2 : 0,
                ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: obscureText
                        ? JosiColors.outline
                        : const Color(0xFF6B7280),
                    fontSize: 16,
                    letterSpacing: obscureText ? 3.2 : 0,
                  ),
              filled: true,
              fillColor: JosiColors.white,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 18, right: 12),
                child: svgAsset == null
                    ? const Icon(Icons.lock_outline_rounded,
                        color: JosiColors.softMuted, size: 23)
                    : SvgPicture.asset(
                        svgAsset!,
                        width: 23,
                        height: 23,
                        colorFilter: const ColorFilter.mode(
                            JosiColors.softMuted, BlendMode.srcIn),
                      ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 54),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 17, horizontal: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: JosiColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: JosiColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide:
                    const BorderSide(color: JosiColors.redDark, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
            child: Divider(color: JosiColors.outlineVariant, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.line,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
          ),
        ),
        const Expanded(
            child: Divider(color: JosiColors.outlineVariant, thickness: 1)),
      ],
    );
  }
}
