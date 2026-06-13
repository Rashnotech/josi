import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/map_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/location/location_providers.dart';
import '../../core/location/location_service.dart';
import '../../core/mock/josi_mock_data.dart';
import '../../core/mock/josi_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/josi_colors.dart';
import '../../core/widgets/app_components.dart';
import '../../core/widgets/josi_google_map.dart';

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
    return JosiGoogleMap(
      initialCameraPosition: MapConstants.cameraFor(MapConstants.abuja),
      markers: <Marker>{
        MapConstants.customerMarker(MapConstants.mockCustomerLocation),
        MapConstants.riderMarker(MapConstants.mockRiderLocation),
      },
      myLocationEnabled: true,
      showCurrentLocationButton: true,
    );
  }
}

// ignore: unused_element
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

// ignore: unused_element
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

// ignore: unused_element
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

class _CurrentLocationBar extends ConsumerStatefulWidget {
  const _CurrentLocationBar();

  @override
  ConsumerState<_CurrentLocationBar> createState() =>
      _CurrentLocationBarState();
}

class _CurrentLocationBarState extends ConsumerState<_CurrentLocationBar> {
  bool _isLocating = false;

  Future<void> _useCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final LatLng location =
          (await ref.read(locationServiceProvider).currentPosition()).latLng;
      final String address = await ref
          .read(reverseGeocodingServiceProvider)
          .addressFromCoordinates(
            latitude: location.latitude,
            longitude: location.longitude,
            fallback: 'Unable to get address. Please adjust the pin.',
          );
      if (!mounted) {
        return;
      }
      ref.read(currentLocationAddressProvider.notifier).state = address;
      ref.read(selectedPickupProvider.notifier).state = location;
      ref.read(selectedPickupAddressProvider.notifier).state = address;
    } on LocationFailure catch (error) {
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
    final String locationLabel = ref.watch(currentLocationAddressProvider);

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
                  _isLocating ? 'Fetching location address...' : locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: JosiColors.muted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                  fontSize: 16,
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
                            fontSize: 14,
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
                            fontSize: 12,
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

class CustomerSelectLocationScreen extends ConsumerStatefulWidget {
  const CustomerSelectLocationScreen({super.key});

  @override
  ConsumerState<CustomerSelectLocationScreen> createState() =>
      _CustomerSelectLocationScreenState();
}

class _CustomerSelectLocationScreenState
    extends ConsumerState<CustomerSelectLocationScreen> {
  late final TextEditingController _pickupController;
  late final TextEditingController _destinationController;
  GoogleMapController? _mapController;
  LatLng _mapCenter = MapConstants.abuja;
  LatLng _selectedPickup = MapConstants.defaultPickup;
  LatLng _selectedDestination = MapConstants.defaultDestination;
  bool _selectingDestination = false;
  bool _isMapLoading = true;
  bool _isLocating = false;
  bool _isFetchingPickupAddress = false;
  bool _isFetchingDestinationAddress = false;
  String? _mapErrorMessage;
  bool _isPermissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: 'Current Location');
    _destinationController =
        TextEditingController(text: '1901 Thornridge Cir. Shiloh');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialLocation();
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLocation() async {
    setState(() {
      _isMapLoading = true;
      _mapErrorMessage = null;
      _isPermissionPermanentlyDenied = false;
    });

    try {
      final LatLng location =
          (await ref.read(locationServiceProvider).currentPosition()).latLng;
      if (!mounted) {
        return;
      }
      await _setPickup(location);
      await _moveCamera(location);
      setState(() {
        _mapCenter = location;
      });
    } on LocationFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _mapCenter = MapConstants.abuja;
        _mapErrorMessage = error.message;
        _isPermissionPermanentlyDenied =
            error.reason == LocationFailureReason.permissionPermanentlyDenied;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    }
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) {
      return;
    }

    setState(() {
      _isLocating = true;
    });

    try {
      final LatLng location =
          (await ref.read(locationServiceProvider).currentPosition()).latLng;
      if (!mounted) {
        return;
      }
      await _setPickup(location);
      await _moveCamera(location);
    } on LocationFailure catch (error) {
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

  Future<void> _setPickup(LatLng location) async {
    setState(() {
      _selectedPickup = location;
      _mapCenter = location;
      _pickupController.text = 'Fetching location address...';
      _selectingDestination = false;
      _mapErrorMessage = null;
      _isFetchingPickupAddress = true;
    });
    ref.read(selectedPickupProvider.notifier).state = location;

    final String address = await _addressFor(location);
    if (!mounted) {
      return;
    }
    setState(() {
      _pickupController.text = address;
      _isFetchingPickupAddress = false;
    });
    ref.read(selectedPickupAddressProvider.notifier).state = address;
  }

  Future<void> _setDestination(LatLng location) async {
    setState(() {
      _selectedDestination = location;
      _destinationController.text = 'Fetching location address...';
      _selectingDestination = true;
      _mapErrorMessage = null;
      _isFetchingDestinationAddress = true;
    });
    ref.read(selectedDestinationProvider.notifier).state = location;

    final String address = await _addressFor(location);
    if (!mounted) {
      return;
    }
    setState(() {
      _destinationController.text = address;
      _isFetchingDestinationAddress = false;
    });
    ref.read(selectedDestinationAddressProvider.notifier).state = address;
  }

  Future<String> _addressFor(LatLng location) {
    return ref.read(reverseGeocodingServiceProvider).addressFromCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
          fallback: 'Unable to get address. Please adjust the pin.',
        );
  }

  Future<void> _moveCamera(LatLng location) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(MapConstants.cameraFor(location)),
    );
  }

  void _handleMapTap(LatLng location) {
    if (_selectingDestination) {
      _setDestination(location);
      return;
    }
    _setPickup(location);
  }

  void _continueWithDefaultLocation() {
    setState(() {
      _mapErrorMessage = null;
      _mapCenter = MapConstants.abuja;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-destination-screen'),
      backgroundColor: JosiColors.surface,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: JosiGoogleMap(
              key: const ValueKey<String>('customer-select-location-map'),
              initialCameraPosition: MapConstants.cameraFor(_mapCenter),
              markers: <Marker>{
                MapConstants.pickupMarker(_selectedPickup),
                MapConstants.destinationMarker(_selectedDestination),
              },
              myLocationEnabled: true,
              showCurrentLocationButton: true,
              isLoading: _isMapLoading,
              errorMessage: _mapErrorMessage,
              isPermissionPermanentlyDenied: _isPermissionPermanentlyDenied,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
              onTap: _handleMapTap,
              onCurrentLocationPressed: _useCurrentLocation,
              onRetryPermission: _loadInitialLocation,
              onOpenAppSettings: () {
                ref.read(locationServiceProvider).openAppSettings();
              },
              onContinueWithDefaultLocation: _continueWithDefaultLocation,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 5, 24, 0),
              child: _DestinationHeader(
                onBack: () => context.go(AppRoutes.customerHome),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.52,
            minChildSize: 0.34,
            maxChildSize: 0.86,
            snap: true,
            snapSizes: const <double>[0.52, 0.86],
            builder: (BuildContext context, ScrollController controller) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  decoration: const BoxDecoration(
                    color: JosiColors.surface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(18)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 24,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _DestinationRouteCard(
                          pickupController: _pickupController,
                          destinationController: _destinationController,
                          isLocating: _isLocating || _isFetchingPickupAddress,
                          isFetchingDestination: _isFetchingDestinationAddress,
                          onUseCurrentLocation: _useCurrentLocation,
                          onSelectDestination: () {
                            setState(() {
                              _selectingDestination = true;
                            });
                          },
                          onDestinationChanged: (String value) {
                            ref
                                .read(
                                    selectedDestinationAddressProvider.notifier)
                                .state = value;
                          },
                        ),
                        const SizedBox(height: 14),
                        _MapSelectionHint(
                          selectingDestination: _selectingDestination,
                        ),
                        const SizedBox(height: 18),
                        _SavedPlacesCard(
                          onTap: () => context.go(AppRoutes.customerProfile),
                        ),
                        const SizedBox(height: 18),
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
              );
            },
          ),
        ],
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
                      fontSize: 16,
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
                      fontSize: 13,
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
        key: const ValueKey<String>('home-last-trip-tile'),
        onTap: () => context.go(AppRoutes.customerTrips),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: JosiColors.muted,
                            fontSize: 12,
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
    required this.isFetchingDestination,
    required this.onUseCurrentLocation,
    required this.onSelectDestination,
    required this.onDestinationChanged,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final bool isLocating;
  final bool isFetchingDestination;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onSelectDestination;
  final ValueChanged<String> onDestinationChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DestinationInputLine(
            fieldKey:
                const ValueKey<String>('destination-current-location-field'),
            controller: pickupController,
            leadingIcon: Icons.radio_button_checked_rounded,
            leadingColor: JosiColors.ink,
            readOnly: true,
            isLoading: isLocating,
            onTap: onUseCurrentLocation,
          ),
          const SizedBox(height: 10),
          _DestinationInputLine(
            fieldKey: const ValueKey<String>('destination-location-field'),
            controller: destinationController,
            leadingIcon: Icons.location_on_rounded,
            leadingColor: JosiColors.red,
            isLoading: isFetchingDestination,
            onTap: onSelectDestination,
            onChanged: onDestinationChanged,
          ),
          _LocationAddressStatus(
            isFetchingPickup: isLocating,
            isFetchingDestination: isFetchingDestination,
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
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
    required this.leadingIcon,
    required this.leadingColor,
    this.readOnly = false,
    this.isLoading = false,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController controller;
  final Key fieldKey;
  final IconData leadingIcon;
  final Color leadingColor;
  final bool readOnly;
  final bool isLoading;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF4F5F7) : JosiColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: JosiColors.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(leadingIcon, color: leadingColor, size: 16),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              maxLines: 1,
              showCursor: !readOnly,
              textInputAction:
                  readOnly ? TextInputAction.none : TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (isLoading)
            const SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (readOnly)
            const Icon(Icons.my_location_rounded,
                color: JosiColors.red, size: 16)
          else
            const Icon(Icons.map_outlined, color: JosiColors.red, size: 16),
        ],
      ),
    );
  }
}

