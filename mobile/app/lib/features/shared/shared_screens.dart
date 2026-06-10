import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<JosiNotification>> notifications =
        ref.watch(notificationsProvider);

    return AppScaffold(
      title: 'Notifications',
      subtitle: 'Trips, wallet, and account updates',
      navRole: role,
      selectedTab: 'notifications',
      child: AppScreenBody(
        children: <Widget>[
          const _FilterRow(
              filters: <String>['All', 'Trips', 'Wallet', 'Rider']),
          const SizedBox(height: 14),
          notifications.when(
            data: (List<JosiNotification> values) => values.isEmpty
                ? const EmptyState(
                    title: 'No notifications',
                    message: 'New updates will appear here.')
                : Column(
                    children: values
                        .map(
                          (JosiNotification notification) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AppCard(
                              color: notification.isRead
                                  ? JosiColors.white
                                  : JosiColors.redSoft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    notification.isRead
                                        ? Icons.notifications_none_rounded
                                        : Icons.notifications_active_rounded,
                                    color: notification.isRead
                                        ? JosiColors.muted
                                        : JosiColors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                            ),
                                            Text(
                                              notification.time,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: JosiColors.muted),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: JosiColors.muted),
                                        ),
                                        const SizedBox(height: 8),
                                        StatusBadge(label: notification.type),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Notifications unavailable',
                message: 'Please try again later.'),
            loading: () => const SizedBox(
                height: 220,
                child: LoadingState(label: 'Loading notifications')),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Support',
      subtitle: 'Help and safety',
      child: AppScreenBody(
        children: <Widget>[
          const SectionHeader(title: 'FAQ'),
          const _FaqCard(
              title: 'How do cash trips work?',
              body: 'Cash is recorded on the trip and reflected in receipts.'),
          const _FaqCard(
              title: 'Can I cancel a request?',
              body:
                  'Customers can cancel before pickup. Riders can decline before accepting.'),
          const _FaqCard(
              title: 'When are rider documents reviewed?',
              body:
                  'Most applications move through review after documents and vehicle details are complete.'),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Contact support',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const AppTextField(
                    label: 'Subject',
                    hintText: 'Trip payment issue',
                    icon: Icons.subject_rounded),
                const SizedBox(height: 12),
                const AppTextField(
                    label: 'Message',
                    hintText: 'Describe the issue',
                    icon: Icons.message_outlined,
                    maxLines: 4),
                const SizedBox(height: 14),
                AppButton(
                    label: 'Report issue',
                    icon: Icons.send_rounded,
                    onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            label: 'Emergency contact',
            icon: Icons.emergency_rounded,
            variant: AppButtonVariant.danger,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  Widget build(BuildContext context) {
    final String homeRoute = role == AppNavRole.customer
        ? AppRoutes.customerHome
        : AppRoutes.riderHome;

    return AppScaffold(
      title: 'Settings',
      subtitle: 'Account preferences',
      child: AppScreenBody(
        children: <Widget>[
          _SettingsItem(
              icon: Icons.person_rounded,
              label: 'Account',
              onTap: () => context.go(AppRoutes.editProfile)),
          _SettingsItem(
              icon: Icons.notifications_rounded,
              label: 'Notifications',
              onTap: () {}),
          _SettingsItem(
              icon: Icons.lock_rounded, label: 'Security', onTap: () {}),
          _SettingsItem(
              icon: Icons.privacy_tip_rounded,
              label: 'Privacy policy',
              onTap: () {}),
          _SettingsItem(
              icon: Icons.description_rounded,
              label: 'Terms and conditions',
              onTap: () {}),
          const SizedBox(height: 12),
          AppButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.danger,
            onPressed: () => context.go(AppRoutes.login),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Back to home',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(homeRoute),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Rik Space');
  final TextEditingController _phoneController =
      TextEditingController(text: '+234 801 234 5678');
  final TextEditingController _emailController =
      TextEditingController(text: 'rik@josi.ng');
  String _gender = 'Select';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('edit-profile-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _EditProfileHeader(
                    onBack: () {
                      if (GoRouter.of(context).canPop()) {
                        context.pop();
                        return;
                      }
                      context.go(AppRoutes.customerProfile);
                    },
                  ),
                  const SizedBox(height: 38),
                  const Center(
                    child: _EditProfilePhoto(name: 'Rik Space', size: 132),
                  ),
                  const SizedBox(height: 44),
                  _EditProfileField(
                    label: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 22),
                  _EditProfileField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('Change'),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _EditProfileField(
                    label: 'Email',
                    controller: _emailController,
                    readOnly: true,
                  ),
                  const SizedBox(height: 22),
                  _EditGenderField(
                    value: _gender,
                    onChanged: (String? value) =>
                        setState(() => _gender = value ?? _gender),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
          child: SizedBox(
            height: 62,
            child: ElevatedButton(
              key: const ValueKey<String>('profile-update-button'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: JosiColors.red,
                foregroundColor: JosiColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: JosiColors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              child: const Text('Update'),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: JosiColors.white,
          shape: const CircleBorder(
            side: BorderSide(color: JosiColors.line),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: const SizedBox.square(
              dimension: 50,
              child: Center(
                child: _SharedAssetIcon(
                  asset: AppAssets.arrowLeft,
                  color: JosiColors.ink,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Your Profile',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(width: 50),
      ],
    );
  }
}

class _EditProfilePhoto extends StatelessWidget {
  const _EditProfilePhoto({
    required this.name,
    required this.size,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((String part) => part.isEmpty ? '' : part[0].toUpperCase())
        .join();

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFFFFDAD8), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: JosiColors.white, width: 4),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            initials,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: JosiColors.red,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Positioned(
          right: -4,
          bottom: 8,
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            decoration: BoxDecoration(
              color: JosiColors.red,
              shape: BoxShape.circle,
              border: Border.all(color: JosiColors.white, width: 3),
            ),
            child: Icon(Icons.edit_outlined,
                color: JosiColors.white, size: size * 0.18),
          ),
        ),
      ],
    );
  }
}

class _EditProfileField extends StatelessWidget {
  const _EditProfileField({
    required this.label,
    required this.controller,
    this.trailing,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final Widget? trailing;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: JosiColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: readOnly ? JosiColors.softMuted : JosiColors.ink,
                  fontSize: 18,
                ),
            decoration: InputDecoration(
              filled: true,
              fillColor: JosiColors.white,
              suffixIcon: trailing == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        widthFactor: 1,
                        child: trailing,
                      ),
                    ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: JosiColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: JosiColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: JosiColors.red, width: 1.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditGenderField extends StatelessWidget {
  const _EditGenderField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Gender',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: JosiColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: JosiColors.red, size: 34),
            items: const <String>[
              'Select',
              'Female',
              'Male',
              'Prefer not to say'
            ]
                .map(
                  (String item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      value == 'Select' ? JosiColors.softMuted : JosiColors.ink,
                  fontSize: 18,
                ),
            decoration: InputDecoration(
              filled: true,
              fillColor: JosiColors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: JosiColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: JosiColors.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: JosiColors.red, width: 1.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SharedAssetIcon extends StatelessWidget {
  const _SharedAssetIcon({
    required this.asset,
    required this.color,
    required this.size,
  });

  final String asset;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filters});

  final List<String> filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters
            .map(
              (String label) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: label == 'All',
                  onSelected: (bool value) {},
                  label: Text(label),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 5),
            Text(body,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: JosiColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: <Widget>[
            Icon(icon, color: JosiColors.muted),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.titleSmall)),
            const Icon(Icons.chevron_right_rounded, color: JosiColors.muted),
          ],
        ),
      ),
    );
  }
}
