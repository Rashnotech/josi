import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit profile',
      subtitle: 'Update account details',
      child: AppScreenBody(
        children: <Widget>[
          const Center(
              child:
                  ProfileAvatar(name: 'Rik Space', size: 92, showEdit: true)),
          const SizedBox(height: 22),
          const AppTextField(
              label: 'Name',
              hintText: 'Rik Space',
              icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Phone',
              hintText: '+234 801 234 5678',
              icon: Icons.phone_outlined),
          const SizedBox(height: 12),
          const AppTextField(
            label: 'Email',
            hintText: 'rik@josi.ng',
            icon: Icons.email_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 18),
          AppButton(
              label: 'Save changes',
              icon: Icons.save_rounded,
              onPressed: () {}),
        ],
      ),
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
