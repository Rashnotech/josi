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
              padding: const EdgeInsets.fromLTRB(27, 29, 27, 36),
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
                  const SizedBox(height: 72),
                  const Center(child: _LogoCard(size: 128, innerSize: 86)),
                  const SizedBox(height: 42),
                  Text(
                    'Welcome to Josi Ride',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Select your experience',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.muted,
                          fontSize: 20,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 72),
                  _RoleCard(
                    title: 'Continue as Customer',
                    subtitle:
                        'Book rides, track your driver, and\nmanage your trips.',
                    buttonLabel: 'Get Started',
                    icon: const _SvgIcon(asset: AppAssets.profile, size: 46),
                    onTap: () => context.go(AppRoutes.loginFor('customer')),
                  ),
                  const SizedBox(height: 28),
                  _RoleCard(
                    title: 'Continue as Rider',
                    subtitle:
                        'Accept requests, navigate routes, and\nmanage your earnings.',
                    buttonLabel: 'Drive with Us',
                    isPrimary: false,
                    icon: const _SvgIcon(asset: AppAssets.bikeLane, size: 46),
                    onTap: () => context.go(AppRoutes.loginFor('rider')),
                  ),
                  const SizedBox(height: 66),
                  Text(
                    'POWERED BY JOSI RIDE',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: JosiColors.outline,
                          letterSpacing: 3.2,
                          fontSize: 13,
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
              padding: EdgeInsets.fromLTRB(29, 29, 29, _isRider ? 44 : 52),
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
                  SizedBox(height: _isRider ? 44 : 101),
                  Center(
                    child: _isRider
                        ? const _LogoCard(
                            size: 72, innerSize: 58, framed: false)
                        : const _LogoCard(
                            size: 130, innerSize: 86, framed: false),
                  ),
                  SizedBox(height: _isRider ? 235 : 38),
                  Text(
                    title,
                    textAlign: _isRider ? TextAlign.left : TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: _isRider ? 40 : 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    textAlign: _isRider ? TextAlign.left : TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: JosiColors.softMuted,
                          fontSize: _isRider ? 26 : 22,
                          height: 1.18,
                        ),
                  ),
                  const SizedBox(height: 74),
                  _RedlineTextField(
                    key: const ValueKey<String>('login-identity-field'),
                    label: emailLabel,
                    hintText: 'name@example.com',
                    controller: _identityController,
                    svgAsset: AppAssets.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 36),
                  _RedlineTextField(
                    key: const ValueKey<String>('login-password-field'),
                    label: 'PASSWORD',
                    hintText: '•••••••••',
                    controller: _passwordController,
                    svgAsset: AppAssets.padlock,
                    obscureText: true,
                    trailingLabel: 'Forgot Password?',
                    onTrailingTap: () => context.go(AppRoutes.forgotPassword),
                    textInputAction: TextInputAction.done,
                  ),
                  if (session.errorMessage != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      session.errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: JosiColors.redDark),
                    ),
                  ],
                  const SizedBox(height: 50),
                  SizedBox(
                    height: 88,
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
                                  letterSpacing: 1.5,
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
                                const SizedBox(width: 17),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 32),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 94),
                  const _OrDivider(),
                  const SizedBox(height: 38),
                  SizedBox(
                    height: 90,
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
                            dimension: 29,
                            child: SvgPicture.asset(AppAssets.google),
                          ),
                          const SizedBox(width: 24),
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
                                    fontSize: 19,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 104),
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
                                    fontSize: 22,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 15),
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
                                      fontSize: 22,
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
  bool _acceptedTerms = true;

  Future<void> _submit() async {
    await ref.read(authControllerProvider.notifier).registerCustomer();
    if (mounted) {
      context.go(AppRoutes.customerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Customer account',
      subtitle: 'Create your Josi profile',
      child: AppScreenBody(
        children: <Widget>[
          const AppTextField(
              label: 'Name',
              hintText: 'Rik Space',
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Email',
              hintText: 'rik@josi.ng',
              icon: Icons.email_outlined),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Phone',
              hintText: '+234 801 234 5678',
              icon: Icons.phone_outlined),
          const SizedBox(height: 12),
          const AppPasswordField(
              label: 'Password', hintText: 'Create password'),
          const SizedBox(height: 12),
          const AppPasswordField(
              label: 'Confirm password', hintText: 'Repeat password'),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _acceptedTerms,
            onChanged: (bool? value) =>
                setState(() => _acceptedTerms = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'I agree to Josi terms and privacy policy.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Create account',
            icon: Icons.person_add_alt_1_rounded,
            isLoading: session.isLoading,
            onPressed: _acceptedTerms ? _submit : null,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Already have an account? Log in'),
            ),
          ),
        ],
      ),
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
  int _step = 0;

  Future<void> _submit() async {
    if (_step < 2) {
      setState(() => _step += 1);
      return;
    }
    await ref.read(authControllerProvider.notifier).registerRider();
    if (mounted) {
      context.go(AppRoutes.riderApplicationStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Rider registration',
      subtitle: 'Step ${_step + 1} of 3',
      child: AppScreenBody(
        children: <Widget>[
          LinearProgressIndicator(
            value: (_step + 1) / 3,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: JosiColors.red,
            backgroundColor: JosiColors.line,
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _RiderRegistrationStep(step: _step),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: _step == 2 ? 'Submit application' : 'Continue',
            icon:
                _step == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
            isLoading: session.isLoading,
            onPressed: _submit,
          ),
          if (_step > 0)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _step -= 1),
                child: const Text('Back'),
              ),
            ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Forgot password',
      subtitle: 'Reset access safely',
      child: AppScreenBody(
        children: <Widget>[
          Text(
            'Enter your email or phone number and Josi will send a 6-digit reset code.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: JosiColors.muted),
          ),
          const SizedBox(height: 20),
          const AppTextField(
              label: 'Email or phone',
              hintText: 'rik@josi.ng',
              icon: Icons.alternate_email_rounded),
          const SizedBox(height: 16),
          AppButton(
            label: 'Send reset code',
            icon: Icons.send_rounded,
            onPressed: () => setState(() => _sent = true),
          ),
          if (_sent) ...<Widget>[
            const SizedBox(height: 16),
            AppCard(
              color: JosiColors.successSoft,
              child: Text(
                'If this account exists, a reset code has been sent.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: JosiColors.success),
              ),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Enter code',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go(AppRoutes.verifyResetCode),
            ),
          ],
        ],
      ),
    );
  }
}

class VerifyResetCodeScreen extends StatelessWidget {
  const VerifyResetCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Verify code',
      subtitle: 'Code expires in 02:00',
      child: AppScreenBody(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int index = 0; index < 6; index++) ...<Widget>[
                Expanded(
                  child: TextField(
                    key: ValueKey<String>('otp-$index'),
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
                if (index < 5) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text('Resend code'),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Verify',
            icon: Icons.verified_rounded,
            onPressed: () => context.go(AppRoutes.resetPassword),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _reset = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Reset password',
      subtitle: 'Choose a stronger password',
      child: AppScreenBody(
        children: <Widget>[
          const AppPasswordField(
              label: 'New password', hintText: 'Enter password'),
          const SizedBox(height: 12),
          const AppPasswordField(
              label: 'Confirm password', hintText: 'Repeat password'),
          const SizedBox(height: 12),
          AppCard(
            color: JosiColors.warningSoft,
            child: Text(
              'Use at least 8 characters with a mix of letters, numbers, and symbols.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: JosiColors.warning),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Reset password',
            icon: Icons.lock_reset_rounded,
            onPressed: () => setState(() => _reset = true),
          ),
          if (_reset) ...<Widget>[
            const SizedBox(height: 16),
            const EmptyState(
              title: 'Password reset',
              message: 'You can now log in with your new password.',
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Back to login',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ],
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
      dimension: 72,
      child: Material(
        color: outlined ? JosiColors.white : const Color(0xFFF0F2F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: outlined ? JosiColors.outlineVariant : Colors.transparent),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.arrowLeft,
              width: 29,
              height: 29,
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
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 39),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          icon,
          const SizedBox(height: 58),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 15),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.muted,
                  fontSize: 21,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: 31),
          SizedBox(
            width: double.infinity,
            height: 64,
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
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
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
                      fontSize: 18,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 13),
        SizedBox(
          height: 88,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.outline,
                  fontSize: 21,
                  letterSpacing: obscureText ? 5 : 0,
                ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: obscureText
                        ? JosiColors.outline
                        : const Color(0xFF6B7280),
                    fontSize: 21,
                    letterSpacing: obscureText ? 5 : 0,
                  ),
              filled: true,
              fillColor: JosiColors.white,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 28, right: 18),
                child: svgAsset == null
                    ? const Icon(Icons.lock_outline_rounded,
                        color: JosiColors.softMuted, size: 29)
                    : SvgPicture.asset(
                        svgAsset!,
                        width: 29,
                        height: 29,
                        colorFilter: const ColorFilter.mode(
                            JosiColors.softMuted, BlendMode.srcIn),
                      ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 76),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 29, horizontal: 0),
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.line,
                  fontSize: 16,
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

class _RiderRegistrationStep extends StatelessWidget {
  const _RiderRegistrationStep({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    if (step == 0) {
      return const Column(
        key: ValueKey<String>('rider-step-personal'),
        children: <Widget>[
          AppTextField(
              label: 'First name',
              hintText: 'Amina',
              icon: Icons.person_outline_rounded),
          SizedBox(height: 12),
          AppTextField(
              label: 'Last name',
              hintText: 'Yusuf',
              icon: Icons.person_outline_rounded),
          SizedBox(height: 12),
          AppTextField(
              label: 'Email',
              hintText: 'amina@josi.ng',
              icon: Icons.email_outlined),
        ],
      );
    }
    if (step == 1) {
      return const Column(
        key: ValueKey<String>('rider-step-location'),
        children: <Widget>[
          AppTextField(
              label: 'Phone',
              hintText: '+234 802 345 6789',
              icon: Icons.phone_outlined),
          SizedBox(height: 12),
          AppTextField(
              label: 'Address',
              hintText: '22 Adetokunbo Ademola Crescent',
              icon: Icons.home_outlined),
          SizedBox(height: 12),
          AppTextField(
              label: 'City',
              hintText: 'Abuja',
              icon: Icons.location_city_rounded),
          SizedBox(height: 12),
          AppTextField(
              label: 'State', hintText: 'FCT', icon: Icons.map_outlined),
        ],
      );
    }
    return const Column(
      key: ValueKey<String>('rider-step-password'),
      children: <Widget>[
        AppPasswordField(label: 'Password', hintText: 'Create password'),
        SizedBox(height: 12),
        AppPasswordField(
            label: 'Confirm password', hintText: 'Repeat password'),
      ],
    );
  }
}
