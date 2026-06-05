import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const String routeName = '/account';

  static Route<void> smoothRoute() {
    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return const AccountScreen();
      },
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final CurvedAnimation curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('account-screen'),
      backgroundColor: JosiColors.surface,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const _AccountHeader(),
                        const SizedBox(height: 24),
                        _AccountMenuItem(
                          icon: Icons.account_circle_outlined,
                          label: 'Profile',
                          onTap: () {},
                        ),
                        _AccountMenuItem(
                          icon: Icons.payment_rounded,
                          label: 'Payment',
                          onTap: () {},
                        ),
                        _AccountMenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Support',
                          onTap: () {},
                        ),
                        _AccountMenuItem(
                          icon: Icons.verified_user_outlined,
                          label: 'Safety',
                          onTap: () {},
                        ),
                        _AccountMenuItem(
                          icon: Icons.location_on_outlined,
                          label: 'Saved places',
                          onTap: () {},
                        ),
                        _AccountMenuItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () {},
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _AccountBottomNav(onHomeTap: () => _goHome(context)),
        ],
      ),
    );
  }

  void _goHome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushReplacementNamed('/home');
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Rik Space',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: JosiColors.black,
                      fontWeight: FontWeight.w800,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.star_rate_rounded, color: Color(0xFF07996D), size: 25),
                  const SizedBox(width: 5),
                  Text(
                    '5.00',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: JosiColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.info_outline_rounded, color: JosiColors.muted, size: 19),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        const _PhotoUploadButton(),
      ],
    );
  }
}

class _PhotoUploadButton extends StatelessWidget {
  const _PhotoUploadButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Upload profile picture',
      button: true,
      child: Material(
        color: JosiColors.surface,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 72,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Icon(Icons.camera_alt_rounded, color: JosiColors.black, size: 32),
                Positioned(
                  right: 16,
                  bottom: 18,
                  child: Icon(Icons.add_rounded, color: JosiColors.black, size: 17),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountMenuItem extends StatelessWidget {
  const _AccountMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 84,
            child: Row(
              children: <Widget>[
                Icon(icon, color: JosiColors.muted, size: 34),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: JosiColors.ink,
                          fontWeight: FontWeight.w500,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: JosiColors.muted, size: 34),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: JosiColors.line),
      ],
    );
  }
}

class _AccountBottomNav extends StatelessWidget {
  const _AccountBottomNav({required this.onHomeTap});

  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _AccountNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
                onTap: onHomeTap,
              ),
            ),
            Expanded(
              child: _AccountNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Rides',
                selected: false,
                onTap: () {},
              ),
            ),
            Expanded(
              child: _AccountNavItem(
                icon: Icons.account_circle_rounded,
                label: 'Account',
                selected: true,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountNavItem extends StatelessWidget {
  const _AccountNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? JosiColors.black : JosiColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 5),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
