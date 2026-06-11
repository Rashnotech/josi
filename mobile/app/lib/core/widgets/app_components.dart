import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../constants/app_routes.dart';
import '../mock/josi_models.dart';
import '../theme/josi_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppNavRole { customer, rider }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? resolvedTap = isLoading ? null : onPressed;
    final Widget labelWidget = isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: Colors.white),
          )
        : Text(label, overflow: TextOverflow.ellipsis);

    if (variant == AppButtonVariant.secondary) {
      return OutlinedButton.icon(
        onPressed: resolvedTap,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: labelWidget,
      );
    }

    if (variant == AppButtonVariant.ghost) {
      return TextButton.icon(
        onPressed: resolvedTap,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: labelWidget,
      );
    }

    return ElevatedButton.icon(
      onPressed: resolvedTap,
      style: variant == AppButtonVariant.danger
          ? ElevatedButton.styleFrom(backgroundColor: JosiColors.redDark)
          : null,
      icon: icon == null || isLoading
          ? const SizedBox.shrink()
          : Icon(icon, size: 20),
      label: labelWidget,
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.hintText,
    super.key,
    this.controller,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.readOnly = false,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    required this.label,
    required this.hintText,
    super.key,
    this.controller,
    this.textInputAction,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Show password' : 'Hide password',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
        ),
      ),
    );
  }
}