class _LocationAddressStatus extends StatelessWidget {
  const _LocationAddressStatus({
    required this.isFetchingPickup,
    required this.isFetchingDestination,
  });

  final bool isFetchingPickup;
  final bool isFetchingDestination;

  @override
  Widget build(BuildContext context) {
    if (!isFetchingPickup && !isFetchingDestination) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Fetching location address...',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: JosiColors.softMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _MapSelectionHint extends StatelessWidget {
  const _MapSelectionHint({required this.selectingDestination});

  final bool selectingDestination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: JosiColors.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            selectingDestination
                ? Icons.location_on_rounded
                : Icons.radio_button_checked_rounded,
            color: JosiColors.red,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              selectingDestination
                  ? 'Tap map to choose destination'
                  : 'Tap map to choose pickup',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
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
                    fontSize: 16,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
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
              height: 52,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                child: const Text('Confirm'),
              ),
            ),
          ),
          const CustomerBottomNav(selectedTab: 'rider'),
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

enum _CustomerPaymentOption { cash, wallet }

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
                        const SizedBox(height: 22),
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
                        const SizedBox(height: 22),
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
                height: 52,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                    fontSize: 20,
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
            fontSize: 17,
            fontWeight: FontWeight.w600,
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
              color: JosiColors.red, size: 26),
        ],
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
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
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
            fontSize: 16,
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
      width: 24,
      height: 24,
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
              width: 12,
              height: 12,
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
      dimension: 32,
      child: Center(child: Icon(icon, color: color, size: 24)),
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
                    'Ride Found',
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
                Expanded(
                  child: InkWell(
                    key: const ValueKey<String>(
                        'request-ride-driver-details-link'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.push(AppRoutes.customerDriverDetails),
                    child: Row(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
                      ],
                    ),
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

class _RideMapBackdrop extends ConsumerWidget {
  const _RideMapBackdrop({
    this.showBikes = false,
    this.showRoute = true,
  });

  final bool showBikes;
  final bool showRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActiveTripMapState mapState = ref.watch(activeTripMapProvider);
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
    final Set<Marker> markers = showRoute
        ? mapState.customerTripMarkers
        : <Marker>{
            MapConstants.pickupMarker(mapState.pickup),
            MapConstants.destinationMarker(mapState.destination),
            MapConstants.riderMarker(
              MapConstants.mockRiderLocation,
              id: 'rider-1',
            ),
            MapConstants.riderMarker(
              const LatLng(9.0832, 7.4321),
              id: 'rider-2',
            ),
            MapConstants.riderMarker(
              const LatLng(9.0614, 7.4102),
              id: 'rider-3',
            ),
          };

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: JosiGoogleMap(
                key: ValueKey<String>(
                  showRoute ? 'ride-found-google-map' : 'ride-search-map',
                ),
                initialCameraPosition: MapConstants.cameraFor(
                  showRoute ? mapState.rider : MapConstants.abuja,
                  zoom:
                      showRoute ? MapConstants.tripZoom : MapConstants.cityZoom,
                ),
                markers: markers,
                myLocationEnabled: true,
                showCurrentLocationButton: false,
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

class CustomerActiveTripScreen extends StatelessWidget {
  const CustomerActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ActiveTripScaffold(
      key: const ValueKey<String>('customer-active-trip-shell'),
      title: 'Rider Arrived',
      subtitle: 'Rider arrived',
      child: AppScreenBody(
        children: <Widget>[
          const SizedBox(height: 300, child: _ActiveTripMapBackdrop()),
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
              'Rider Arrived',
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

class _ActiveTripMapBackdrop extends ConsumerWidget {
  const _ActiveTripMapBackdrop();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ActiveTripMapState mapState = ref.watch(activeTripMapProvider);

    return JosiGoogleMap(
      key: const ValueKey<String>('customer-active-trip-map'),
      initialCameraPosition: MapConstants.cameraFor(
        mapState.rider,
        zoom: MapConstants.tripZoom,
      ),
      markers: mapState.customerTripMarkers,
      myLocationEnabled: true,
      showCurrentLocationButton: true,
    );
  }
}

// ignore: unused_element
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
                    'Rider Arrived',
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
                Expanded(
                  child: InkWell(
                    key: const ValueKey<String>(
                        'active-trip-driver-details-link'),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.push(AppRoutes.customerDriverDetails),
                    child: Row(
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: JosiColors.ink,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sedan',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: JosiColors.softMuted,
                                      fontSize: 14,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const _ContactRoundButton(asset: AppAssets.sms),
                const SizedBox(width: 12),
                const _ContactRoundButton(asset: AppAssets.call),
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
  const _ContactRoundButton({
    this.icon,
    this.asset,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final String? asset;

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
      child: asset != null
          ? _AssetIcon(asset: asset!, color: JosiColors.red, size: 22)
          : Icon(icon, color: JosiColors.red, size: 24),
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
    const String amount = 'NGN 3,500';

    return Scaffold(
      key: const ValueKey<String>('customer-trip-completed-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              children: <Widget>[
                _RateDriverHeader(
                  onBack: () => context.go(AppRoutes.customerTripActive),
                ),
                const SizedBox(height: 34),
                InkWell(
                  key: const ValueKey<String>(
                      'completed-trip-driver-details-link'),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push(AppRoutes.customerDriverDetails),
                  child: Column(
                    children: <Widget>[
                      const Center(
                        child: _DriverAvatar(name: 'Jenny Wilson', size: 96),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Jenny Wilson',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        'Hyundai Verna',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 16,
                            ),
                      ),
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 11),
                      decoration: const BoxDecoration(
                        color: JosiColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        'OR 678-UVWX',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.softMuted,
                              fontSize: 16,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$amount cash payment recorded for this trip.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: 34),
                Text(
                  'How was your trip with\nJenny Wilson',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: JosiColors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.28,
                      ),
                ),
                const SizedBox(height: 28),
                const Divider(color: JosiColors.line),
                const SizedBox(height: 26),
                Text(
                  'Your overall rating',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: JosiColors.softMuted,
                        fontSize: 16,
                      ),
                ),
                const SizedBox(height: 24),
                const _RateDriverStars(),
                const SizedBox(height: 28),
                const Divider(color: JosiColors.line),
                const SizedBox(height: 24),
                Text(
                  'Add detailed review',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: JosiColors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                const _RateDriverReviewField(),
                const SizedBox(height: 120),
              ],
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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
              child: _RidePrimaryButton(
                key: const ValueKey<String>('submit-trip-rating-button'),
                label: 'Submit',
                onPressed: () => context.go(AppRoutes.customerHome),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RateDriverHeader extends StatelessWidget {
  const _RateDriverHeader({required this.onBack});

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
              dimension: 46,
              child: Center(
                child: _AssetIcon(
                  asset: AppAssets.arrowLeft,
                  color: JosiColors.ink,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Rate Rider',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: JosiColors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }
}

class _RateDriverStars extends StatelessWidget {
  const _RateDriverStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (int index = 0; index < 5; index += 1)
          const Icon(
            Icons.star_rounded,
            color: JosiColors.red,
            size: 48,
          ),
      ],
    );
  }
}

class _RateDriverReviewField extends StatelessWidget {
  const _RateDriverReviewField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey<String>('trip-rating-review-field'),
      minLines: 5,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: 'Enter here',
        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: JosiColors.softMuted,
              fontSize: 16,
            ),
        contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: JosiColors.ink,
            fontSize: 16,
          ),
    );
  }
}

enum _BookingActivityTab {
  active('Active'),
  completed('Completed'),
  cancelled('Cancelled');

  const _BookingActivityTab(this.label);

  final String label;

  String get key => switch (this) {
        _BookingActivityTab.active => 'activity-tab-active',
        _BookingActivityTab.completed => 'activity-tab-completed',
        _BookingActivityTab.cancelled => 'activity-tab-cancelled',
      };
}

class _BookingActivityItem {
  const _BookingActivityItem({
    required this.id,
    required this.driverName,
    required this.vehicle,
    required this.seats,
    required this.rating,
    required this.distance,
    required this.duration,
    required this.rate,
    required this.dateTime,
    required this.pickup,
    required this.destination,
    required this.carNumber,
    this.statusLabel,
    this.expanded = false,
  });

  final String id;
  final String? statusLabel;
  final String driverName;
  final String vehicle;
  final String seats;
  final String rating;
  final String distance;
  final String duration;
  final String rate;
  final String dateTime;
  final String pickup;
  final String destination;
  final String carNumber;
  final bool expanded;
}

const Map<_BookingActivityTab, List<_BookingActivityItem>>
    _bookingActivityItems = <_BookingActivityTab, List<_BookingActivityItem>>{
  _BookingActivityTab.active: <_BookingActivityItem>[
    _BookingActivityItem(
      id: 'TRP-2409',
      driverName: 'Jenny Wilson',
      vehicle: 'Sedan',
      seats: '4 Seater',
      rating: '5.0',
      distance: '4.5 Mile',
      duration: '4 mins',
      rate: r'$1.25',
      dateTime: 'Oct 18, 2023 | 08:00 AM',
      pickup: '6391 Elgin St. Celina, Delawa...',
      destination: '1901 Thornridge Cir. Sh...',
      carNumber: 'GR 678-UVWX',
      expanded: true,
    ),
  ],
  _BookingActivityTab.completed: <_BookingActivityItem>[
    _BookingActivityItem(
      id: 'TRP-2408',
      driverName: 'Byron Barlow',
      vehicle: 'MPV',
      seats: '5 Seater',
      rating: '5.0',
      distance: '4.5 Mile',
      duration: '4 mins',
      rate: r'$1.25',
      dateTime: 'Oct 18, 2023 | 08:00 AM',
      pickup: '6391 Elgin St. Celina, Delawa...',
      destination: '1901 Thornridge Cir. Sh...',
      carNumber: 'GR 678-UVWX',
    ),
    _BookingActivityItem(
      id: 'TRP-2411',
      driverName: 'Robert Fox',
      vehicle: 'MPV',
      seats: '5 Seater',
      rating: '5.0',
      distance: '4.5 Mile',
      duration: '4 mins',
      rate: r'$1.25',
      dateTime: 'Oct 18, 2023 | 08:00 AM',
      pickup: '6391 Elgin St. Celina, Delawa...',
      destination: '1901 Thornridge Cir. Sh...',
      carNumber: 'GR 678-UVWX',
    ),
  ],
  _BookingActivityTab.cancelled: <_BookingActivityItem>[
    _BookingActivityItem(
      id: 'TRP-2410',
      statusLabel: 'Cancelled by Rider',
      driverName: 'Cody Fisher',
      vehicle: 'MPV',
      seats: '5 Seater',
      rating: '5.0',
      distance: '4.5 Mile',
      duration: '4 mins',
      rate: r'$1.25',
      dateTime: 'Oct 18, 2023 | 08:00 AM',
      pickup: '6391 Elgin St. Celina, Delawa...',
      destination: '1901 Thornridge Cir. Sh...',
      carNumber: 'GR 678-UVWX',
    ),
    _BookingActivityItem(
      id: 'TRP-2412',
      statusLabel: 'Cancelled by You',
      driverName: 'Ralph Edwards',
      vehicle: 'MPV',
      seats: '5 Seater',
      rating: '5.0',
      distance: '4.5 Mile',
      duration: '4 mins',
      rate: r'$1.25',
      dateTime: 'Oct 18, 2023 | 08:00 AM',
      pickup: '6391 Elgin St. Celina, Delawa...',
      destination: '1901 Thornridge Cir. Sh...',
      carNumber: 'GR 678-UVWX',
    ),
  ],
};

class CustomerTripsScreen extends StatefulWidget {
  const CustomerTripsScreen({super.key});

  @override
  State<CustomerTripsScreen> createState() => _CustomerTripsScreenState();
}

class _CustomerTripsScreenState extends State<CustomerTripsScreen> {
  _BookingActivityTab _selectedTab = _BookingActivityTab.active;

  void _selectTab(_BookingActivityTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<_BookingActivityItem> items =
        _bookingActivityItems[_selectedTab] ?? <_BookingActivityItem>[];

    return Scaffold(
      key: const ValueKey<String>('customer-activity-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _ProfileHeader(
                    title: 'Bookings',
                    onBack: () => context.go(AppRoutes.customerHome),
                  ),
                ),
                const SizedBox(height: 18),
                _BookingTabs(
                  selectedTab: _selectedTab,
                  onSelected: _selectTab,
                ),
                Expanded(
                  child: ListView.separated(
                    key: const ValueKey<String>('booking-activity-list'),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    itemBuilder: (BuildContext context, int index) {
                      final _BookingActivityItem item = items[index];
                      return _BookingActivityCard(
                        item: item,
                        tab: _selectedTab,
                        onTap: () =>
                            context.push(AppRoutes.customerDriverDetails),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 16),
                    itemCount: items.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedTab: 'activity'),
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

    return Scaffold(
      key: const ValueKey<String>('customer-wallet-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _ProfileHeader(
                    title: 'Wallet',
                    onBack: () => context.go(AppRoutes.customerHome),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                    children: <Widget>[
                      summary.when(
                        data: (WalletSummary wallet) => Column(
                          children: <Widget>[
                            WalletBalanceCard(
                              key: const ValueKey<String>(
                                  'customer-wallet-balance-card'),
                              title: 'Available balance',
                              balance: wallet.availableBalance,
                              subtitle: 'Use wallet balance for faster rides',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: MetricTile(
                                    label: 'Today',
                                    value: wallet.todayEarnings,
                                    icon: Icons.today_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MetricTile(
                                    label: 'Pending',
                                    value: wallet.pendingRemittance,
                                    icon: Icons.hourglass_bottom_rounded,
                                    color: JosiColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        error: (Object error, StackTrace stackTrace) =>
                            const ErrorState(
                          title: 'Wallet unavailable',
                          message: 'Wallet balance could not load.',
                        ),
                        loading: () => const SizedBox(
                          height: 220,
                          child: LoadingState(label: 'Loading wallet'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Payment methods',
                        icon: Icons.credit_card_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () =>
                            context.go(AppRoutes.customerPaymentMethods),
                      ),
                      const SizedBox(height: 18),
                      const SectionHeader(title: 'Transactions'),
                      const SizedBox(height: 8),
                      transactions.when(
                        data: (List<WalletTransaction> values) => Column(
                          children: values
                              .map(
                                (WalletTransaction transaction) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _CustomerWalletTransactionCard(
                                    transaction: transaction,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        error: (Object error, StackTrace stackTrace) =>
                            const ErrorState(
                          title: 'Transactions unavailable',
                          message: 'Please try again later.',
                        ),
                        loading: () => const SizedBox(
                          height: 160,
                          child: LoadingState(label: 'Loading transactions'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(selectedTab: 'wallet'),
    );
  }
}

class _CustomerWalletTransactionCard extends StatelessWidget {
  const _CustomerWalletTransactionCard({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final Color color =
        transaction.isCredit ? JosiColors.success : JosiColors.red;

    return AppCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: JosiColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: JosiColors.muted,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                transaction.amount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: JosiColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                transaction.status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: JosiColors.muted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingTabs extends StatelessWidget {
  const _BookingTabs({
    required this.selectedTab,
    required this.onSelected,
  });

  final _BookingActivityTab selectedTab;
  final ValueChanged<_BookingActivityTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: JosiColors.line)),
      ),
      child: Row(
        children: <Widget>[
          for (final _BookingActivityTab tab in _BookingActivityTab.values)
            Expanded(
              child: _BookingTabButton(
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

class _BookingTabButton extends StatelessWidget {
  const _BookingTabButton({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final _BookingActivityTab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: selected ? JosiColors.red : JosiColors.muted,
          fontSize: 16,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        key: ValueKey<String>(tab.key),
        onTap: onTap,
        child: SizedBox(
          height: 54,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Center(child: Text(tab.label, style: style)),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 120 : 0,
                height: 4,
                decoration: const BoxDecoration(
                  color: JosiColors.red,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingActivityCard extends StatelessWidget {
  const _BookingActivityCard({
    required this.item,
    required this.tab,
    required this.onTap,
  });

  final _BookingActivityItem item;
  final _BookingActivityTab tab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      shadowColor: const Color(0x12000000),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: JosiColors.line),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (item.statusLabel != null) ...<Widget>[
                Text(
                  item.statusLabel!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: JosiColors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 14),
              ],
              _BookingDriverRow(item: item),
              const _BookingDivider(height: 26),
              _BookingStatsRow(item: item),
              const SizedBox(height: 18),
              _BookingDateRow(dateTime: item.dateTime),
              const _BookingDivider(height: 24),
              _BookingRouteSummary(
                pickup: item.pickup,
                destination: item.destination,
              ),
              const _BookingDivider(height: 22),
              _BookingCarNumberRow(carNumber: item.carNumber),
              if (item.expanded) ...<Widget>[
                const SizedBox(height: 14),
                const _BookingMiniMap(),
                const SizedBox(height: 18),
                const _BookingContactRow(),
                const SizedBox(height: 14),
                const _BookingActionRow(),
              ] else
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: JosiColors.ink,
                  size: 28,
                  semanticLabel: '${tab.label} booking collapsed control',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingDriverRow extends StatelessWidget {
  const _BookingDriverRow({required this.item});

  final _BookingActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            key: ValueKey<String>('activity-driver-details-link-${item.id}'),
            borderRadius: BorderRadius.circular(8),
            onTap: () => context.push(AppRoutes.customerDriverDetails),
            child: Row(
              children: <Widget>[
                _BookingDriverAvatar(name: item.driverName),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: JosiColors.ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.vehicle} ( ${item.seats})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: JosiColors.muted,
                              fontSize: 15,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.star_rounded, color: JosiColors.red, size: 26),
            const SizedBox(width: 6),
            Text(
              item.rating,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BookingContactRow extends StatelessWidget {
  const _BookingContactRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        _BookingContactButton(
          key: ValueKey<String>('booking-sms-button'),
          asset: AppAssets.sms,
          label: 'SMS',
        ),
        SizedBox(width: 12),
        _BookingContactButton(
          key: ValueKey<String>('booking-call-button'),
          asset: AppAssets.call,
          label: 'Call',
        ),
      ],
    );
  }
}

class _BookingContactButton extends StatelessWidget {
  const _BookingContactButton({
    required this.asset,
    required this.label,
    super.key,
  });

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: OutlinedButton.icon(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            backgroundColor: JosiColors.surface,
            foregroundColor: JosiColors.red,
            side: const BorderSide(color: JosiColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),
          icon: _AssetIcon(asset: asset, color: JosiColors.red, size: 18),
          label: Text(label),
        ),
      ),
    );
  }
}

class _BookingDriverAvatar extends StatelessWidget {
  const _BookingDriverAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final String initials = name
        .split(' ')
        .take(2)
        .map((String part) => part.isEmpty ? '' : part[0].toUpperCase())
        .join();

    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: JosiColors.redSoft,
        border: Border.all(color: JosiColors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: JosiColors.red,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _BookingStatsRow extends StatelessWidget {
  const _BookingStatsRow({required this.item});

  final _BookingActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _BookingStat(
            icon: Icons.location_on_outlined,
            value: item.distance,
          ),
        ),
        Expanded(
          child: _BookingStat(
            icon: Icons.access_time_rounded,
            value: item.duration,
          ),
        ),
        Expanded(
          child: _BookingStat(
            icon: Icons.work_outline_rounded,
            value: item.rate,
            suffix: '/mile',
          ),
        ),
      ],
    );
  }
}

class _BookingStat extends StatelessWidget {
  const _BookingStat({
    required this.icon,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: JosiColors.red, size: 24),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: JosiColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
              children: <InlineSpan>[
                TextSpan(text: value),
                if (suffix != null)
                  TextSpan(
                    text: ' $suffix',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: JosiColors.muted,
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingDateRow extends StatelessWidget {
  const _BookingDateRow({required this.dateTime});

  final String dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Date & Time',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: JosiColors.muted,
                fontSize: 14,
              ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            dateTime,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _BookingRouteSummary extends StatelessWidget {
  const _BookingRouteSummary({
    required this.pickup,
    required this.destination,
  });

  final String pickup;
  final String destination;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: Stack(
        children: <Widget>[
          const Positioned(
            left: 13,
            top: 31,
            bottom: 31,
            child: SizedBox(
              width: 2,
              child: CustomPaint(
                painter: _DashedLinePainter(color: JosiColors.softMuted),
              ),
            ),
          ),
          _BookingRoutePoint(
            icon: Icons.radio_button_checked_rounded,
            color: JosiColors.ink,
            text: pickup,
          ),
          Positioned(
            left: 48,
            right: 0,
            top: 42,
            child: Container(height: 1, color: JosiColors.line),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BookingRoutePoint(
              icon: Icons.location_on_rounded,
              color: JosiColors.red,
              text: destination,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRoutePoint extends StatelessWidget {
  const _BookingRoutePoint({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

class _BookingCarNumberRow extends StatelessWidget {
  const _BookingCarNumberRow({required this.carNumber});

  final String carNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          'Car Number',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: JosiColors.muted,
                fontSize: 14,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            carNumber,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _BookingMiniMap extends StatelessWidget {
  const _BookingMiniMap();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: const SizedBox(
        height: 126,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(painter: _BookingMiniMapPainter()),
            ),
            Positioned(
              left: 118,
              bottom: 24,
              child: _BookingMapPin(compact: true),
            ),
            Positioned(
              right: 52,
              bottom: 20,
              child: _BookingMapPin(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingMapPin extends StatelessWidget {
  const _BookingMapPin({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 30 : 46,
      height: compact ? 30 : 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: compact ? JosiColors.white : JosiColors.redSoft,
      ),
      child: Icon(
        compact ? Icons.location_on_rounded : Icons.radio_button_checked,
        color: JosiColors.red,
        size: compact ? 26 : 34,
      ),
    );
  }
}

class _BookingMiniMapPainter extends CustomPainter {
  const _BookingMiniMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint background = Paint()..color = const Color(0xFFF3F4F5);
    final Paint road = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    final Paint lane = Paint()
      ..color = const Color(0xFFDADDE1)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    final Paint route = Paint()
      ..color = JosiColors.ink
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Offset.zero & size, background);

    for (double x = -40; x < size.width + 40; x += 72) {
      canvas.drawLine(Offset(x, 0), Offset(x + 120, size.height), road);
      canvas.drawLine(Offset(x + 14, 0), Offset(x + 134, size.height), lane);
    }
    for (double y = 16; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 18), road);
      canvas.drawLine(Offset(0, y + 10), Offset(size.width, y + 28), lane);
    }

    final Path path = Path()
      ..moveTo(size.width * 0.34, size.height * 0.70)
      ..lineTo(size.width * 0.52, size.height * 0.28)
      ..lineTo(size.width * 0.78, size.height * 0.60);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant _BookingMiniMapPainter oldDelegate) => false;
}

class _BookingActionRow extends StatelessWidget {
  const _BookingActionRow();

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F2F2),
                foregroundColor: JosiColors.red,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                textStyle: labelStyle,
              ),
              child: const Text('Cancel'),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: JosiColors.red,
                foregroundColor: JosiColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                textStyle: labelStyle,
              ),
              child: const Text('Reschedule'),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingDivider extends StatelessWidget {
  const _BookingDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: Divider(height: 1, color: JosiColors.line)),
    );
  }
}

class _ManagedAddress {
  const _ManagedAddress({
    required this.title,
    required this.address,
  });

  final String title;
  final String address;
}

const List<_ManagedAddress> _managedAddresses = <_ManagedAddress>[
  _ManagedAddress(
    title: 'Home',
    address: '1901 Thornridge Cir. Shiloh, Hawaii 81063',
  ),
  _ManagedAddress(
    title: 'Office',
    address: '4517 Washington Ave. Manchester, Kentucky 39495',
  ),
  _ManagedAddress(
    title: "Parent's House",
    address: '8502 Preston Rd. Inglewood, Maine 98380',
  ),
  _ManagedAddress(
    title: "Friend's House",
    address: '2464 Royal Ln, Mesa, New Jersey 45463',
  ),
];

class CustomerManageAddressScreen extends StatelessWidget {
  const CustomerManageAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-manage-address-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 26),
                    children: <Widget>[
                      _ProfileHeader(
                        title: 'Manage Address',
                        onBack: () => context.go(AppRoutes.customerProfile),
                      ),
                      const SizedBox(height: 40),
                      for (int index = 0;
                          index < _managedAddresses.length;
                          index += 1) ...<Widget>[
                        _ManagedAddressRow(address: _managedAddresses[index]),
                        if (index != _managedAddresses.length - 1)
                          const Divider(height: 30, color: JosiColors.line),
                      ],
                      const SizedBox(height: 42),
                      _AddNewAddressButton(
                        onTap: () => context.go(AppRoutes.customerAddAddress),
                      ),
                    ],
                  ),
                ),
                _ManageAddressBottomBar(
                  onApply: () => context.go(AppRoutes.customerProfile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ManagedAddressRow extends StatelessWidget {
  const _ManagedAddressRow({required this.address});

  final _ManagedAddress address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _AddressPinIcon(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                address.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                address.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 15,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressPinIcon extends StatelessWidget {
  const _AddressPinIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          const Icon(
            Icons.location_on_outlined,
            color: JosiColors.ink,
            size: 38,
          ),
          Positioned(
            top: 12,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: JosiColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: JosiColors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddNewAddressButton extends StatelessWidget {
  const _AddNewAddressButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const ValueKey<String>('add-new-address-button'),
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: CustomPaint(
          painter: const _DashedRoundedBorderPainter(
            color: JosiColors.red,
            radius: 8,
          ),
          child: SizedBox(
            height: 64,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.add_rounded,
                      color: JosiColors.red, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'Add New Address',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: JosiColors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ManageAddressBottomBar extends StatelessWidget {
  const _ManageAddressBottomBar({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: JosiColors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: JosiColors.charcoal.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const ValueKey<String>('manage-address-apply-button'),
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: JosiColors.red,
                foregroundColor: JosiColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999)),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final RRect border = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(1);
    final Path path = Path()..addRRect(border);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = (distance + 8).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

enum _AddAddressLabel {
  home('Home'),
  office('Office'),
  parent('Parent\'s House'),
  friend('Friend\'s House');

  const _AddAddressLabel(this.label);

  final String label;
}

class CustomerAddAddressScreen extends StatefulWidget {
  const CustomerAddAddressScreen({super.key});

  @override
  State<CustomerAddAddressScreen> createState() =>
      _CustomerAddAddressScreenState();
}

class _CustomerAddAddressScreenState extends State<CustomerAddAddressScreen> {
  _AddAddressLabel _selectedLabel = _AddAddressLabel.home;

  void _selectLabel(_AddAddressLabel label) {
    setState(() {
      _selectedLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-add-address-screen'),
      backgroundColor: JosiColors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _AddAddressMapBackdrop()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: _ProfileHeader(
                    title: 'Add Address',
                    onBack: () => context.go(AppRoutes.customerManageAddress),
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: _AddAddressMapMarker()),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: _AddAddressSheet(
                selectedLabel: _selectedLabel,
                onLabelSelected: _selectLabel,
                onSave: () => context.go(AppRoutes.customerManageAddress),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressMapBackdrop extends StatelessWidget {
  const _AddAddressMapBackdrop();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _AddAddressMapPainter());
  }
}

class _AddAddressMapPainter extends CustomPainter {
  const _AddAddressMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFEDEFF1), BlendMode.src);

    final Paint road = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint lane = Paint()
      ..color = const Color(0xFFB7BDC5)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint minor = Paint()
      ..color = const Color(0xFFF8F9FA)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (double x = -size.width * 0.35; x < size.width * 1.2; x += 110) {
      canvas.drawLine(Offset(x, -40), Offset(x + 220, size.height), road);
      canvas.drawLine(Offset(x + 22, -40), Offset(x + 242, size.height), lane);
    }
    for (double y = -40; y < size.height * 0.8; y += 115) {
      canvas.drawLine(Offset(-40, y), Offset(size.width + 60, y + 80), road);
      canvas.drawLine(
          Offset(-40, y + 18), Offset(size.width + 60, y + 98), lane);
    }
    for (double y = 90; y < size.height * 0.64; y += 86) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 70), minor);
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 70), lane);
    }

    _drawStreetLabel(
        canvas, 'W Broadway', size.width * 0.16, size.height * 0.12, -1.08);
    _drawStreetLabel(
        canvas, 'Worth St', size.width * 0.36, size.height * 0.03, 0.58);
    _drawStreetLabel(
        canvas, 'Leonard St', size.width * 0.63, size.height * 0.05, 0.58);
    _drawStreetLabel(
        canvas, 'Reade St', size.width * 0.37, size.height * 0.29, 0.38);
    _drawStreetLabel(
        canvas, 'Broadway', size.width * 0.70, size.height * 0.22, -0.98);
    _drawStreetLabel(
        canvas, 'Chambers St', size.width * 0.28, size.height * 0.42, 0.38);
  }

  void _drawStreetLabel(
      Canvas canvas, String label, double x, double y, double angle) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF9EA3AA),
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AddAddressMapPainter oldDelegate) => false;
}

class _AddAddressMapMarker extends StatelessWidget {
  const _AddAddressMapMarker();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.25),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 36),
            child: Icon(Icons.location_on_rounded,
                color: JosiColors.red, size: 86),
          ),
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: JosiColors.white,
              border: Border.all(color: JosiColors.red, width: 5),
            ),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: JosiColors.ink,
              ),
              child: Text(
                'RS',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: JosiColors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressSheet extends StatelessWidget {
  const _AddAddressSheet({
    required this.selectedLabel,
    required this.onLabelSelected,
    required this.onSave,
  });

  final _AddAddressLabel selectedLabel;
  final ValueChanged<_AddAddressLabel> onLabelSelected;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: JosiColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Save address as *',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 15,
                    ),
              ),
              const SizedBox(height: 18),
              _AddAddressLabelSelector(
                selectedLabel: selectedLabel,
                onSelected: onLabelSelected,
              ),
              const SizedBox(height: 22),
              const _AddAddressField(
                key: ValueKey<String>('complete-address-field'),
                label: 'Complete address',
                hintText: 'Enter address *',
                height: 86,
              ),
              const SizedBox(height: 18),
              const _AddAddressField(
                key: ValueKey<String>('address-floor-field'),
                label: 'Floor',
                hintText: 'Enter Floor',
                height: 58,
              ),
              const SizedBox(height: 18),
              const _AddAddressField(
                key: ValueKey<String>('address-landmark-field'),
                label: 'Landmark',
                hintText: 'Enter Landmark',
                height: 58,
              ),
              const SizedBox(height: 26),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  key: const ValueKey<String>('save-address-button'),
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JosiColors.red,
                    foregroundColor: JosiColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  child: const Text('Save address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddAddressLabelSelector extends StatelessWidget {
  const _AddAddressLabelSelector({
    required this.selectedLabel,
    required this.onSelected,
  });

  final _AddAddressLabel selectedLabel;
  final ValueChanged<_AddAddressLabel> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final _AddAddressLabel label in _AddAddressLabel.values)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _AddAddressLabelChip(
                label: label,
                selected: label == selectedLabel,
                onTap: () => onSelected(label),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddAddressLabelChip extends StatelessWidget {
  const _AddAddressLabelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _AddAddressLabel label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? JosiColors.red : const Color(0xFFF2F2F2),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: ValueKey<String>(
            'address-label-${label.label.toLowerCase().replaceAll(' ', '-')}'),
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            label.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected ? JosiColors.white : JosiColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _AddAddressField extends StatelessWidget {
  const _AddAddressField({
    required this.label,
    required this.hintText,
    required this.height,
    super.key,
  });

  final String label;
  final String hintText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: JosiColors.ink,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: TextField(
            maxLines: height > 70 ? 3 : 1,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: JosiColors.softMuted.withValues(alpha: 0.62),
                    fontSize: 18,
                  ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            ),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 16,
                ),
          ),
        ),
      ],
    );
  }
}

enum _DriverDetailsTab {
  about('About'),
  review('Review');

  const _DriverDetailsTab(this.label);

  final String label;

  String get key => switch (this) {
        _DriverDetailsTab.about => 'driver-details-tab-about',
        _DriverDetailsTab.review => 'driver-details-tab-review',
      };
}

class CustomerDriverDetailsScreen extends StatefulWidget {
  const CustomerDriverDetailsScreen({super.key});

  @override
  State<CustomerDriverDetailsScreen> createState() =>
      _CustomerDriverDetailsScreenState();
}

class _CustomerDriverDetailsScreenState
    extends State<CustomerDriverDetailsScreen> {
  _DriverDetailsTab _selectedTab = _DriverDetailsTab.about;

  void _selectTab(_DriverDetailsTab tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _goBack(BuildContext context) {
    final GoRouter router = GoRouter.of(context);
    if (router.canPop()) {
      context.pop();
      return;
    }
    context.go(AppRoutes.customerHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('customer-driver-details-screen'),
      backgroundColor: JosiColors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              children: <Widget>[
                _ProfileHeader(
                  title: 'Rider Details',
                  onBack: () => _goBack(context),
                ),
                const SizedBox(height: 30),
                const _DriverDetailsHeader(),
                const SizedBox(height: 28),
                const Divider(color: JosiColors.line),
                const SizedBox(height: 22),
                const _DriverDetailsStats(),
                const SizedBox(height: 24),
                _DriverDetailsTabs(
                  selectedTab: _selectedTab,
                  onSelected: _selectTab,
                ),
                const SizedBox(height: 26),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _selectedTab == _DriverDetailsTab.about
                      ? const _DriverDetailsAbout(
                          key: ValueKey<String>('driver-details-about-panel'),
                        )
                      : const _DriverDetailsReviews(
                          key: ValueKey<String>('driver-details-review-panel'),
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

class _DriverDetailsHeader extends StatelessWidget {
  const _DriverDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const _VerifiedDriverAvatar(size: 112),
        const SizedBox(width: 22),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Jenny Wilson',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'example@gmail.com',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.softMuted,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(Icons.location_on_rounded,
                      color: JosiColors.red, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'New York, United Stats',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: JosiColors.softMuted,
                            fontSize: 16,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerifiedDriverAvatar extends StatelessWidget {
  const _VerifiedDriverAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFECEF), Color(0xFFFFD0D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: JosiColors.white, width: 3),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              'JW',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: JosiColors.red,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 12,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: JosiColors.red,
                shape: BoxShape.circle,
                border: Border.all(color: JosiColors.white, width: 4),
              ),
              child: const Icon(Icons.check_rounded,
                  color: JosiColors.white, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverDetailsStats extends StatelessWidget {
  const _DriverDetailsStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(
          child: _DriverDetailsStat(
            icon: Icons.groups_rounded,
            value: '7,500+',
            label: 'Customer',
          ),
        ),
        Expanded(
          child: _DriverDetailsStat(
            icon: Icons.business_center_rounded,
            value: '10+',
            label: 'Years Exp.',
          ),
        ),
        Expanded(
          child: _DriverDetailsStat(
            icon: Icons.star_rounded,
            value: '4.9+',
            label: 'Rating',
          ),
        ),
        Expanded(
          child: _DriverDetailsStat(
            icon: Icons.chat_bubble_rounded,
            value: '4,956',
            label: 'Review',
          ),
        ),
      ],
    );
  }
}

class _DriverDetailsStat extends StatelessWidget {
  const _DriverDetailsStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: JosiColors.red, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.red,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: JosiColors.softMuted,
                fontSize: 13,
              ),
        ),
      ],
    );
  }
}

class _DriverDetailsTabs extends StatelessWidget {
  const _DriverDetailsTabs({
    required this.selectedTab,
    required this.onSelected,
  });

  final _DriverDetailsTab selectedTab;
  final ValueChanged<_DriverDetailsTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: JosiColors.line)),
      ),
      child: Row(
        children: <Widget>[
          for (final _DriverDetailsTab tab in _DriverDetailsTab.values)
            Expanded(
              child: InkWell(
                key: ValueKey<String>(tab.key),
                onTap: () => onSelected(tab),
                child: SizedBox(
                  height: 54,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Center(
                        child: Text(
                          tab.label,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: tab == selectedTab
                                        ? JosiColors.red
                                        : JosiColors.softMuted,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: 4,
                        width: tab == selectedTab ? 180 : 0,
                        decoration: const BoxDecoration(
                          color: JosiColors.red,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DriverDetailsAbout extends StatelessWidget {
  const _DriverDetailsAbout({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 16,
                  height: 1.58,
                ),
            children: <InlineSpan>[
              const TextSpan(
                text:
                    'Professional Josi rider with verified ride history, clean vehicle records, and a strong customer rating. ',
              ),
              TextSpan(
                text: 'Read more',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.red,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationColor: JosiColors.red,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Rider Contact',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            const _DriverAvatar(name: 'Jenny Wilson', size: 54),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Jenny Wilson',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: JosiColors.ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rider',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: JosiColors.softMuted,
                          fontSize: 14,
                        ),
                  ),
                ],
              ),
            ),
            const _ContactRoundButton(asset: AppAssets.sms),
            const SizedBox(width: 12),
            const _ContactRoundButton(asset: AppAssets.call),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          'Car Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        const _DriverCarDetailRow(label: 'Car Model', value: 'Hyundai Verna'),
        const SizedBox(height: 14),
        const _DriverCarDetailRow(label: 'Car Number', value: 'GR 678-UVWX'),
        const SizedBox(height: 14),
        const _DriverCarDetailRow(label: 'Car Color', value: 'White'),
      ],
    );
  }
}

class _DriverCarDetailRow extends StatelessWidget {
  const _DriverCarDetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 16,
                ),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: JosiColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class _DriverDetailsReviews extends StatelessWidget {
  const _DriverDetailsReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Review',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: JosiColors.ink,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 14),
        const _DriverReviewCard(
          name: 'Rik Space',
          body: 'Clean car, fast pickup, and smooth driving.',
        ),
        const SizedBox(height: 12),
        const _DriverReviewCard(
          name: 'Fatima Bello',
          body: 'Jenny was polite and easy to reach during the trip.',
        ),
      ],
    );
  }
}

class _DriverReviewCard extends StatelessWidget {
  const _DriverReviewCard({
    required this.name,
    required this.body,
  });

  final String name;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JosiColors.white,
        border: Border.all(color: JosiColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: JosiColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Icon(Icons.star_rounded, color: JosiColors.red, size: 20),
              const SizedBox(width: 4),
              Text(
                '5.0',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: JosiColors.ink,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: JosiColors.softMuted,
                  fontSize: 14,
                ),
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
                      onTap: () => context.go(AppRoutes.customerManageAddress),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Payment Methods',
                      asset: AppAssets.card,
                      onTap: () => context.go(AppRoutes.customerPaymentMethods),
                    ),
                    _CustomerProfileMenuItem(
                      label: 'Settings',
                      icon: Icons.settings_outlined,
                      onTap: () => context.go(AppRoutes.customerSettings),
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
