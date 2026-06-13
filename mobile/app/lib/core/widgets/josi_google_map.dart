import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../theme/josi_colors.dart';

class JosiGoogleMap extends StatelessWidget {
  const JosiGoogleMap({
    required this.initialCameraPosition,
    super.key,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.myLocationEnabled = false,
    this.showCurrentLocationButton = true,
    this.isLoading = false,
    this.errorMessage,
    this.isPermissionPermanentlyDenied = false,
    this.onMapCreated,
    this.onTap,
    this.onCurrentLocationPressed,
    this.onRetryPermission,
    this.onContinueWithDefaultLocation,
    this.onOpenAppSettings,
  });

  static bool debugUseStaticMap = false;

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final bool myLocationEnabled;
  final bool showCurrentLocationButton;
  final bool isLoading;
  final String? errorMessage;
  final bool isPermissionPermanentlyDenied;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<LatLng>? onTap;
  final VoidCallback? onCurrentLocationPressed;
  final VoidCallback? onRetryPermission;
  final VoidCallback? onContinueWithDefaultLocation;
  final VoidCallback? onOpenAppSettings;

  @override
  Widget build(BuildContext context) {
    final Widget map = debugUseStaticMap
        ? _StaticJosiMap(markers: markers, onTap: onTap)
        : GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: myLocationEnabled,
            myLocationButtonEnabled: showCurrentLocationButton,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: onMapCreated,
            onTap: onTap,
          );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: map),
        if (showCurrentLocationButton && onCurrentLocationPressed != null)
          Positioned(
            right: 18,
            bottom: 24,
            child: _MapRoundButton(onPressed: onCurrentLocationPressed!),
          ),
        if (isLoading)
          const Positioned.fill(
            child: _MapLoadingOverlay(),
          ),
        if (errorMessage != null)
          Positioned.fill(
            child: _MapErrorOverlay(
              message: errorMessage!,
              isPermissionPermanentlyDenied: isPermissionPermanentlyDenied,
              onRetryPermission: onRetryPermission,
              onContinueWithDefaultLocation: onContinueWithDefaultLocation,
              onOpenAppSettings: onOpenAppSettings,
            ),
          ),
      ],
    );
  }
}

class _MapRoundButton extends StatelessWidget {
  const _MapRoundButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.white,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: const Color(0x22000000),
      child: IconButton(
        tooltip: 'Use current location',
        onPressed: onPressed,
        icon: const Icon(Icons.my_location_rounded, color: JosiColors.red),
      ),
    );
  }
}

class _MapLoadingOverlay extends StatelessWidget {
  const _MapLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x66FFFFFF),
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: JosiColors.white,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

class _MapErrorOverlay extends StatelessWidget {
  const _MapErrorOverlay({
    required this.message,
    required this.isPermissionPermanentlyDenied,
    this.onRetryPermission,
    this.onContinueWithDefaultLocation,
    this.onOpenAppSettings,
  });

  final String message;
  final bool isPermissionPermanentlyDenied;
  final VoidCallback? onRetryPermission;
  final VoidCallback? onContinueWithDefaultLocation;
  final VoidCallback? onOpenAppSettings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x99FFFFFF),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: JosiColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JosiColors.line),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: JosiColors.ink,
                      fontSize: 15,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 14),
              if (isPermissionPermanentlyDenied &&
                  onOpenAppSettings != null) ...<Widget>[
                ElevatedButton(
                  onPressed: onOpenAppSettings,
                  child: const Text('Open settings'),
                ),
              ] else if (onRetryPermission != null) ...<Widget>[
                ElevatedButton(
                  onPressed: onRetryPermission,
                  child: const Text('Request permission'),
                ),
              ],
              if (onContinueWithDefaultLocation != null) ...<Widget>[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onContinueWithDefaultLocation,
                  child: const Text('Continue with Abuja'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StaticJosiMap extends StatelessWidget {
  const _StaticJosiMap({
    required this.markers,
    this.onTap,
  });

  final Set<Marker> markers;
  final ValueChanged<LatLng>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        onTap?.call(const LatLng(9.0816, 7.4634));
      },
      child: CustomPaint(
        painter: _StaticJosiMapPainter(markers: markers.toList()),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _StaticJosiMapPainter extends CustomPainter {
  const _StaticJosiMapPainter({required this.markers});

  final List<Marker> markers;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4F6F5),
    );

    final Paint majorRoad = Paint()
      ..color = JosiColors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final Paint minorRoad = Paint()
      ..color = const Color(0xFFDCE3DF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final double x in <double>[0.18, 0.44, 0.70, 0.92]) {
      canvas.drawLine(
        Offset(size.width * x, -20),
        Offset(size.width * (x - 0.18), size.height + 20),
        majorRoad,
      );
    }
    for (final double y in <double>[0.18, 0.38, 0.58, 0.78]) {
      canvas.drawLine(
        Offset(-20, size.height * y),
        Offset(size.width + 20, size.height * (y + 0.12)),
        minorRoad,
      );
    }

    final List<Offset> slots = <Offset>[
      Offset(size.width * 0.32, size.height * 0.42),
      Offset(size.width * 0.62, size.height * 0.34),
      Offset(size.width * 0.50, size.height * 0.56),
      Offset(size.width * 0.72, size.height * 0.60),
    ];

    for (int index = 0; index < markers.length; index++) {
      final Marker marker = markers[index];
      final Offset point = slots[index % slots.length];
      final Color color = _colorForMarker(marker);
      canvas.drawCircle(point.translate(0, 12), 17,
          Paint()..color = color.withValues(alpha: 0.18));
      canvas.drawCircle(point, 15, Paint()..color = color);
      canvas.drawCircle(point, 5, Paint()..color = JosiColors.white);
    }
  }

  Color _colorForMarker(Marker marker) {
    final String id = marker.markerId.value;
    if (id.contains('rider')) {
      return const Color(0xFF1976D2);
    }
    if (id.contains('destination')) {
      return JosiColors.red;
    }
    if (id.contains('customer')) {
      return const Color(0xFF7B1FA2);
    }
    return const Color(0xFF188A42);
  }

  @override
  bool shouldRepaint(covariant _StaticJosiMapPainter oldDelegate) {
    return oldDelegate.markers != markers;
  }
}
