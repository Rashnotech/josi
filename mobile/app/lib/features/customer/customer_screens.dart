import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_routes.dart';
import '../../core/mock/josi_mock_data.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/device_location_service.dart';
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
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: _CustomerHomeMap(
              key: ValueKey<String>('customer-home-map'),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _HomeHeader(
                        firstName: firstName,
                        onNotifications: () =>
                            context.go(AppRoutes.customerNotifications),
                      ),
                      const SizedBox(height: 10),
                      const _CurrentLocationBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.34,
            minChildSize: 0.24,
            maxChildSize: 0.82,
            snap: true,
            snapSizes: const <double>[0.34, 0.82],
            builder: (BuildContext context, ScrollController scrollController) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: constraints.maxWidth.clamp(0.0, 430.0).toDouble(),
                      height: constraints.maxHeight,
                      child: _WhereToPanel(
                        lastTrip: lastTrip,
                        scrollController: scrollController,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedTab: 'home'),
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

class _CustomerHomeMap extends StatelessWidget {
  const _CustomerHomeMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: CustomPaint(painter: _CustomerHomeMapPainter()),
        ),
        const Positioned(
          right: 32,
          top: 178,
          child: _MapActionButton(icon: Icons.my_location_rounded),
        ),
        const Positioned(
          right: 28,
          top: 278,
          child: _HomeMapMarker(
            icon: Icons.directions_car_filled_rounded,
            color: JosiColors.charcoal,
          ),
        ),
        const Positioned(
          left: 74,
          bottom: 260,
          child: _HomeMapMarker(
            icon: Icons.person_pin_circle_rounded,
            color: JosiColors.red,
          ),
        ),
      ],
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      elevation: 4,
      shadowColor: JosiColors.charcoal.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: 42,
        child: Icon(icon, color: JosiColors.ink, size: 21),
      ),
    );
  }
}

