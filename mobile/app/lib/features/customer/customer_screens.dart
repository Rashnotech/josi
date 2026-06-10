import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_mock_data.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<JosiUser> user = ref.watch(currentCustomerProvider);
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);
    final String firstName = user.maybeWhen(
      data: (JosiUser value) => value.name.split(' ').first,
      orElse: () => 'there',
    );
    final Trip lastTrip = trips.maybeWhen(
      data: (List<Trip> values) =>
          values.isEmpty ? JosiMockData.trips.first : values.first,
      orElse: () => JosiMockData.trips.first,
    );

    return Scaffold(
      key: const ValueKey<String>('customer-home-screen'),
      backgroundColor: JosiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double mapHeight = (constraints.maxHeight * 0.32)
                    .clamp(226.0, 292.0)
                    .toDouble();

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _HomeHeader(
                        firstName: firstName,
                        onNotifications: () =>
                            context.go(AppRoutes.customerNotifications),
                      ),
                      const SizedBox(height: 8),
                      _HomeMapSection(
                        mapHeight: mapHeight,
                        lastTrip: lastTrip,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _CustomerFixedBottomNav(selectedTab: 'home'),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.firstName,
    required this.onNotifications,
  });

  final String firstName;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _SoftIconButton(
          onTap: () {},
          child:
              const Icon(Icons.menu_rounded, color: JosiColors.red, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Hi, $firstName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        _SoftIconButton(
          onTap: onNotifications,
          child: const _AssetIcon(
            asset: AppAssets.notification,
            color: JosiColors.red,
            size: 17,
          ),
        ),
      ],
    );
  }
}

class _HomeMapSection extends StatelessWidget {
  const _HomeMapSection({
    required this.mapHeight,
    required this.lastTrip,
  });

  final double mapHeight;
  final Trip lastTrip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mapHeight + 258,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AppMapPlaceholder(
              height: mapHeight,
              title: 'City route preview',
            ),
          ),
          const Positioned(
            left: 10,
            right: 10,
            top: 10,
            child: _CurrentLocationBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: mapHeight - 28,
            child: _WhereToPanel(lastTrip: lastTrip),
          ),
        ],
      ),
    );
  }
}

class _CurrentLocationBar extends StatelessWidget {
  const _CurrentLocationBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: JosiColors.line),
      ),
      child: Row(
        children: <Widget>[
          const _AssetIcon(
            asset: AppAssets.location,
            color: JosiColors.red,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Current Location',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: JosiColors.muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
            ),
          ),
          const Icon(Icons.bookmark_border_rounded,
              color: JosiColors.red, size: 18),
        ],
      ),
    );
  }
}

class _WhereToPanel extends StatelessWidget {
  const _WhereToPanel({required this.lastTrip});

  final Trip lastTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: JosiColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Where to?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.customerTrips),
                child: const Text('MANAGE'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _HomePlaceTile(
                  key: const ValueKey<String>('home-destination-tile'),
                  title: 'Destination',
                  subtitle: 'Enter Destination',
                  asset: AppAssets.location,
                  isPrimary: true,
                  onTap: () => context.go(AppRoutes.customerSelectLocation),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HomePlaceTile(
                  title: 'Office',
                  subtitle: '35 KM Away',
                  asset: AppAssets.card,
                  onTap: () => context.go(AppRoutes.customerSelectLocation),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LastTripTile(trip: lastTrip),
        ],
      ),
    );
  }
}

class CustomerBookTripScreen extends StatelessWidget {
  const CustomerBookTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Book a trip',
      subtitle: 'Ride or package delivery',
      child: AppScreenBody(
        children: <Widget>[
          const AppMapPlaceholder(height: 220),
          const SizedBox(height: 16),
          const AppTextField(
              label: 'Pickup',
              hintText: 'Wuse 2, Abuja',
              icon: Icons.radio_button_checked_rounded),
          const SizedBox(height: 12),
          const AppTextField(
              label: 'Destination',
              hintText: 'Jabi Lake Mall',
              icon: Icons.location_on_rounded),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: <Widget>[
                const Icon(Icons.inventory_2_rounded, color: JosiColors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Package delivery uses the same confirmation flow with pickup and recipient destination.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: JosiColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go(AppRoutes.customerConfirmTrip),
          ),
        ],
      ),
    );
  }
}