class AppDropdown extends StatelessWidget {
  const AppDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.hintText,
    required this.onTap,
    super.key,
  });

  final String hintText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search_rounded, color: JosiColors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hintText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: JosiColors.muted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: JosiColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.color = JosiColors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: card,
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    super.key,
    this.color = JosiColors.info,
    this.softColor = JosiColors.infoSoft,
  });

  final String label;
  final Color color;
  final Color softColor;

  factory StatusBadge.forTrip(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return const StatusBadge(
            label: 'Active',
            color: JosiColors.info,
            softColor: JosiColors.infoSoft);
      case TripStatus.completed:
        return const StatusBadge(
            label: 'Completed',
            color: JosiColors.success,
            softColor: JosiColors.successSoft);
      case TripStatus.cancelled:
        return const StatusBadge(
            label: 'Cancelled',
            color: JosiColors.red,
            softColor: JosiColors.redSoft);
      case TripStatus.searching:
        return const StatusBadge(
            label: 'Searching',
            color: JosiColors.warning,
            softColor: JosiColors.warningSoft);
    }
  }

  factory StatusBadge.forDocument(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.notUploaded:
        return const StatusBadge(
            label: 'Not uploaded',
            color: JosiColors.muted,
            softColor: JosiColors.surfaceStrong);
      case DocumentStatus.pending:
        return const StatusBadge(
            label: 'Pending',
            color: JosiColors.warning,
            softColor: JosiColors.warningSoft);
      case DocumentStatus.verified:
        return const StatusBadge(
            label: 'Verified',
            color: JosiColors.success,
            softColor: JosiColors.successSoft);
      case DocumentStatus.rejected:
        return const StatusBadge(
            label: 'Rejected',
            color: JosiColors.red,
            softColor: JosiColors.redSoft);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.inbox_rounded,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 42, color: JosiColors.red),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: JosiColors.muted),
          ),
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Loading'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(color: JosiColors.red),
          const SizedBox(height: 12),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: JosiColors.muted)),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
        title: title, message: message, icon: Icons.error_outline_rounded);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({
    required this.trip,
    super.key,
    this.onTap,
    this.trailing,
  });

  final Trip trip;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(trip.id,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              trailing ?? StatusBadge.forTrip(trip.status),
            ],
          ),
          const SizedBox(height: 14),
          _RouteLine(pickup: trip.pickup, destination: trip.destination),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _FactChip(icon: Icons.payments_rounded, label: trip.fare),
              _FactChip(icon: Icons.route_rounded, label: trip.distance),
              Text(
                trip.dateLabel,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: JosiColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    required this.vehicle,
    super.key,
  });

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: JosiColors.charcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.directions_car_filled_rounded,
                  color: JosiColors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: JosiColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${vehicle.color} ${vehicle.type} • ${vehicle.plateNumber}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: JosiColors.softMuted),
          ),
          const SizedBox(height: 10),
          Text(
            'Chassis ${vehicle.chassisNumber}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: JosiColors.softMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    required this.title,
    required this.balance,
    super.key,
    this.subtitle,
    this.icon = Icons.account_balance_wallet_rounded,
  });

  final String title;
  final String balance;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: JosiColors.charcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: JosiColors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: JosiColors.white),
              ),
              const Spacer(),
              const StatusBadge(
                  label: 'Josi Wallet',
                  color: JosiColors.white,
                  softColor: Color(0x22FFFFFF)),
            ],
          ),
          const SizedBox(height: 22),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: JosiColors.softMuted)),
          const SizedBox(height: 6),
          Text(balance,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: JosiColors.white)),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: JosiColors.softMuted)),
          ],
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.name,
    super.key,
    this.size = 64,
    this.showEdit = false,
  });

  final String name;
  final double size;
  final bool showEdit;

  @override
  Widget build(BuildContext context) {
    final String initials = name
        .split(' ')
        .where((String part) => part.isNotEmpty)
        .take(2)
        .map((String part) => part.characters.first.toUpperCase())
        .join();

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: JosiColors.redSoft,
            shape: BoxShape.circle,
            border: Border.all(color: JosiColors.white, width: 3),
          ),
          child: Text(
            initials,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: JosiColors.red),
          ),
        ),
        if (showEdit)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                  color: JosiColors.red, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded,
                  color: JosiColors.white, size: 15),
            ),
          ),
      ],
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.navRole,
    this.selectedTab,
    this.actions = const <Widget>[],
    this.showBackButton = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final AppNavRole? navRole;
  final String? selectedTab;
  final List<Widget> actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final bool canPop = GoRouter.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackButton && canPop
            ? IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, overflow: TextOverflow.ellipsis),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: JosiColors.muted),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: navRole == null
          ? null
          : AppBottomNav(role: navRole!, selectedTab: selectedTab ?? 'home'),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.role,
    required this.selectedTab,
    super.key,
  });

  final AppNavRole role;
  final String selectedTab;

  @override
  Widget build(BuildContext context) {
    if (role == AppNavRole.customer) {
      return CustomerBottomNav(selectedTab: selectedTab);
    }

    const List<_NavDestination> destinations = <_NavDestination>[
      _NavDestination('home', 'Home', Icons.home_rounded, AppRoutes.riderHome),
      _NavDestination(
          'trips', 'Trips', Icons.route_rounded, AppRoutes.riderTrips),
      _NavDestination('wallet', 'Wallet', Icons.account_balance_wallet_rounded,
          AppRoutes.riderWallet),
      _NavDestination('notifications', 'Alerts', Icons.notifications_rounded,
          AppRoutes.riderNotifications),
      _NavDestination(
          'profile', 'Profile', Icons.person_rounded, AppRoutes.riderProfile),
    ];
    final int selectedIndex = destinations
        .indexWhere((_NavDestination item) => item.key == selectedTab);

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (int index) =>
          context.go(destinations[index].route),
      destinations: destinations
          .map(
            (_NavDestination item) => NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class CustomerBottomNav extends StatelessWidget {
  const CustomerBottomNav({
    required this.selectedTab,
    super.key,
  });

  final String selectedTab;

  @override
  Widget build(BuildContext context) {
    final String activeTab = switch (selectedTab) {
      'trips' => 'activity',
      'ride' => 'rides',
      _ => selectedTab,
    };

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: JosiColors.white,
        border: Border(top: BorderSide(color: JosiColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: <Widget>[
              _CustomerNavItem(
                tab: 'home',
                label: 'Home',
                asset: AppAssets.home,
                route: AppRoutes.customerHome,
                selectedTab: activeTab,
              ),
              _CustomerNavItem(
                tab: 'activity',
                label: 'Activity',
                asset: AppAssets.history,
                route: AppRoutes.customerTrips,
                selectedTab: activeTab,
              ),
              _CustomerNavItem(
                tab: 'rides',
                label: 'Rides',
                asset: AppAssets.bikeLane,
                route: AppRoutes.customerSelectLocation,
                selectedTab: activeTab,
              ),
              _CustomerNavItem(
                tab: 'profile',
                label: 'Profile',
                asset: AppAssets.profile,
                route: AppRoutes.customerProfile,
                selectedTab: activeTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppMapPlaceholder extends StatelessWidget {
  const AppMapPlaceholder({
    super.key,
    this.height = 260,
    this.title = 'Abuja route preview',
  });

  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: CustomPaint(painter: _MapPlaceholderPainter())),
            Positioned(
              left: 18,
              top: 18,
              child: StatusBadge(
                  label: title,
                  color: JosiColors.charcoal,
                  softColor: JosiColors.white),
            ),
            const Positioned(
              right: 28,
              top: 84,
              child: _MapMarker(icon: Icons.directions_car_filled_rounded),
            ),
            const Positioned(
              left: 78,
              bottom: 62,
              child: _MapMarker(
                  icon: Icons.person_pin_circle_rounded, color: JosiColors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentUploadCard extends StatelessWidget {
  const DocumentUploadCard({
    required this.document,
    super.key,
  });

  final DocumentRequirement document;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: JosiColors.redSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.upload_file_rounded, color: JosiColors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Text(document.title,
                            style: Theme.of(context).textTheme.titleMedium)),
                    StatusBadge.forDocument(document.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  document.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: JosiColors.muted),
                ),
                if (document.rejectionReason != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    document.rejectionReason!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: JosiColors.red),
                  ),
                ],
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonalIcon(
                    onPressed: () {},
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text('Upload'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
    this.color = JosiColors.red,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: JosiColors.muted)),
        ],
      ),
    );
  }
}

class AppScreenBody extends StatelessWidget {
  const AppScreenBody({
    required this.children,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(18, 8, 18, 24),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: children,
    );
  }
}

class _RouteLine extends StatelessWidget {
  const _RouteLine({
    required this.pickup,
    required this.destination,
  });

  final String pickup;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _RoutePoint(
            icon: Icons.radio_button_checked_rounded,
            label: pickup,
            color: JosiColors.success),
        const Padding(
          padding: EdgeInsets.only(left: 11),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
                height: 18,
                child: VerticalDivider(color: JosiColors.line, thickness: 1.4)),
          ),
        ),
        _RoutePoint(
            icon: Icons.location_on_rounded,
            label: destination,
            color: JosiColors.red),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: JosiColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: JosiColors.muted),
          const SizedBox(width: 5),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: JosiColors.ink)),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination(this.key, this.label, this.icon, this.route);

  final String key;
  final String label;
  final IconData icon;
  final String route;
}

class _CustomerNavItem extends StatelessWidget {
  const _CustomerNavItem({
    required this.tab,
    required this.label,
    required this.asset,
    required this.route,
    required this.selectedTab,
  });

  final String tab;
  final String label;
  final String asset;
  final String route;
  final String selectedTab;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = tab == selectedTab;
    final Color color = isSelected ? JosiColors.red : JosiColors.softMuted;

    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              asset,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    this.color = JosiColors.charcoal,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: JosiColors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withAlpha(46),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEAF2EE), BlendMode.src);
    final Paint park = Paint()..color = const Color(0xFFD9EEDC);
    final Paint road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint thin = Paint()
      ..color = JosiColors.mapLine
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final Paint route = Paint()
      ..color = JosiColors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.62, size.height * 0.08, 88, 82),
        const Radius.circular(18),
      ),
      park,
    );
    for (int index = 0; index < 7; index++) {
      final double y = size.height * (0.14 + index * 0.12);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 42), road);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 42), thin);
    }

    final Path path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.74)
      ..quadraticBezierTo(size.width * 0.34, size.height * 0.46,
          size.width * 0.54, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.72, size.height * 0.68,
          size.width * 0.78, size.height * 0.34);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