class _HomeMapMarker extends StatelessWidget {
  const _HomeMapMarker({
    required this.icon,
    required this.color,
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
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: JosiColors.charcoal.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}

class _CustomerHomeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEAF2EE), BlendMode.src);

    final Paint district = Paint()..color = const Color(0xFFDCEED8);
    final Paint water = Paint()..color = const Color(0xFFD8EAF7);
    final Paint road = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint roadLine = Paint()
      ..color = JosiColors.mapLine
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint minorRoad = Paint()
      ..color = const Color(0xFFF7F8F7)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint route = Paint()
      ..color = JosiColors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.06, size.width * 0.34,
            size.height * 0.22),
        const Radius.circular(26),
      ),
      district,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.width * 0.08, size.height * 0.54, size.width * 0.42,
            size.height * 0.18),
        const Radius.circular(42),
      ),
      water,
    );

    for (int index = 0; index < 8; index++) {
      final double y = size.height * (0.1 + index * 0.12);
      canvas.drawLine(Offset(-28, y), Offset(size.width + 28, y + 58), road);
      canvas.drawLine(
          Offset(-28, y), Offset(size.width + 28, y + 58), roadLine);
    }

    for (int index = 0; index < 5; index++) {
      final double x = size.width * (0.08 + index * 0.22);
      canvas.drawLine(
          Offset(x, -28), Offset(x + 92, size.height + 28), minorRoad);
      canvas.drawLine(
          Offset(x, -28), Offset(x + 92, size.height + 28), roadLine);
    }

    final Path routePath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.33, size.height * 0.52,
          size.width * 0.52, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.72, size.height * 0.64,
          size.width * 0.78, size.height * 0.37);
    canvas.drawPath(routePath, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurrentLocationBar extends StatefulWidget {
  const _CurrentLocationBar();

  @override
  State<_CurrentLocationBar> createState() => _CurrentLocationBarState();
}

class _CurrentLocationBarState extends State<_CurrentLocationBar> {
  final DeviceLocationService _locationService = const DeviceLocationService();
  String _locationLabel = 'Current Location';
  bool _isLocating = false;

  Future<void> _useCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final DeviceLocation location = await _locationService.currentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _locationLabel = location.displayLabel;
      });
    } on DeviceLocationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        key: const ValueKey<String>('home-current-location-button'),
        onTap: _useCurrentLocation,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
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
                  _isLocating ? 'Locating...' : _locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: JosiColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                ),
              ),
              if (_isLocating)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.my_location_rounded,
                    color: JosiColors.red, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhereToPanel extends StatelessWidget {
  const _WhereToPanel({
    required this.lastTrip,
    required this.scrollController,
  });

  final Trip lastTrip;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey<String>('customer-where-to-sheet'),
      color: JosiColors.white,
      elevation: 18,
      shadowColor: JosiColors.charcoal.withValues(alpha: 0.16),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 22),
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          Center(
            child: Container(
              width: 34,
              height: 4,
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
                  asset: AppAssets.office,
                  onTap: () => context.go(AppRoutes.customerSelectLocation),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LastTripTile(trip: lastTrip),
          const SizedBox(height: 18),
          Text(
            'Saved Places',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          _SavedPlaceButton(
            icon: Icons.home_rounded,
            title: 'Home address',
            subtitle: '2715 Ash Dr. San Jose',
            onTap: () => context.go(AppRoutes.customerSelectLocation),
          ),
          const SizedBox(height: 10),
          _SavedPlaceButton(
            icon: Icons.work_rounded,
            title: 'Work',
            subtitle: 'Central Business District',
            onTap: () => context.go(AppRoutes.customerSelectLocation),
          ),
          const SizedBox(height: 10),
          _SavedPlaceButton(
            icon: Icons.add_location_alt_rounded,
            title: 'Add a new stop',
            subtitle: 'Save another frequent destination',
            onTap: () => context.go(AppRoutes.customerSelectLocation),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceButton extends StatelessWidget {
  const _SavedPlaceButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.surface,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: JosiColors.line),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: JosiColors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: JosiColors.red, size: 18),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: JosiColors.ink,
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

class CustomerSelectLocationScreen extends StatefulWidget {
  const CustomerSelectLocationScreen({super.key});

  @override
  State<CustomerSelectLocationScreen> createState() =>
      _CustomerSelectLocationScreenState();
}

class _CustomerSelectLocationScreenState
    extends State<CustomerSelectLocationScreen> {
  final DeviceLocationService _locationService = const DeviceLocationService();
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'Current Location');
    _destinationController =
        TextEditingController(text: '1901 Thornridge Cir. Shiloh');
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final DeviceLocation location = await _locationService.currentPosition();
      if (!mounted) {
        return;
      }
      setState(() {
        _pickupController.text = location.displayLabel;
      });
    } on DeviceLocationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

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
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _DestinationHeader(
                    onBack: () => context.go(AppRoutes.customerHome),
                  ),
                  const SizedBox(height: 18),
                  _DestinationRouteCard(
                    pickupController: _pickupController,
                    destinationController: _destinationController,
                    isLocating: _isLocating,
                    onUseCurrentLocation: _useCurrentLocation,
                  ),
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
            size: 18,
          ),
        ),
        Expanded(
          child: Text(
            key: const ValueKey<String>('destination-screen-title'),
            'Destination',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: JosiColors.redDark,
                  fontSize: 20,
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
  const _DestinationRouteCard({
    required this.pickupController,
    required this.destinationController,
    required this.isLocating,
    required this.onUseCurrentLocation,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final bool isLocating;
  final VoidCallback onUseCurrentLocation;

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
                _DestinationInputLine(
                  fieldKey: const ValueKey<String>(
                      'destination-current-location-field'),
                  controller: pickupController,
                  isFilled: true,
                  readOnly: true,
                  isLoading: isLocating,
                  onTap: onUseCurrentLocation,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _DestinationInputLine(
                        fieldKey: const ValueKey<String>(
                            'destination-location-field'),
                        controller: destinationController,
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
    required this.controller,
    required this.fieldKey,
    this.isFilled = false,
    this.readOnly = false,
    this.isLoading = false,
    this.onTap,
  });

  final TextEditingController controller;
  final Key fieldKey;
  final bool isFilled;
  final bool readOnly;
  final bool isLoading;
  final VoidCallback? onTap;

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
      child: TextField(
        key: fieldKey,
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: 1,
        showCursor: !readOnly,
        textInputAction: readOnly ? TextInputAction.none : TextInputAction.done,
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: JosiColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          suffixIconConstraints:
              const BoxConstraints.tightFor(width: 24, height: 24),
          suffixIcon: readOnly
              ? (isLoading
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded,
                      color: JosiColors.red, size: 18))
              : null,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
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
          const CustomerBottomNav(selectedTab: 'rides'),
        ],
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

enum _CustomerPaymentOption { cash, wallet, paypal, applePay, googlePay }

class CustomerPaymentMethodsScreen extends StatefulWidget {
  const CustomerPaymentMethodsScreen({
    required this.confirmRoute,
    super.key,
    this.backRoute = AppRoutes.customerProfile,
  });

  final String confirmRoute;
  final String backRoute;

  @override
  State<CustomerPaymentMethodsScreen> createState() =>
      _CustomerPaymentMethodsScreenState();
}

class _CustomerPaymentMethodsScreenState
    extends State<CustomerPaymentMethodsScreen> {
  _CustomerPaymentOption _selectedOption = _CustomerPaymentOption.cash;

  void _select(_CustomerPaymentOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-payment-methods-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Column(
                children: <Widget>[
                  _PaymentMethodsHeader(
                    onBack: () => context.go(widget.backRoute),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 22, 0, 24),
                      children: <Widget>[
                        const _PaymentSectionTitle('Cash'),
                        const SizedBox(height: 10),
                        _PaymentOptionTile(
                          key: const ValueKey<String>('payment-cash-option'),
                          icon: const _PaymentMaterialIcon(
                            icon: Icons.payments_rounded,
                            color: JosiColors.red,
                          ),
                          label: 'Cash',
                          selected:
                              _selectedOption == _CustomerPaymentOption.cash,
                          onTap: () => _select(_CustomerPaymentOption.cash),
                        ),
                        const SizedBox(height: 28),
                        const _PaymentSectionTitle('Wallet'),
                        const SizedBox(height: 10),
                        _PaymentOptionTile(
                          key: const ValueKey<String>('payment-wallet-option'),
                          icon: const _PaymentMaterialIcon(
                            icon: Icons.account_balance_wallet_rounded,
                            color: JosiColors.red,
                          ),
                          label: 'Wallet',
                          selected:
                              _selectedOption == _CustomerPaymentOption.wallet,
                          onTap: () => _select(_CustomerPaymentOption.wallet),
                        ),
                        const SizedBox(height: 28),
                        const _PaymentSectionTitle('Credit & Debit Card'),
                        const SizedBox(height: 10),
                        _PaymentActionTile(
                          key: const ValueKey<String>('payment-add-card'),
                          icon: const _PaymentMaterialIcon(
                            icon: Icons.credit_card_rounded,
                            color: JosiColors.red,
                          ),
                          label: 'Add Card',
                          onTap: () {},
                        ),
                        const SizedBox(height: 28),
                        const _PaymentSectionTitle('More Payment Options'),
                        const SizedBox(height: 10),
                        _MorePaymentOptionsCard(
                          selectedOption: _selectedOption,
                          onSelected: _select,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  key: const ValueKey<String>('confirm-payment-button'),
                  onPressed: () => context.go(widget.confirmRoute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JosiColors.red,
                    foregroundColor: JosiColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: JosiColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  child: const Text('Confirm Payment'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodsHeader extends StatelessWidget {
  const _PaymentMethodsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Row(
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
                child: Icon(Icons.arrow_back_rounded,
                    color: JosiColors.black, size: 20),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Payment Methods',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: JosiColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _PaymentSectionTitle extends StatelessWidget {
  const _PaymentSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: JosiColors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PaymentTileFrame(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(width: 18),
          Expanded(child: _PaymentTileLabel(label)),
          _PaymentRadio(selected: selected),
        ],
      ),
    );
  }
}

class _PaymentActionTile extends StatelessWidget {
  const _PaymentActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PaymentTileFrame(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          icon,
          const SizedBox(width: 18),
          Expanded(child: _PaymentTileLabel(label)),
          const Icon(Icons.chevron_right_rounded,
              color: JosiColors.red, size: 36),
        ],
      ),
    );
  }
}

class _MorePaymentOptionsCard extends StatelessWidget {
  const _MorePaymentOptionsCard({
    required this.selectedOption,
    required this.onSelected,
  });

  final _CustomerPaymentOption selectedOption;
  final ValueChanged<_CustomerPaymentOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: JosiColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          _GroupedPaymentOption(
            key: const ValueKey<String>('payment-paypal-option'),
            icon: const _PaypalMark(),
            label: 'Paypal',
            selected: selectedOption == _CustomerPaymentOption.paypal,
            onTap: () => onSelected(_CustomerPaymentOption.paypal),
          ),
          const Divider(height: 1, color: JosiColors.line),
          _GroupedPaymentOption(
            key: const ValueKey<String>('payment-apple-pay-option'),
            icon: const _PaymentMaterialIcon(
              icon: Icons.apple,
              color: JosiColors.black,
            ),
            label: 'Apple Pay',
            selected: selectedOption == _CustomerPaymentOption.applePay,
            onTap: () => onSelected(_CustomerPaymentOption.applePay),
          ),
          const Divider(height: 1, color: JosiColors.line),
          _GroupedPaymentOption(
            key: const ValueKey<String>('payment-google-pay-option'),
            icon: SizedBox.square(
              dimension: 36,
              child: Center(
                child:
                    SvgPicture.asset(AppAssets.google, width: 30, height: 30),
              ),
            ),
            label: 'Google Pay',
            selected: selectedOption == _CustomerPaymentOption.googlePay,
            onTap: () => onSelected(_CustomerPaymentOption.googlePay),
          ),
        ],
      ),
    );
  }
}

class _GroupedPaymentOption extends StatelessWidget {
  const _GroupedPaymentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: <Widget>[
                icon,
                const SizedBox(width: 18),
                Expanded(child: _PaymentTileLabel(label)),
                _PaymentRadio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTileFrame extends StatelessWidget {
  const _PaymentTileFrame({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: JosiColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _PaymentTileLabel extends StatelessWidget {
  const _PaymentTileLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: JosiColors.softMuted,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
    );
  }
}

class _PaymentRadio extends StatelessWidget {
  const _PaymentRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? JosiColors.red : JosiColors.line,
          width: selected ? 2.4 : 1.6,
        ),
      ),
      child: selected
          ? Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: JosiColors.red,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _PaymentMaterialIcon extends StatelessWidget {
  const _PaymentMaterialIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 36,
      child: Center(child: Icon(icon, color: color, size: 30)),
    );
  }
}

class _PaypalMark extends StatelessWidget {
  const _PaypalMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Transform.translate(
            offset: const Offset(5, 2),
            child: Text(
              'P',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF179BD7),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
          Transform.translate(
            offset: const Offset(-1, -1),
            child: Text(
              'P',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF003087),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RideSearchStage { searching, found, notFound }

class CustomerSearchingRiderScreen extends StatefulWidget {
  const CustomerSearchingRiderScreen({
    super.key,
    this.showNotFound = false,
  });

  final bool showNotFound;

  @override
  State<CustomerSearchingRiderScreen> createState() =>
      _CustomerSearchingRiderScreenState();
}

class _CustomerSearchingRiderScreenState
    extends State<CustomerSearchingRiderScreen> {
  late _RideSearchStage _stage = widget.showNotFound
      ? _RideSearchStage.notFound
      : _RideSearchStage.searching;

  @override
  void didUpdateWidget(covariant CustomerSearchingRiderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showNotFound != widget.showNotFound) {
      _stage = widget.showNotFound
          ? _RideSearchStage.notFound
          : _RideSearchStage.searching;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case _RideSearchStage.searching:
        return _SearchingRideView(
          onBack: () => context.go(AppRoutes.customerSelectLocation),
          onBookMini: () => setState(() => _stage = _RideSearchStage.found),
        );
      case _RideSearchStage.found:
        return _RideFoundView(
          onBack: () => setState(() => _stage = _RideSearchStage.searching),
          onRequestRide: () => context.go(AppRoutes.customerTripActive),
        );
      case _RideSearchStage.notFound:
        return _RideNotFoundView(
          onBack: () => context.go(AppRoutes.customerSelectLocation),
          onTryAgain: () {
            context.go(AppRoutes.customerSearchingRider);
            setState(() => _stage = _RideSearchStage.searching);
          },
        );
    }
  }
}

class _SearchingRideView extends StatelessWidget {
  const _SearchingRideView({
    required this.onBack,
    required this.onBookMini,
  });

  final VoidCallback onBack;
  final VoidCallback onBookMini;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-searching-rider-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: _RideMapBackdrop(
              showBikes: true,
              showRoute: false,
            ),
          ),
          Positioned(
            left: 24,
            top: MediaQuery.paddingOf(context).top + 26,
            child: _FloatingBackButton(onTap: onBack),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: MediaQuery.paddingOf(context).top + 136,
            child: Column(
              children: <Widget>[
                const _SearchingRideBadge(),
                const SizedBox(height: 22),
                Text(
                  'Searching Ride...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: JosiColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _RideBottomAction(
        label: 'Book Mini',
        onPressed: onBookMini,
      ),
    );
  }
}

class _RideFoundView extends StatelessWidget {
  const _RideFoundView({
    required this.onBack,
    required this.onRequestRide,
  });

  final VoidCallback onBack;
  final VoidCallback onRequestRide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-ride-found-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: _RideMapBackdrop(showBikes: true, showRoute: true),
          ),
          Positioned(
            left: 24,
            top: MediaQuery.paddingOf(context).top + 26,
            child: _FloatingBackButton(onTap: onBack),
          ),
          Positioned(
            right: 24,
            bottom: 236,
            child: _LocateMeButton(onTap: () {}),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.31,
            minChildSize: 0.28,
            maxChildSize: 0.45,
            snap: true,
            snapSizes: const <double>[0.31, 0.45],
            builder: (BuildContext context, ScrollController scrollController) {
              return _RideFoundSheet(
                scrollController: scrollController,
                onRequestRide: onRequestRide,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RideNotFoundView extends StatelessWidget {
  const _RideNotFoundView({
    required this.onBack,
    required this.onTryAgain,
  });

  final VoidCallback onBack;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-ride-not-found-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _RideMapBackdrop(showRoute: true)),
          Positioned(
            left: 24,
            top: MediaQuery.paddingOf(context).top + 26,
            child: _FloatingBackButton(onTap: onBack),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 48,
            left: 0,
            right: 0,
            child: Text(
              'Book Ride',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _RideNotFoundSheet(onTryAgain: onTryAgain),
          ),
        ],
      ),
    );
  }
}

class _SearchingRideBadge extends StatelessWidget {
  const _SearchingRideBadge();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.05, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            SizedBox.square(
              dimension: 112,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 5,
                strokeCap: StrokeCap.round,
                backgroundColor: JosiColors.redSoft,
                color: JosiColors.red,
              ),
            ),
            child!,
          ],
        );
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          color: JosiColors.white,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: _RideBikeIcon(
            key: ValueKey<String>('searching-ride-bike-icon'),
            color: JosiColors.red,
            size: 48,
          ),
        ),
      ),
    );
  }
}

