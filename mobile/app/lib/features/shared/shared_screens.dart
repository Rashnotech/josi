import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final List<String> filters = widget.role == AppNavRole.customer
        ? const <String>['All', 'Trips']
        : const <String>['All', 'Trips', 'Wallet', 'Rider'];

    final AsyncValue<List<JosiNotification>> notifications =
        widget.role == AppNavRole.customer
            ? ref
                .watch(customerTripsProvider)
                .whenData(_notificationsFromCustomerTrips)
            : ref.watch(notificationsProvider);

    return AppScaffold(
      title: 'Notifications',
      subtitle: 'Trips, wallet, and account updates',
      navRole: widget.role,
      selectedTab: 'notifications',
      child: AppScreenBody(
        children: <Widget>[
          _FilterRow(
            filters: filters,
            selected: _selectedFilter,
            onSelected: (String filter) =>
                setState(() => _selectedFilter = filter),
          ),
          const SizedBox(height: 14),
          notifications.when(
            data: (List<JosiNotification> values) {
              final List<JosiNotification> filtered = _selectedFilter == 'All'
                  ? values
                  : values
                      .where(
                          (JosiNotification item) => item.type == _selectedFilter)
                      .toList();
              return filtered.isEmpty
                  ? const EmptyState(
                      title: 'No notifications',
                      message: 'New updates will appear here.')
                  : Column(
                      children: filtered
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
                    );
            },
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
        'Booking details appear in Bookings after a ride is confirmed and remain available from the trip card.',
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
    answer: 'Open Bookings to review scheduled and completed rides.',
  ),
];

const List<_HelpContactItem> _helpContactItems = <_HelpContactItem>[
  _HelpContactItem(
    label: 'Customer Service',
    icon: Icons.headset_mic_rounded,
    detail: '+234 9162599418',
  ),
  _HelpContactItem(
    label: 'WhatsApp',
    icon: Icons.chat_bubble_outline_rounded,
    detail: '(480) 555-0103',
    expanded: true,
  ),
  _HelpContactItem(
    label: 'Website',
    icon: Icons.language_rounded,
    detail: 'jositransport.com',
  ),
  _HelpContactItem(
    label: 'Email',
    icon: Icons.email_outlined,
    detail: 'support@jositransport.com',
  ),
  _HelpContactItem(
    label: 'Facebook',
    icon: Icons.facebook_rounded,
    detail: 'Josi Ride',
  ),
  _HelpContactItem(
    label: 'Twitter',
    icon: Icons.alternate_email_rounded,
    detail: 'Josi Ride',
  ),
  _HelpContactItem(
    label: 'Instagram',
    icon: Icons.camera_alt_rounded,
    detail: 'Josi Ride',
  ),
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
                    titleFontSize: 18,
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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({
    required this.role,
    super.key,
  });

  final AppNavRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        onTap: () => _openPasswordManager(context),
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

  void _openPasswordManager(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return const _PasswordManagerSheet();
      },
    );
  }
}

class _PasswordManagerSheet extends ConsumerStatefulWidget {
  const _PasswordManagerSheet();

  @override
  ConsumerState<_PasswordManagerSheet> createState() =>
      _PasswordManagerSheetState();
}

