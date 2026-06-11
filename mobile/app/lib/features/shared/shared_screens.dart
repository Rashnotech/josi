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

enum _HelpCenterTab {
  faq('FAQ'),
  contactUs('Contact Us');

  const _HelpCenterTab(this.label);

  final String label;

  String get key => switch (this) {
        _HelpCenterTab.faq => 'help-tab-faq',
        _HelpCenterTab.contactUs => 'help-tab-contact-us',
      };
}

enum _HelpFaqCategory {
  all('All'),
  services('Services'),
  general('General'),
  account('Account');

  const _HelpFaqCategory(this.label);

  final String label;
}

class _HelpFaqItem {
  const _HelpFaqItem({
    required this.question,
    required this.answer,
    this.expanded = false,
  });

  final String question;
  final String answer;
  final bool expanded;
}

class _HelpContactItem {
  const _HelpContactItem({
    required this.label,
    required this.icon,
    this.detail,
    this.expanded = false,
  });

  final String label;
  final IconData icon;
  final String? detail;
  final bool expanded;
}

const List<_HelpFaqItem> _helpFaqItems = <_HelpFaqItem>[
  _HelpFaqItem(
    question: 'What if I need to cancel a booking?',
    answer:
        'You can cancel before pickup from the booking details. Any cash trip record stays attached to the ride history.',
    expanded: true,
  ),
  _HelpFaqItem(
    question: 'Is safe to use App?',
    answer:
        'Josi keeps profile, trip, and payment records in the app so support can review every ride clearly.',
  ),
  _HelpFaqItem(
    question: 'How do I receive Booking Details?',
    answer:
        'Booking details appear in Activity after a ride is confirmed and remain available from the trip card.',
  ),
  _HelpFaqItem(
    question: 'How can I edit my profile information?',
    answer:
        'Open Profile, tap Your profile, then update your name, phone number, email, or gender.',
  ),
  _HelpFaqItem(
    question: 'How to cancel Taxi?',
    answer:
        'Open the active booking and use the available cancel action before the driver arrives.',
  ),
  _HelpFaqItem(
    question: 'Is Voice call or Chat Feature there?',
    answer:
        'The active trip screen includes call and message actions for reaching your driver.',
  ),
  _HelpFaqItem(
    question: 'How to see pre-booked Taxi?',
    answer: 'Open Profile, then Pre-Booked Rides to review scheduled bookings.',
  ),
];

const List<_HelpContactItem> _helpContactItems = <_HelpContactItem>[
  _HelpContactItem(label: 'Customer Service', icon: Icons.headset_mic_rounded),
  _HelpContactItem(
    label: 'WhatsApp',
    icon: Icons.chat_bubble_outline_rounded,
    detail: '(480) 555-0103',
    expanded: true,
  ),
  _HelpContactItem(label: 'Website', icon: Icons.language_rounded),
  _HelpContactItem(label: 'Facebook', icon: Icons.facebook_rounded),
  _HelpContactItem(label: 'Twitter', icon: Icons.alternate_email_rounded),
  _HelpContactItem(label: 'Instagram', icon: Icons.camera_alt_rounded),
];

String _profileRouteForRole(AppNavRole role) => role == AppNavRole.customer
    ? AppRoutes.customerProfile
    : AppRoutes.riderProfile;

class SupportScreen extends StatefulWidget {
  const SupportScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  _HelpCenterTab _selectedTab = _HelpCenterTab.faq;
  _HelpFaqCategory _selectedCategory = _HelpFaqCategory.all;

  void _selectTab(_HelpCenterTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _selectCategory(_HelpFaqCategory category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('help-center-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _ReferenceHeader(
                    title: 'Help Center',
                    backKey: 'help-center-back-button',
                    onBack: () => context.go(_profileRouteForRole(widget.role)),
                  ),
                ),
                const SizedBox(height: 34),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _HelpSearchField(),
                ),
                const SizedBox(height: 24),
                _HelpTabMenu(
                  selectedTab: _selectedTab,
                  onSelected: _selectTab,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: _selectedTab == _HelpCenterTab.faq
                        ? _HelpFaqList(
                            key: const ValueKey<String>('help-faq-list'),
                            selectedCategory: _selectedCategory,
                            onCategorySelected: _selectCategory,
                          )
                        : const _HelpContactList(
                            key: ValueKey<String>('help-contact-list'),
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

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('settings-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _ReferenceHeader(
                    title: 'Settings',
                    backKey: 'settings-back-button',
                    onBack: () => context.go(_profileRouteForRole(role)),
                  ),
                ),
                const SizedBox(height: 54),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: <Widget>[
                      _SettingsMenuRow(
                        key: const ValueKey<String>(
                            'settings-item-notifications'),
                        icon: Icons.notifications_none_rounded,
                        label: 'Notification Settings',
                        onTap: () {},
                      ),
                      const _SettingsDivider(),
                      _SettingsMenuRow(
                        key: const ValueKey<String>(
                            'settings-item-password-manager'),
                        icon: Icons.key_rounded,
                        label: 'Password Manager',
                        onTap: () {},
                      ),
                      const _SettingsDivider(),
                      _SettingsMenuRow(
                        key: const ValueKey<String>(
                            'settings-item-delete-account'),
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete Account',
                        onTap: () {},
                      ),
                    ],
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
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 18),
          child: SizedBox(
            height: 52,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
              dimension: 42,
              child: Center(
                child: _SharedAssetIcon(
                  asset: AppAssets.arrowLeft,
                  color: JosiColors.ink,
                  size: 19,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 42),
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

class _ReferenceHeader extends StatelessWidget {
  const _ReferenceHeader({
    required this.title,
    required this.backKey,
    required this.onBack,
  });

  final String title;
  final String backKey;
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
            key: ValueKey<String>(backKey),
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.arrowLeft,
                  width: 19,
                  height: 19,
                  colorFilter:
                      const ColorFilter.mode(JosiColors.ink, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 44),
      ],
    );
  }
}