class _RideFoundSheet extends StatelessWidget {
  const _RideFoundSheet({
    required this.scrollController,
    required this.onRequestRide,
  });

  final ScrollController scrollController;
  final VoidCallback onRequestRide;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey<String>('request-ride-bottom-sheet'),
      color: JosiColors.white,
      elevation: 18,
      shadowColor: JosiColors.charcoal.withValues(alpha: 0.16),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          children: <Widget>[
            Center(
              child: Container(
                width: 72,
                height: 4,
                decoration: BoxDecoration(
                  color: JosiColors.line,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Ride Founded',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '5 min Away',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _DriverAvatar(name: 'Jenny Wilson', size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jenny Wilson',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: JosiColors.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Bike rider',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const _RideBikeIcon(
                        key: ValueKey<String>('request-ride-bike-icon'),
                        color: JosiColors.red,
                        size: 22,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        text: '\$1.25',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: JosiColors.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                        children: <InlineSpan>[
                          TextSpan(
                            text: '/mi',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: JosiColors.softMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GR 678',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            _RidePrimaryButton(
              key: const ValueKey<String>('request-ride-button'),
              label: 'Request Ride',
              onPressed: onRequestRide,
            ),
          ],
        ),
      ),
    );
  }
}

class _RideNotFoundSheet extends StatelessWidget {
  const _RideNotFoundSheet({required this.onTryAgain});

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return _RideSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            AppAssets.locationSearch,
            key: const ValueKey<String>('ride-not-found-illustration'),
            height: 178,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Ride Not Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'please try again in a few minutes',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 28),
          _RidePrimaryButton(
            key: const ValueKey<String>('try-again-ride-button'),
            label: 'Try Again',
            onPressed: onTryAgain,
          ),
        ],
      ),
    );
  }
}