class _PasswordManagerSheetState extends ConsumerState<_PasswordManagerSheet> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _loading = false;
  String? _message;
  Map<String, String> _errors = const <String, String>{};

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }

    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmation = _confirmPasswordController.text;
    final Map<String, String> errors = <String, String>{};
    if (currentPassword.isEmpty) {
      errors['current_password'] = 'Enter your current password.';
    }
    if (newPassword.isEmpty) {
      errors['password'] = 'Enter a new password.';
    }
    if (confirmation.isEmpty) {
      errors['password_confirmation'] = 'Confirm your new password.';
    } else if (newPassword != confirmation) {
      errors['password_confirmation'] = 'Passwords do not match.';
    }

    setState(() {
      _errors = errors;
      _message = null;
    });
    if (errors.isNotEmpty) {
      return;
    }

    setState(() => _loading = true);
    try {
      final String message =
          await ref.read(authRepositoryProvider).changePassword(
                currentPassword: currentPassword,
                password: newPassword,
                passwordConfirmation: confirmation,
              );
      if (!mounted) {
        return;
      }
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = _settingsErrorMessage(error, 'Unable to update password.');
          _errors = _settingsFieldErrors(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        key: const ValueKey<String>('password-manager-sheet'),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
        decoration: const BoxDecoration(
          color: JosiColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                child: Container(
                  width: 86,
                  height: 4,
                  decoration: BoxDecoration(
                    color: JosiColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Password Manager',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 18),
              if (_message != null) ...<Widget>[
                _SettingsInlineMessage(message: _message!),
                const SizedBox(height: 14),
              ],
              _SettingsPasswordField(
                key: const ValueKey<String>('current-password-update-field'),
                label: 'Current Password',
                controller: _currentPasswordController,
                errorText: _errors['current_password'],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              _SettingsPasswordField(
                key: const ValueKey<String>('new-password-update-field'),
                label: 'New Password',
                controller: _newPasswordController,
                errorText: _errors['password'],
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              _SettingsPasswordField(
                key: const ValueKey<String>('confirm-password-update-field'),
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                errorText: _errors['password_confirmation'],
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  key: const ValueKey<String>('password-manager-submit'),
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JosiColors.red,
                    foregroundColor: JosiColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: JosiColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  child: _loading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: JosiColors.white,
                          ),
                        )
                      : const Text('Update Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsPasswordField extends StatefulWidget {
  const _SettingsPasswordField({
    required this.label,
    required this.controller,
    super.key,
    this.errorText,
    this.textInputAction,
  });

  final String label;
  final TextEditingController controller;
  final String? errorText;
  final TextInputAction? textInputAction;

  @override
  State<_SettingsPasswordField> createState() => _SettingsPasswordFieldState();
}

class _SettingsPasswordFieldState extends State<_SettingsPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: JosiColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            textInputAction: widget.textInputAction,
            decoration: InputDecoration(
              filled: true,
              fillColor: JosiColors.white,
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: JosiColors.softMuted,
                  size: 20,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
        if (widget.errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: JosiColors.redDark,
                  fontSize: 12,
                  height: 1.2,
                ),
          ),
        ],
      ],
    );
  }
}

class _SettingsInlineMessage extends StatelessWidget {
  const _SettingsInlineMessage({
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final Color accent = isError ? JosiColors.redDark : JosiColors.success;
    final Color background =
        isError ? const Color(0xFFFFF1F2) : const Color(0xFFEFFAF3);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: accent,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: accent,
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

String _settingsErrorMessage(Object error, String fallback) {
  if (error is ApiException) {
    final Object? first =
        error.errors.values.isEmpty ? null : error.errors.values.first;
    if (first is List<Object?> && first.isNotEmpty) {
      return '${first.first}';
    }
    return error.message;
  }

  return fallback;
}

Map<String, String> _settingsFieldErrors(Object error) {
  if (error is! ApiException || error.errors.isEmpty) {
    return const <String, String>{};
  }

  return error.errors.map((String key, Object? value) {
    if (value is List && value.isNotEmpty) {
      return MapEntry<String, String>(key, '${value.first}');
    }
    return MapEntry<String, String>(key, '$value');
  });
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _gender = 'Select';
  bool _hydrated = false;
  bool _saving = false;
  Map<String, String> _errors = const <String, String>{};
  String? _message;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) {
      return;
    }

    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final Map<String, String> errors = <String, String>{};
    if (name.isEmpty) {
      errors['name'] = 'Enter your name.';
    }
    if (phone.isEmpty) {
      errors['phone'] = 'Enter your phone number.';
    }
    if (email.isEmpty) {
      errors['email'] = 'Enter your email address.';
    } else if (!email.contains('@')) {
      errors['email'] = 'Enter a valid email address.';
    }

    setState(() {
      _errors = errors;
      _message = null;
    });
    if (errors.isNotEmpty) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(customerRepositoryProvider).updateProfile(
            name: name,
            phone: phone,
            email: email,
            gender: _gender,
          );
      ref.invalidate(currentCustomerProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      context.go(AppRoutes.customerProfile);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _message = _settingsErrorMessage(error, 'Unable to update profile.');
          _errors = _settingsFieldErrors(error);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<JosiUser> user = ref.watch(currentCustomerProvider);
    final JosiUser? profile = user.value;
    if (!_hydrated && profile != null) {
      _nameController.text = profile.displayName;
      _phoneController.text = profile.phone;
      _emailController.text = profile.email;
      _gender = (profile.gender?.trim().isNotEmpty ?? false)
          ? profile.gender!
          : 'Select';
      _hydrated = true;
    }

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
                  Center(
                    child: _EditProfilePhoto(
                      name: profile?.displayName ?? 'Josi customer',
                      size: 132,
                    ),
                  ),
                  const SizedBox(height: 44),
                  _EditProfileField(
                    label: 'Name',
                    controller: _nameController,
                    errorText: _errors['name'],
                  ),
                  const SizedBox(height: 22),
                  _EditProfileField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    errorText: _errors['phone'],
                  ),
                  const SizedBox(height: 22),
                  _EditProfileField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    errorText: _errors['email'],
                  ),
                  const SizedBox(height: 22),
                  _EditGenderField(
                    value: _gender,
                    onChanged: (String? value) =>
                        setState(() => _gender = value ?? _gender),
                  ),
                  if (_message != null) ...<Widget>[
                    const SizedBox(height: 18),
                    _SettingsInlineMessage(
                      message: _message!,
                      isError: true,
                    ),
                  ],
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
              onPressed: _saving ? null : _submit,
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
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: JosiColors.white,
                      ),
                    )
                  : const Text('Update'),
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
    this.keyboardType,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? errorText;

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
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.ink,
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
              errorText: errorText,
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
  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

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
                  key: ValueKey<String>(
                      'notification-filter-${label.toLowerCase()}'),
                  selected: label == selected,
                  onSelected: (bool value) => onSelected(label),
                  label: Text(label),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

List<JosiNotification> _notificationsFromCustomerTrips(List<Trip> trips) {
  final List<Trip> relevant = trips
      .where((Trip trip) =>
          trip.status == TripStatus.completed ||
          trip.status == TripStatus.cancelled)
      .toList()
    ..sort((Trip a, Trip b) {
      final DateTime? aTime = a.completedAt ?? a.cancelledAt ?? a.requestedAt;
      final DateTime? bTime = b.completedAt ?? b.cancelledAt ?? b.requestedAt;
      if (aTime == null || bTime == null) {
        return 0;
      }
      return bTime.compareTo(aTime);
    });

  return relevant.map((Trip trip) {
    final bool isCancelled = trip.status == TripStatus.cancelled;
    return JosiNotification(
      title: isCancelled ? 'Trip cancelled' : 'Trip completed',
      body: isCancelled
          ? 'Your trip from ${trip.pickup} to ${trip.destination} was cancelled.'
          : 'Your trip from ${trip.pickup} to ${trip.destination} is complete. '
              '${trip.fare} - ${_paymentMethodLabel(trip.paymentMethod)}.',
      type: 'Trips',
      time: trip.dateLabel,
      isRead: true,
    );
  }).toList();
}

String _paymentMethodLabel(PaymentMethod method) => switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.online => 'Online',
      PaymentMethod.wallet => 'Wallet',
    };

