import 'package:flutter/services.dart';

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  String get displayLabel =>
      'Lat ${latitude.toStringAsFixed(5)}, Lng ${longitude.toStringAsFixed(5)}';
}

class DeviceLocationException implements Exception {
  const DeviceLocationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DeviceLocationService {
  const DeviceLocationService();

  static const String channelName = 'josi_ride/device_location';
  static const MethodChannel _channel = MethodChannel(channelName);

  Future<DeviceLocation> currentPosition() async {
    try {
      final Object? response =
          await _channel.invokeMethod<Object?>('currentPosition');
      if (response is! Map<Object?, Object?>) {
        throw const DeviceLocationException(
          'Phone GPS returned an unreadable position.',
        );
      }

      final Object? latitude = response['latitude'];
      final Object? longitude = response['longitude'];
      if (latitude is! num || longitude is! num) {
        throw const DeviceLocationException(
          'Phone GPS returned an incomplete position.',
        );
      }

      return DeviceLocation(
        latitude: latitude.toDouble(),
        longitude: longitude.toDouble(),
      );
    } on PlatformException catch (error) {
      throw DeviceLocationException(_messageFor(error.code));
    }
  }

  String _messageFor(String code) {
    return switch (code) {
      'PERMISSION_DENIED' => 'Location permission was denied.',
      'LOCATION_DISABLED' => 'Turn on phone location services and try again.',
      'LOCATION_TIMEOUT' => 'GPS took too long to find your position.',
      'LOCATION_BUSY' => 'GPS is already finding your position.',
      _ => 'Phone GPS could not find your position.',
    };
  }
}
