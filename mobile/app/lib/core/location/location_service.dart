import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  unavailable,
}

class LocationFailure implements Exception {
  const LocationFailure({
    required this.reason,
    required this.message,
  });

  final LocationFailureReason reason;
  final String message;

  bool get canRequestAgain => reason == LocationFailureReason.permissionDenied;

  bool get canOpenSettings =>
      reason == LocationFailureReason.permissionPermanentlyDenied;

  @override
  String toString() => message;
}

class LocationService {
  const LocationService();

  Future<Position> currentPosition() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(
        reason: LocationFailureReason.serviceDisabled,
        message: 'Turn on phone location services and try again.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        reason: LocationFailureReason.permissionDenied,
        message: 'Location permission was denied.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        reason: LocationFailureReason.permissionPermanentlyDenied,
        message:
            'Location permission is permanently denied. Open app settings to turn it on.',
      );
    }

    try {
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } on LocationServiceDisabledException {
      throw const LocationFailure(
        reason: LocationFailureReason.serviceDisabled,
        message: 'Turn on phone location services and try again.',
      );
    } on PermissionDeniedException {
      throw const LocationFailure(
        reason: LocationFailureReason.permissionDenied,
        message: 'Location permission was denied.',
      );
    } on TimeoutException {
      throw const LocationFailure(
        reason: LocationFailureReason.unavailable,
        message: 'GPS took too long to find your position.',
      );
    } on Object {
      throw const LocationFailure(
        reason: LocationFailureReason.unavailable,
        message: 'Phone GPS could not find your position.',
      );
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
