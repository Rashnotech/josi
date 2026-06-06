import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Welcome to Josi',
      subtitle: 'Choose how you want to continue',
      showBackButton: false,
      child: AppScreenBody(
        children: <Widget>[
          const SizedBox(height: 12),
          _RoleCard(
            title: 'Continue as Customer',
            subtitle: 'Book rides, send packages, and manage payments.',
            icon: Icons.person_pin_circle_rounded,
            onTap: () => context.go(AppRoutes.customerRegister),
          ),
          const SizedBox(height: 14),
          _RoleCard(
            title: 'Continue as Rider',
            subtitle: 'Accept trips, track earnings, and complete onboarding.',
            icon: Icons.delivery_dining_rounded,
            onTap: () => context.go(AppRoutes.riderRegister),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.apartment_rounded, color: JosiColors.charcoal),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fleet owners can manage fleets from the web/admin dashboard for this MVP.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: JosiColors.muted),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.fleetDashboard),
                  child: const Text('View'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Log in',
            icon: Icons.login_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _identityController =
      TextEditingController(text: 'rik@josi.ng');
  final TextEditingController _passwordController =
      TextEditingController(text: 'password');

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
    final AuthSession session = ref.read(authControllerProvider);
    final JosiUser? user = session.user;
    if (user == null) {
      return;
    }
    if (user.role == AppRole.customer) {
      context.go(AppRoutes.customerHome);
      return;
    }
    if (user.role == AppRole.rider) {
      context.go(user.applicationStatus == RiderApplicationStatus.approved
          ? AppRoutes.riderHome
          : AppRoutes.riderApplicationStatus);
      return;
    }
    context.go(AppRoutes.fleetDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final AuthSession session = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Log in',
      subtitle: 'Backend role detection is automatic',
      showBackButton: false,
      child: AppScreenBody(
        children: <Widget>[
          const SizedBox(height: 14),
          Text('Access Josi', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Use your email or phone number to continue.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: JosiColors.muted),
          ),
          const SizedBox(height: 24),
          AppTextField(
            key: const ValueKey<String>('login-identity-field'),
            label: 'Email or phone',
            hintText: 'rik@josi.ng',
            controller: _identityController,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AppPasswordField(
            key: const ValueKey<String>('login-password-field'),
            label: 'Password',
            hintText: 'Enter password',
            controller: _passwordController,
            textInputAction: TextInputAction.done,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.go(AppRoutes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
          ),
          if (session.errorMessage != null) ...<Widget>[
            AppCard(
              color: JosiColors.redSoft,
              child: Text(
                session.errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: JosiColors.redDark),
              ),
            ),
            const SizedBox(height: 14),
          ],
          AppButton(
            key: const ValueKey<String>('login-button'),
            label: 'Log in',
            icon: Icons.arrow_forward_rounded,
            isLoading: session.isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('New here?',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: JosiColors.muted)),
              TextButton(
                onPressed: () => context.go(AppRoutes.customerRegister),
                child: const Text('Register as customer'),
              ),
            ],
          ),
          Center(
            child: TextButton(
              onPressed: () => context.go(AppRoutes.riderRegister),
              child: const Text('Register as rider'),
            ),
          ),
        ],
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

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: JosiColors.redSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: JosiColors.red, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: JosiColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: JosiColors.muted),
        ],
      ),
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