class CustomerSelectLocationScreen extends StatelessWidget {
  const CustomerSelectLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-destination-screen'),
      backgroundColor: JosiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _DestinationHeader(
                    onBack: () => context.go(AppRoutes.customerHome),
                  ),
                  const SizedBox(height: 42),
                  const _DestinationRouteCard(),
                  const SizedBox(height: 28),
                  _SavedPlacesCard(
                    onTap: () => context.go(AppRoutes.customerProfile),
                  ),
                  const SizedBox(height: 28),
                  for (final String location in const <String>[
                    '2118 Thornridge Cir. Syracuse, C...',
                    '4517 Washington Ave. Manche...',
                    '2715 Ash Dr. San Jose, South Da...',
                  ]) ...<Widget>[
                    _RecentDestinationTile(location: location),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _DestinationBottomBar(
        onConfirm: () => context.go(AppRoutes.customerConfirmTrip),
      ),
    );
  }
}

class _HomePlaceTile extends StatelessWidget {
  const _HomePlaceTile({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.onTap,
    super.key,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final Color background = isPrimary ? JosiColors.red : JosiColors.surface;
    final Color foreground = isPrimary ? JosiColors.white : JosiColors.ink;
    final Color muted =
        isPrimary ? JosiColors.white.withValues(alpha: 0.82) : JosiColors.muted;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border:
                Border.all(color: isPrimary ? JosiColors.red : JosiColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 31,
                height: 31,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? JosiColors.white.withValues(alpha: 0.18)
                      : JosiColors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _AssetIcon(asset: asset, color: foreground, size: 17),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastTripTile extends StatelessWidget {
  const _LastTripTile({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF8F8),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => context.go(AppRoutes.customerTripDetailPath(trip.id)),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: JosiColors.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.history_rounded,
                  color: JosiColors.red, size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Last Trip',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: JosiColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: JosiColors.muted,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: JosiColors.muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationHeader extends StatelessWidget {
  const _DestinationHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _SoftIconButton(
          onTap: onBack,
          child: const _AssetIcon(
            asset: AppAssets.arrowLeft,
            color: JosiColors.redDark,
            size: 22,
          ),
        ),
        Expanded(
          child: Text(
            'Destination',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: JosiColors.redDark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _DestinationRouteCard extends StatelessWidget {
  const _DestinationRouteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: JosiColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _DestinationRail(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: <Widget>[
                const _DestinationInputLine(
                  text: '6391 Elgin St. Celina, Delawa...',
                  isFilled: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: _DestinationInputLine(
                        text: '1901 Thornridge Cir. Sh...',
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.map_outlined,
                        color: JosiColors.red, size: 24),
                    const SizedBox(width: 12),
                    IconButton(
                      constraints:
                          const BoxConstraints.tightFor(width: 34, height: 34),
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(Icons.add_rounded,
                          color: JosiColors.red, size: 27),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationRail extends StatelessWidget {
  const _DestinationRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 86,
      child: Column(
        children: <Widget>[
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: JosiColors.red, width: 3),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: JosiColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Expanded(
            child: CustomPaint(
              painter: _DashedLinePainter(color: JosiColors.outline),
              child: SizedBox(width: 1),
            ),
          ),
          const _AssetIcon(
            asset: AppAssets.location,
            color: JosiColors.red,
            size: 25,
          ),
        ],
      ),
    );
  }
}

class _DestinationInputLine extends StatelessWidget {
  const _DestinationInputLine({
    required this.text,
    this.isFilled = false,
  });

  final String text;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFFF0F1F4) : JosiColors.white,
        border: const Border(
          bottom: BorderSide(color: JosiColors.ink, width: 1),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: JosiColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

class _SavedPlacesCard extends StatelessWidget {
  const _SavedPlacesCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _DestinationListCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          const Icon(Icons.bookmark_rounded, color: JosiColors.red, size: 28),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              'Saved Places',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: JosiColors.muted, size: 26),
        ],
      ),
    );
  }
}

class _RecentDestinationTile extends StatelessWidget {
  const _RecentDestinationTile({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return _DestinationListCard(
      onTap: () => context.go(AppRoutes.customerConfirmTrip),
      child: Row(
        children: <Widget>[
          const Icon(Icons.history_rounded, color: JosiColors.muted, size: 25),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationListCard extends StatelessWidget {
  const _DestinationListCard({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: JosiColors.line),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DestinationBottomBar extends StatelessWidget {
  const _DestinationBottomBar({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: JosiColors.surface),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 14),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                key: const ValueKey<String>('destination-confirm-button'),
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: JosiColors.red,
                  foregroundColor: JosiColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: JosiColors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                child: const Text('Confirm'),
              ),
            ),
          ),
          const _CustomerFixedBottomNav(selectedTab: 'activity'),
        ],
      ),
    );
  }
}

class _CustomerFixedBottomNav extends StatelessWidget {
  const _CustomerFixedBottomNav({required this.selectedTab});

  final String selectedTab;

  @override
  Widget build(BuildContext context) {
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
                selectedTab: selectedTab,
              ),
              _CustomerNavItem(
                tab: 'activity',
                label: 'Activity',
                asset: AppAssets.notification,
                route: AppRoutes.customerTrips,
                selectedTab: selectedTab,
              ),
              _CustomerNavItem(
                tab: 'rides',
                label: 'Rides',
                asset: AppAssets.bikeLane,
                route: AppRoutes.customerBookTrip,
                selectedTab: selectedTab,
              ),
              _CustomerNavItem(
                tab: 'profile',
                label: 'Profile',
                asset: AppAssets.profile,
                route: AppRoutes.customerProfile,
                selectedTab: selectedTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            _AssetIcon(asset: asset, color: color, size: 22),
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

class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F2F4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.square(
          dimension: 42,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _AssetIcon extends StatelessWidget {
  const _AssetIcon({
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

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    double y = 3;
    while (y < size.height) {
      canvas.drawLine(
          Offset(size.width / 2, y), Offset(size.width / 2, y + 3), paint);
      y += 7;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class CustomerConfirmTripScreen extends StatefulWidget {
  const CustomerConfirmTripScreen({super.key});

  @override
  State<CustomerConfirmTripScreen> createState() =>
      _CustomerConfirmTripScreenState();
}

class _CustomerConfirmTripScreenState extends State<CustomerConfirmTripScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  String _tripType = 'Ride';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Confirm trip',
      subtitle: 'Fare estimate and payment',
      child: AppScreenBody(
        children: <Widget>[
          TripCard(trip: JosiMockData.trips[0]),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Zone pricing'),
          AppCard(
            child: Column(
              children: <Widget>[
                for (final MapEntry<String, String> entry
                    in JosiMockData.zonePricing.entries)
                  _SummaryRow(label: entry.key, value: entry.value),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Payment method'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _PaymentChoiceChip(
                label: 'Cash',
                selected: _paymentMethod == PaymentMethod.cash,
                onSelected: () =>
                    setState(() => _paymentMethod = PaymentMethod.cash),
              ),
              _PaymentChoiceChip(
                label: 'Online payment',
                selected: _paymentMethod == PaymentMethod.online,
                onSelected: () =>
                    setState(() => _paymentMethod = PaymentMethod.online),
              ),
              _PaymentChoiceChip(
                label: 'Wallet',
                selected: _paymentMethod == PaymentMethod.wallet,
                onSelected: () =>
                    setState(() => _paymentMethod = PaymentMethod.wallet),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppDropdown(
            label: 'Trip type',
            value: _tripType,
            items: const <String>['Ride', 'Package delivery'],
            onChanged: (String? value) =>
                setState(() => _tripType = value ?? _tripType),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Confirm request',
            icon: Icons.local_taxi_rounded,
            onPressed: () => context.go(AppRoutes.customerSearchingRider),
          ),
        ],
      ),
    );
  }
}

class CustomerSearchingRiderScreen extends StatelessWidget {
  const CustomerSearchingRiderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Finding rider',
      subtitle: 'Matching nearby verified riders',
      child: AppScreenBody(
        children: <Widget>[
          AppCard(
            child: Column(
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.78, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (BuildContext context, double scale, Widget? child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: const BoxDecoration(
                        color: JosiColors.redSoft, shape: BoxShape.circle),
                    child: const Icon(Icons.radar_rounded,
                        color: JosiColors.red, size: 54),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Searching for the best rider',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  'This usually takes a few seconds.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: JosiColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TripCard(
              trip: JosiMockData.trips[0],
              trailing: const StatusBadge(label: 'Cash')),
          const SizedBox(height: 18),
          AppButton(
            label: 'Preview active trip',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => context.go(AppRoutes.customerTripActive),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Cancel request',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go(AppRoutes.customerHome),
          ),
        ],
      ),
    );
  }
}

class CustomerActiveTripScreen extends StatelessWidget {
  const CustomerActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Active trip',
      subtitle: 'Rider is en route',
      child: AppScreenBody(
        children: <Widget>[
          const AppMapPlaceholder(
              height: 300, title: 'Live tracking placeholder'),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const ProfileAvatar(name: 'Amina Yusuf'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Amina Yusuf',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Toyota Corolla • ABC 482 JK',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: JosiColors.muted),
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(
                        label: '4.8',
                        color: JosiColors.warning,
                        softColor: JosiColors.warningSoft),
                  ],
                ),
                const SizedBox(height: 16),
                const _Timeline(labels: <String>[
                  'Rider accepted',
                  'Arriving at pickup',
                  'Trip in progress'
                ]),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppButton(
                        label: 'Call',
                        icon: Icons.call_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        label: 'Help',
                        icon: Icons.chat_bubble_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const AppCard(
            child: Column(
              children: <Widget>[
                _SummaryRow(label: 'Fare', value: 'NGN 3,500'),
                _SummaryRow(
                    label: 'Payment status', value: 'Cash due at drop-off'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Complete trip preview',
            icon: Icons.check_circle_rounded,
            onPressed: () => context.go(AppRoutes.customerTripCompleted),
          ),
        ],
      ),
    );
  }
}

class CustomerTripCompletedScreen extends StatelessWidget {
  const CustomerTripCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Trip completed',
      subtitle: 'Receipt and rating',
      child: AppScreenBody(
        children: <Widget>[
          const EmptyState(
            title: 'You arrived safely',
            message: 'NGN 3,500 cash payment recorded for this trip.',
            icon: Icons.check_circle_rounded,
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Rate Amina',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    for (int index = 0; index < 5; index++)
                      const Icon(Icons.star_rate_rounded,
                          color: JosiColors.warning, size: 34),
                  ],
                ),
                const SizedBox(height: 12),
                const AppTextField(
                    label: 'Leave review',
                    hintText: 'Smooth ride and polite rider',
                    maxLines: 3),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Download receipt',
                  icon: Icons.receipt_long_rounded,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Back to home',
            icon: Icons.home_rounded,
            onPressed: () => context.go(AppRoutes.customerHome),
          ),
        ],
      ),
    );
  }
}

class CustomerTripsScreen extends ConsumerWidget {
  const CustomerTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Trips',
      subtitle: 'History and active requests',
      navRole: AppNavRole.customer,
      selectedTab: 'trips',
      child: AppScreenBody(
        children: <Widget>[
          const _FilterRow(
              filters: <String>['All', 'Active', 'Completed', 'Cancelled']),
          const SizedBox(height: 14),
          trips.when(
            data: (List<Trip> values) => values.isEmpty
                ? const EmptyState(
                    title: 'No trips yet',
                    message: 'Your completed rides will appear here.')
                : Column(
                    children: values.map((Trip trip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TripCard(
                          trip: trip,
                          onTap: () => context
                              .go(AppRoutes.customerTripDetailPath(trip.id)),
                        ),
                      );
                    }).toList(),
                  ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Trips unavailable', message: 'Please try again later.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading trips')),
          ),
        ],
      ),
    );
  }
}

class CustomerTripDetailScreen extends ConsumerWidget {
  const CustomerTripDetailScreen({
    required this.tripId,
    super.key,
  });

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);

    return AppScaffold(
      title: 'Trip detail',
      subtitle: tripId,
      child: AppScreenBody(
        children: <Widget>[
          trips.when(
            data: (List<Trip> values) {
              final Trip trip = values.firstWhere(
                  (Trip value) => value.id == tripId,
                  orElse: () => values.first);
              return Column(
                children: <Widget>[
                  TripCard(trip: trip),
                  const SizedBox(height: 16),
                  const AppMapPlaceholder(height: 220),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: <Widget>[
                        _SummaryRow(label: 'Rider', value: trip.riderName),
                        _SummaryRow(
                            label: 'Payment',
                            value: _paymentLabel(trip.paymentMethod)),
                        _SummaryRow(label: 'Distance', value: trip.distance),
                        _SummaryRow(label: 'Duration', value: trip.duration),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppCard(
                    child: _Timeline(labels: <String>[
                      'Requested',
                      'Accepted',
                      'Picked up',
                      'Completed'
                    ]),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Receipt',
                    icon: Icons.receipt_long_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {},
                  ),
                ],
              );
            },
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Trip unavailable',
                message: 'This trip could not be loaded.'),
            loading: () => const SizedBox(
                height: 220, child: LoadingState(label: 'Loading trip')),
          ),
        ],
      ),
    );
  }
}

class CustomerWalletScreen extends ConsumerWidget {
  const CustomerWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<WalletSummary> summary = ref.watch(customerWalletProvider);
    final AsyncValue<List<WalletTransaction>> transactions =
        ref.watch(walletTransactionsProvider);

    return AppScaffold(
      title: 'Wallet',
      subtitle: 'Payments and transactions',
      navRole: AppNavRole.customer,
      selectedTab: 'wallet',
      child: AppScreenBody(
        children: <Widget>[
          summary.when(
            data: (WalletSummary wallet) => WalletBalanceCard(
              title: 'Available balance',
              balance: wallet.balance,
              subtitle: 'Cash payment stays available for every route.',
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Wallet unavailable',
                message: 'Balance could not be loaded.'),
            loading: () => const SizedBox(
                height: 190, child: LoadingState(label: 'Loading wallet')),
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Add money',
            icon: Icons.add_card_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Payment methods'),
          const AppCard(
            child: Column(
              children: <Widget>[
                _SummaryRow(label: 'Cash', value: 'Available'),
                _SummaryRow(label: 'Wallet', value: 'Active'),
                _SummaryRow(label: 'Online payment', value: 'Placeholder'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Transactions'),
          transactions.when(
            data: (List<WalletTransaction> values) => Column(
              children: values.map((WalletTransaction transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TransactionCard(transaction: transaction),
                );
              }).toList(),
            ),
            error: (Object error, StackTrace stackTrace) => const ErrorState(
                title: 'Transactions unavailable',
                message: 'Please try again later.'),
            loading: () => const SizedBox(
                height: 160,
                child: LoadingState(label: 'Loading transactions')),
          ),
        ],
      ),
    );
  }
}

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<JosiUser> user = ref.watch(currentCustomerProvider);

    return Scaffold(
      key: const ValueKey<String>('customer-profile-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: user.when(
              data: (JosiUser value) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ProfileHeader(
                      title: 'Profile',
                      onBack: () => context.go(AppRoutes.customerHome),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: _CustomerProfilePhoto(name: value.name, size: 118),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      value.name,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: JosiColors.ink,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 36),
                    _CustomerProfileMenuItem(
                      label: 'Your profile',
                      asset: AppAssets.profile,
                      onTap: () => context.go(AppRoutes.editProfile),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Manage Address',
                      asset: AppAssets.location,
                      onTap: () => context.go(AppRoutes.customerSelectLocation),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Notification',
                      asset: AppAssets.notification,
                      onTap: () => context.go(AppRoutes.customerNotifications),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Payment Methods',
                      asset: AppAssets.card,
                      onTap: () => context.go(AppRoutes.customerWallet),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Pre-Booked Rides',
                      asset: AppAssets.bikeLane,
                      onTap: () => context.go(AppRoutes.customerTrips),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      onTap: () => context.go(AppRoutes.customerSettings),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Emergency Contact',
                      icon: Icons.emergency_outlined,
                      onTap: () => context.go(AppRoutes.customerSupport),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Help Center',
                      icon: Icons.help_outline_rounded,
                      onTap: () => context.go(AppRoutes.customerSupport),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.login);
                        }
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                    ),
                  ],
                ),
              ),
              error: (Object error, StackTrace stackTrace) =>
                  const AppScreenBody(
                children: <Widget>[
                  ErrorState(
                    title: 'Profile unavailable',
                    message: 'Customer profile could not be loaded.',
                  ),
                ],
              ),
              loading: () => const SizedBox(
                  height: 220, child: LoadingState(label: 'Loading profile')),
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          const AppBottomNav(role: AppNavRole.customer, selectedTab: 'profile'),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
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
              dimension: 48,
              child: Center(
                child: _AssetIcon(
                  asset: AppAssets.arrowLeft,
                  color: JosiColors.ink,
                  size: 23,
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
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _CustomerProfilePhoto extends StatelessWidget {
  const _CustomerProfilePhoto({
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
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: JosiColors.red,
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Positioned(
          right: -2,
          bottom: 8,
          child: Container(
            width: size * 0.33,
            height: size * 0.33,
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

class _CustomerProfileMenuItem extends StatelessWidget {
  const _CustomerProfileMenuItem({
    required this.label,
    required this.onTap,
    this.asset,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final String? asset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: JosiColors.line)),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 38,
              child: asset == null
                  ? Icon(icon, color: JosiColors.red, size: 28)
                  : _AssetIcon(
                      asset: asset!,
                      color: JosiColors.red,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: JosiColors.red, size: 34),
          ],
        ),
      ),
    );
  }
}

class _PaymentChoiceChip extends StatelessWidget {
  const _PaymentChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (bool value) => onSelected(),
      selectedColor: JosiColors.redSoft,
      checkmarkColor: JosiColors.red,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? JosiColors.red : JosiColors.ink,
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

class _Timeline extends StatelessWidget {
  const _Timeline({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: labels.map((String label) {
        final int index = labels.indexOf(label);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Icon(
                  index == labels.length - 1
                      ? Icons.radio_button_checked_rounded
                      : Icons.check_circle_rounded,
                  color: index == labels.length - 1
                      ? JosiColors.red
                      : JosiColors.success,
                  size: 22,
                ),
                if (index != labels.length - 1)
                  const SizedBox(
                      height: 26,
                      child: VerticalDivider(
                          color: JosiColors.line, thickness: 1.2)),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: JosiColors.muted)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: <Widget>[
          Icon(
            transaction.isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: transaction.isCredit ? JosiColors.success : JosiColors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(transaction.title,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(transaction.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: JosiColors.muted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(transaction.amount,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 3),
              Text(transaction.status,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: JosiColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}

String _paymentLabel(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.cash:
      return 'Cash';
    case PaymentMethod.online:
      return 'Online payment';
    case PaymentMethod.wallet:
      return 'Wallet';
  }
}