class _ReferenceHeader extends StatelessWidget {
  const _ReferenceHeader({
    required this.title,
    required this.backKey,
    required this.onBack,
    this.titleFontSize = 20,
  });

  final String title;
  final String backKey;
  final VoidCallback onBack;
  final double titleFontSize;

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
                  fontSize: titleFontSize,
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
      height: 52,
      child: TextField(
        key: const ValueKey<String>('help-search-field'),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 15,
              ),
          prefixIcon:
              const Icon(Icons.search_rounded, color: JosiColors.red, size: 24),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: JosiColors.ink,
              fontSize: 15,
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
        height: 52,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(
              child: Text(
                tab.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? JosiColors.red : JosiColors.muted,
                      fontSize: 15,
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
          height: 44,
          constraints: const BoxConstraints(minWidth: 80),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            category.label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? JosiColors.white : JosiColors.softMuted,
                  fontSize: 14,
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
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: JosiColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  item.expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: JosiColors.red,
                  size: 26,
                ),
              ],
            ),
          ),
          if (item.expanded) ...<Widget>[
            const Divider(height: 1, color: JosiColors.line),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 17),
              child: Text(
                item.answer,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 14,
                      height: 1.35,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HelpContactList extends StatefulWidget {
  const _HelpContactList({super.key});

  @override
  State<_HelpContactList> createState() => _HelpContactListState();
}

class _HelpContactListState extends State<_HelpContactList> {
  final Set<String> _expandedItems = _helpContactItems
      .where((_HelpContactItem item) => item.expanded)
      .map((_HelpContactItem item) => item.label)
      .toSet();

  void _toggle(_HelpContactItem item) {
    if (item.detail == null) {
      return;
    }
    setState(() {
      if (!_expandedItems.remove(item.label)) {
        _expandedItems.add(item.label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      children: <Widget>[
        for (final _HelpContactItem item in _helpContactItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _HelpContactCard(
              item: item,
              expanded: _expandedItems.contains(item.label),
              onTap: () => _toggle(item),
            ),
          ),
      ],
    );
  }
}

class _HelpContactCard extends StatelessWidget {
  const _HelpContactCard({
    required this.item,
    required this.expanded,
    required this.onTap,
  });

  final _HelpContactItem item;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('help-contact-${item.label.toLowerCase()}'),
      decoration: BoxDecoration(
        color: JosiColors.white,
        border: Border.all(color: JosiColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
              child: Row(
                children: <Widget>[
                  Icon(item.icon, color: JosiColors.red, size: 28),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: JosiColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: JosiColors.ink,
                    size: 26,
                  ),
                ],
              ),
            ),
            if (expanded && item.detail != null) ...<Widget>[
              const Padding(
                padding: EdgeInsets.only(left: 64, right: 18),
                child: Divider(height: 1, color: JosiColors.line),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(64, 12, 18, 18),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: JosiColors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.detail!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 14,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