class _SettingsMenuRow extends StatelessWidget {
  const _SettingsMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: Row(
          children: <Widget>[
            Icon(icon, color: JosiColors.red, size: 32),
            const SizedBox(width: 22),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: JosiColors.red,
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: JosiColors.line);
  }
}

class _HelpSearchField extends StatelessWidget {
  const _HelpSearchField();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        key: const ValueKey<String>('help-search-field'),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 18,
              ),
          prefixIcon:
              const Icon(Icons.search_rounded, color: JosiColors.red, size: 30),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: JosiColors.ink,
              fontSize: 18,
            ),
      ),
    );
  }
}

class _HelpTabMenu extends StatelessWidget {
  const _HelpTabMenu({
    required this.selectedTab,
    required this.onSelected,
  });

  final _HelpCenterTab selectedTab;
  final ValueChanged<_HelpCenterTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: JosiColors.line)),
      ),
      child: Row(
        children: <Widget>[
          for (final _HelpCenterTab tab in _HelpCenterTab.values)
            Expanded(
              child: _HelpTabButton(
                tab: tab,
                selected: tab == selectedTab,
                onTap: () => onSelected(tab),
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpTabButton extends StatelessWidget {
  const _HelpTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _HelpCenterTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>(tab.key),
      onTap: onTap,
      child: SizedBox(
        height: 60,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(
              child: Text(
                tab.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? JosiColors.red : JosiColors.muted,
                      fontSize: 17,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: selected ? 178 : 0,
              height: 4,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpFaqList extends StatelessWidget {
  const _HelpFaqList({
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  final _HelpFaqCategory selectedCategory;
  final ValueChanged<_HelpFaqCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      children: <Widget>[
        _HelpFaqCategories(
          selectedCategory: selectedCategory,
          onSelected: onCategorySelected,
        ),
        const SizedBox(height: 22),
        for (final _HelpFaqItem item in _helpFaqItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HelpFaqCard(item: item),
          ),
      ],
    );
  }
}

class _HelpFaqCategories extends StatelessWidget {
  const _HelpFaqCategories({
    required this.selectedCategory,
    required this.onSelected,
  });

  final _HelpFaqCategory selectedCategory;
  final ValueChanged<_HelpFaqCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final _HelpFaqCategory category in _HelpFaqCategory.values)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _HelpCategoryChip(
                category: category,
                selected: category == selectedCategory,
                onTap: () => onSelected(category),
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpCategoryChip extends StatelessWidget {
  const _HelpCategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _HelpFaqCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? JosiColors.red : const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: ValueKey<String>(
            'help-faq-category-${category.label.toLowerCase()}'),
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 52,
          constraints: const BoxConstraints(minWidth: 90),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Text(
            category.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? JosiColors.white : JosiColors.softMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _HelpFaqCard extends StatelessWidget {
  const _HelpFaqCard({required this.item});

  final _HelpFaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JosiColors.white,
        border: Border.all(color: JosiColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: JosiColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  item.expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: JosiColors.red,
                  size: 30,
                ),
              ],
            ),
          ),
          if (item.expanded) ...<Widget>[
            const Divider(height: 1, color: JosiColors.line),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Text(
                item.answer,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 16,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpContactList extends StatelessWidget {
  const _HelpContactList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      children: <Widget>[
        for (final _HelpContactItem item in _helpContactItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HelpContactCard(item: item),
          ),
      ],
    );
  }
}

class _HelpContactCard extends StatelessWidget {
  const _HelpContactCard({required this.item});

  final _HelpContactItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('help-contact-${item.label.toLowerCase()}'),
      decoration: BoxDecoration(
        color: JosiColors.white,
        border: Border.all(color: JosiColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            child: Row(
              children: <Widget>[
                Icon(item.icon, color: JosiColors.red, size: 34),
                const SizedBox(width: 22),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  item.expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: JosiColors.ink,
                  size: 30,
                ),
              ],
            ),
          ),
          if (item.expanded && item.detail != null) ...<Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 86, right: 22),
              child: Divider(height: 1, color: JosiColors.line),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(86, 14, 22, 22),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: JosiColors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.detail!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 16,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