class _RideSheet extends StatelessWidget {
  const _RideSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 4,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _RideBottomAction extends StatelessWidget {
  const _RideBottomAction({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 18, 30, 20),
          child: _RidePrimaryButton(
            key: const ValueKey<String>('book-mini-button'),
            label: label,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class _RidePrimaryButton extends StatelessWidget {
  const _RidePrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: JosiColors.red,
          foregroundColor: JosiColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _FloatingBackButton extends StatelessWidget {
  const _FloatingBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: const Color(0x18000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox.square(
          dimension: 44,
          child: Center(
            child: _AssetIcon(
              asset: AppAssets.arrowLeft,
              color: JosiColors.ink,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocateMeButton extends StatelessWidget {
  const _LocateMeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: const Color(0x18000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox.square(
          dimension: 54,
          child:
              Icon(Icons.my_location_rounded, color: JosiColors.red, size: 28),
        ),
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({
    required this.name,
    required this.size,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: JosiColors.redSoft,
        border: Border.all(color: JosiColors.white, width: 3),
      ),
      child: Text(
        name
            .split(' ')
            .take(2)
            .map((String part) => part.isEmpty ? '' : part[0])
            .join(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: JosiColors.red,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _MapBikeMarker extends StatelessWidget {
  const _MapBikeMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: JosiColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: JosiColors.red.withValues(alpha: 0.16)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const _RideBikeIcon(color: JosiColors.red, size: 24),
    );
  }
}

class _RideBikeIcon extends StatelessWidget {
  const _RideBikeIcon({
    required this.color,
    required this.size,
    super.key,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.bike,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class _RideMapBackdrop extends StatelessWidget {
  const _RideMapBackdrop({
    this.showBikes = false,
    this.showRoute = true,
  });

  final bool showBikes;
  final bool showRoute;

  @override
  Widget build(BuildContext context) {
    final List<Offset> bikes = showRoute
        ? const <Offset>[Offset(0.58, 0.43)]
        : const <Offset>[
            Offset(0.22, 0.44),
            Offset(0.75, 0.45),
            Offset(0.52, 0.64),
            Offset(0.22, 0.72),
            Offset(0.78, 0.71),
            Offset(0.42, 0.90),
          ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _RideMapPainter(showRoute: showRoute),
                child: const SizedBox.expand(),
              ),
            ),
            if (showBikes)
              for (int index = 0; index < bikes.length; index += 1)
                Positioned(
                  left: constraints.maxWidth * bikes[index].dx - 21,
                  top: constraints.maxHeight * bikes[index].dy - 21,
                  child: _MapBikeMarker(
                    key: ValueKey<String>('ride-map-bike-marker-$index'),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _RideMapPainter extends CustomPainter {
  const _RideMapPainter({required this.showRoute});

  final bool showRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEAF2EE));

    final Paint districtPaint = Paint()..color = const Color(0xFFDCEED8);
    final Paint waterPaint = Paint()..color = const Color(0xFFD8EAF7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.58, size.height * 0.06, size.width * 0.34,
            size.height * 0.22),
        const Radius.circular(26),
      ),
      districtPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-size.width * 0.08, size.height * 0.54, size.width * 0.42,
            size.height * 0.18),
        const Radius.circular(42),
      ),
      waterPaint,
    );

    final Paint roadPaint = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final Paint minorRoadPaint = Paint()
      ..color = const Color(0xFFF7F8F7)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final Paint roadLinePaint = Paint()
      ..color = JosiColors.mapLine
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final Paint arrowPaint = Paint()
      ..color = const Color(0xFFC9CDD2)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (final double x in <double>[0.12, 0.34, 0.57, 0.82]) {
      canvas.drawLine(
        Offset(size.width * x, -size.height * 0.1),
        Offset(size.width * (x - 0.24), size.height * 1.1),
        roadPaint,
      );
      canvas.drawLine(
        Offset(size.width * x, -size.height * 0.1),
        Offset(size.width * (x - 0.24), size.height * 1.1),
        roadLinePaint,
      );
    }
    for (final double y in <double>[0.12, 0.28, 0.45, 0.66, 0.84]) {
      canvas.drawLine(
        Offset(-size.width * 0.1, size.height * y),
        Offset(size.width * 1.1, size.height * (y + 0.16)),
        roadPaint,
      );
      canvas.drawLine(
        Offset(-size.width * 0.1, size.height * y),
        Offset(size.width * 1.1, size.height * (y + 0.16)),
        roadLinePaint,
      );
    }
    for (final double x in <double>[0.2, 0.46, 0.71]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x + 0.12), size.height),
        minorRoadPaint,
      );
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x + 0.12), size.height),
        roadLinePaint,
      );
    }
    for (final double y in <double>[0.2, 0.38, 0.58, 0.76]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y - 0.08)),
        minorRoadPaint,
      );
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y - 0.08)),
        roadLinePaint,
      );
    }

    _drawStreetLabel(canvas, size, 'Worth St', const Offset(0.36, 0.08), -0.6);
    _drawStreetLabel(canvas, size, 'Broadway', const Offset(0.70, 0.29), -1.05);
    _drawStreetLabel(canvas, size, 'Reade St', const Offset(0.37, 0.41), 0.28);
    _drawStreetLabel(canvas, size, 'Park Row', const Offset(0.35, 0.70), -0.18);
    _drawStreetLabel(canvas, size, 'Warren St', const Offset(0.24, 0.58), 0.38);

    for (final Offset point in <Offset>[
      const Offset(0.22, 0.52),
      const Offset(0.38, 0.74),
      const Offset(0.63, 0.46),
      const Offset(0.72, 0.68),
    ]) {
      final Offset center =
          Offset(size.width * point.dx, size.height * point.dy);
      canvas.drawLine(center.translate(-8, -8), center, arrowPaint);
      canvas.drawLine(center, center.translate(-4, 8), arrowPaint);
    }

    if (showRoute) {
      final Paint routePaint = Paint()
        ..color = const Color(0xFF4A4A4A)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Path route = Path()
        ..moveTo(size.width * 0.34, size.height * 0.22)
        ..lineTo(size.width * 0.60, size.height * 0.34)
        ..lineTo(size.width * 0.48, size.height * 0.48)
        ..lineTo(size.width * 0.78, size.height * 0.62);
      canvas.drawPath(route, routePaint);
      _drawMapPin(canvas, size, const Offset(0.34, 0.22), isPickup: true);
      _drawDestinationPulse(canvas, size, const Offset(0.78, 0.62));
    }

    final Rect fadeRect = Offset.zero & size;
    canvas.drawRect(
      fadeRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0x55FFFFFF),
            Color(0x00FFFFFF),
            Color(0xB8FFFFFF),
          ],
          stops: <double>[0, 0.45, 1],
        ).createShader(fadeRect),
    );
  }

  void _drawStreetLabel(
    Canvas canvas,
    Size size,
    String text,
    Offset fractionalOffset,
    double rotation,
  ) {
    canvas.save();
    canvas.translate(
        size.width * fractionalOffset.dx, size.height * fractionalOffset.dy);
    canvas.rotate(rotation);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFFB8BCC2),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawMapPin(Canvas canvas, Size size, Offset point,
      {required bool isPickup}) {
    final Offset center = Offset(size.width * point.dx, size.height * point.dy);
    final Paint paint = Paint()..color = JosiColors.red;
    canvas.drawLine(center, center.translate(0, 48), paint..strokeWidth = 4);
    canvas.drawCircle(center, 24, Paint()..color = JosiColors.white);
    canvas.drawCircle(center, 19, paint);
    canvas.drawCircle(center, 10, Paint()..color = JosiColors.white);
  }

  void _drawDestinationPulse(Canvas canvas, Size size, Offset point) {
    final Offset center = Offset(size.width * point.dx, size.height * point.dy);
    canvas.drawCircle(
        center, 54, Paint()..color = JosiColors.red.withValues(alpha: 0.16));
    canvas.drawCircle(
        center, 38, Paint()..color = JosiColors.red.withValues(alpha: 0.22));
    canvas.drawCircle(center, 28, Paint()..color = JosiColors.red);
    final Path arrow = Path()
      ..moveTo(center.dx - 10, center.dy - 7)
      ..lineTo(center.dx + 11, center.dy)
      ..lineTo(center.dx - 10, center.dy + 7)
      ..close();
    canvas.drawPath(arrow, Paint()..color = JosiColors.white);
  }

  @override
  bool shouldRepaint(covariant _RideMapPainter oldDelegate) {
    return oldDelegate.showRoute != showRoute;
  }
}

