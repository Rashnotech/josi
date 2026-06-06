import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _pages.length - 1) {
      context.go(AppRoutes.roleSelection);
      return;
    }
    _controller.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('onboarding-screen'),
      backgroundColor: JosiColors.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.roleSelection),
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (int value) => setState(() => _index = value),
                itemBuilder: (BuildContext context, int index) {
                  final _OnboardingPage page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: _OnboardingVisual(
                              icon: page.icon, accent: page.accent),
                        ),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: JosiColors.muted),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (int dot = 0; dot < _pages.length; dot++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: dot == _index ? 26 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: dot == _index
                                ? JosiColors.red
                                : JosiColors.line,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                      label:
                          _index == _pages.length - 1 ? 'Choose role' : 'Next',
                      onPressed: _next),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingVisual extends StatelessWidget {
  const _OnboardingVisual({
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 230,
        height: 230,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(199),
                shape: BoxShape.circle,
              ),
            ),
            Icon(icon, size: 86, color: JosiColors.red),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;
}

const List<_OnboardingPage> _pages = <_OnboardingPage>[
  _OnboardingPage(
    title: 'Fast city rides and deliveries',
    body:
        'Move across town, send packages, and keep every trip visible from one clean app.',
    icon: Icons.local_taxi_rounded,
    accent: JosiColors.redSoft,
  ),
  _OnboardingPage(
    title: 'Trusted riders near you',
    body:
        'See rider details, vehicle information, status updates, and support when it matters.',
    icon: Icons.verified_user_rounded,
    accent: JosiColors.infoSoft,
  ),
  _OnboardingPage(
    title: 'Cash, wallet, or online payment',
    body:
        'Choose the payment option that fits each trip, including cash support for local routes.',
    icon: Icons.account_balance_wallet_rounded,
    accent: JosiColors.warningSoft,
  ),
  _OnboardingPage(
    title: 'Earn with Josi',
    body:
        'Riders and fleet partners get clear trip requests, earnings, documents, and remittance tools.',
    icon: Icons.delivery_dining_rounded,
    accent: JosiColors.successSoft,
  ),
];