class CustomerActiveTripScreen extends StatelessWidget {
  const CustomerActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ActiveTripScaffold(
      key: const ValueKey<String>('customer-active-trip-shell'),
      title: 'Driver Arrived',
      subtitle: 'Driver arrived',
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
            label: 'Trip preview',
            icon: Icons.check_circle_rounded,
            onPressed: () => context.go(AppRoutes.customerTripCompleted),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripScaffold extends StatelessWidget {
  const _ActiveTripScaffold({
    required Widget child,
    super.key,
    String? title,
    String? subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-active-trip-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _ActiveTripMapBackdrop()),
          Positioned(
            left: 24,
            top: MediaQuery.paddingOf(context).top + 26,
            child: _FloatingBackButton(
              onTap: () => context.go(AppRoutes.customerHome),
            ),
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 48,
            left: 0,
            right: 0,
            child: Text(
              'Driver Arrived',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 300,
            child: _LocateMeButton(onTap: () {}),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _ActiveTripSheet(
              onTripPreview: () => context.go(AppRoutes.customerTripCompleted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveTripMapBackdrop extends StatelessWidget {
  const _ActiveTripMapBackdrop();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            const Positioned.fill(
              child: CustomPaint(
                painter: _RideMapPainter(showRoute: true),
                child: SizedBox.expand(),
              ),
            ),
            Positioned(
              left: constraints.maxWidth * 0.56 - 20,
              top: constraints.maxHeight * 0.33 - 20,
              child: const _CarMapMarker(),
            ),
          ],
        );
      },
    );
  }
}

class _CarMapMarker extends StatelessWidget {
  const _CarMapMarker();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.52,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: JosiColors.ink,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 12,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: const Icon(
          Icons.directions_car_filled_rounded,
          color: JosiColors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _ActiveTripSheet extends StatelessWidget {
  const _ActiveTripSheet({required this.onTripPreview});

  final VoidCallback onTripPreview;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 4,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Driver Arrived',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  '5 min Away',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                const _DriverAvatar(name: 'Jenny Wilson', size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jenny Wilson',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sedan',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                const _ContactRoundButton(icon: Icons.chat_bubble_rounded),
                const SizedBox(width: 12),
                const _ContactRoundButton(icon: Icons.call_rounded),
              ],
            ),
            const SizedBox(height: 18),
            const _ActiveTripRouteSummary(),
            const SizedBox(height: 16),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 14),
            const Row(
              children: <Widget>[
                Expanded(
                  child: _ActiveTripStat(label: 'Rate per', value: r'$1.25'),
                ),
                Expanded(
                  child: _ActiveTripStat(
                      label: 'Car Number', value: 'GR 678-UVWX'),
                ),
                Expanded(
                  child:
                      _ActiveTripStat(label: 'No. of Seats', value: '4 Seats'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _RidePrimaryButton(
              key: const ValueKey<String>('trip-preview-button'),
              label: 'Trip preview',
              onPressed: onTripPreview,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRoundButton extends StatelessWidget {
  const _ContactRoundButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: JosiColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: JosiColors.line),
      ),
      child: Icon(icon, color: JosiColors.red, size: 24),
    );
  }
}

class _ActiveTripRouteSummary extends StatelessWidget {
  const _ActiveTripRouteSummary();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned(
          left: 16,
          top: 26,
          bottom: 26,
          child: _RouteDashedLine(),
        ),
        Column(
          children: <Widget>[
            _ActiveRoutePoint(
              icon: Icons.radio_button_checked_rounded,
              iconColor: JosiColors.ink,
              label: '6391 Elgin St. Celina, Delswa...',
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: JosiColors.white,
                  border: Border.all(color: JosiColors.line),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'OTP - 6546',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const _ActiveRoutePoint(
              icon: Icons.location_on_rounded,
              iconColor: JosiColors.red,
              label: '1901 Thornridge Cir. Sh...',
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveRoutePoint extends StatelessWidget {
  const _ActiveRoutePoint({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 34,
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 16,
                ),
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _RouteDashedLine extends StatelessWidget {
  const _RouteDashedLine();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 1,
      height: 58,
      child: CustomPaint(
        painter: _DashedLinePainter(color: JosiColors.softMuted),
      ),
    );
  }
}

class _ActiveTripStat extends StatelessWidget {
  const _ActiveTripStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 13,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: JosiColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
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
      selectedTab: 'activity',
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _ProfileHeader(
                      title: 'Profile',
                      onBack: () => context.go(AppRoutes.customerHome),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: _CustomerProfilePhoto(name: value.name, size: 104),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      value.name,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: JosiColors.ink,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                    const SizedBox(height: 22),
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
                      onTap: () => context.go(AppRoutes.customerPaymentMethods),
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
      bottomNavigationBar: const CustomerBottomNav(selectedTab: 'profile'),
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
              dimension: 42,
              child: Center(
                child: _AssetIcon(
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
            title,
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
              width: 34,
              child: asset == null
                  ? Icon(icon, color: JosiColors.red, size: 24)
                  : _AssetIcon(
                      asset: asset!,
                      color: JosiColors.red,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: JosiColors.red, size: 28),
          ],
        ),
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
