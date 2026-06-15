import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

typedef RouteHttpPost = Future<RouteHttpResponse> Function(
  Uri uri, {
  required Map<String, String> headers,
  required Object? body,
});

enum RouteSource { backend, googleRoutes, fallback }

class RouteHttpResponse {
  const RouteHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}

class RouteDetails {
  const RouteDetails({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.source,
    this.encodedPolyline,
  });

  final List<LatLng> polylinePoints;
  final int distanceMeters;
  final int durationSeconds;
  final RouteSource source;
  final String? encodedPolyline;

  bool get isFallback => source == RouteSource.fallback;

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '$distanceMeters m';
    }

    final double kilometers = distanceMeters / 1000;
    final int decimals = kilometers >= 10 ? 0 : 1;
    return '${kilometers.toStringAsFixed(decimals)} km';
  }

  String get durationLabel {
    final int minutes = math.max(1, (durationSeconds / 60).ceil());
    if (minutes < 60) {
      return '$minutes min';
    }

    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }
}

class RouteFailure implements Exception {
  const RouteFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class RouteService {
  RouteService({
    String googleRoutesApiKey = const String.fromEnvironment(
      'JOSI_GOOGLE_ROUTES_API_KEY',
    ),
    String backendRouteEndpoint = const String.fromEnvironment(
      'JOSI_BACKEND_ROUTE_ENDPOINT',
    ),
    RouteHttpPost? httpPost,
  })  : _googleRoutesApiKey = googleRoutesApiKey.trim(),
        _backendRouteEndpoint = backendRouteEndpoint.trim(),
        _httpPost = httpPost ?? _defaultHttpPost;

  static const String failureMessage =
      'Unable to calculate route. Please check the selected locations.';

  static const String _googleRoutesEndpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  final String _googleRoutesApiKey;
  final String _backendRouteEndpoint;
  final RouteHttpPost _httpPost;

  Future<RouteDetails> routeBetween({
    required double pickupLatitude,
    required double pickupLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) {
    return routeLatLng(
      pickup: LatLng(pickupLatitude, pickupLongitude),
      destination: LatLng(destinationLatitude, destinationLongitude),
    );
  }

  Future<RouteDetails> routeLatLng({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    if (!_hasUsableCoordinates(pickup) || !_hasUsableCoordinates(destination)) {
      throw const RouteFailure(failureMessage);
    }

    if (_backendRouteEndpoint.isNotEmpty) {
      return _fetchBackendRoute(pickup: pickup, destination: destination);
    }

    if (_googleRoutesApiKey.isNotEmpty) {
      return _fetchGoogleRoutesRoute(pickup: pickup, destination: destination);
    }

    return fallbackRoute(pickup: pickup, destination: destination);
  }

  List<LatLng> decodePolyline(String encodedPolyline) {
    return decodeEncodedPolyline(encodedPolyline);
  }

  static List<LatLng> decodeEncodedPolyline(String encodedPolyline) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encodedPolyline.length) {
      final _DecodedPolylineValue decodedLatitude =
          _decodePolylineValue(encodedPolyline, index);
      index = decodedLatitude.nextIndex;
      latitude += decodedLatitude.value;

      final _DecodedPolylineValue decodedLongitude =
          _decodePolylineValue(encodedPolyline, index);
      index = decodedLongitude.nextIndex;
      longitude += decodedLongitude.value;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }

  static RouteDetails fallbackRoute({
    required LatLng pickup,
    required LatLng destination,
  }) {
    final int distanceMeters = _haversineDistanceMeters(pickup, destination);
    final int durationSeconds = math.max(
      60,
      (distanceMeters / 9.72).round(),
    );

    return RouteDetails(
      polylinePoints: <LatLng>[pickup, destination],
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      source: RouteSource.fallback,
    );
  }

  Future<RouteDetails> _fetchBackendRoute({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    try {
      final RouteHttpResponse response = await _httpPost(
        Uri.parse(_backendRouteEndpoint),
        headers: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, double>{
          'pickup_latitude': pickup.latitude,
          'pickup_longitude': pickup.longitude,
          'destination_latitude': destination.latitude,
          'destination_longitude': destination.longitude,
        }),
      );

      if (!_isSuccess(response.statusCode)) {
        throw const RouteFailure(failureMessage);
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        throw const RouteFailure(failureMessage);
      }

      final Map<String, Object?> payload =
          decoded['data'] is Map<String, Object?>
              ? decoded['data']! as Map<String, Object?>
              : decoded;
      return _routeFromBackendPayload(payload);
    } on RouteFailure {
      rethrow;
    } on Object {
      throw const RouteFailure(failureMessage);
    }
  }

  Future<RouteDetails> _fetchGoogleRoutesRoute({
    required LatLng pickup,
    required LatLng destination,
  }) async {
    try {
      final RouteHttpResponse response = await _httpPost(
        Uri.parse(_googleRoutesEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': _googleRoutesApiKey,
          'X-Goog-FieldMask':
              'routes.distanceMeters,routes.duration,routes.polyline.encodedPolyline',
        },
        body: jsonEncode(<String, Object>{
          'origin': _routeLocationPayload(pickup),
          'destination': _routeLocationPayload(destination),
          'travelMode': 'DRIVE',
          'routingPreference': 'TRAFFIC_UNAWARE',
          'computeAlternativeRoutes': false,
          'units': 'METRIC',
        }),
      );

      if (!_isSuccess(response.statusCode)) {
        throw const RouteFailure(failureMessage);
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        throw const RouteFailure(failureMessage);
      }

      final Object? routesValue = decoded['routes'];
      if (routesValue is! List<Object?> || routesValue.isEmpty) {
        throw const RouteFailure(failureMessage);
      }

      final Object? routeValue = routesValue.first;
      if (routeValue is! Map<String, Object?>) {
        throw const RouteFailure(failureMessage);
      }

      final Object? polylineValue = routeValue['polyline'];
      if (polylineValue is! Map<String, Object?>) {
        throw const RouteFailure(failureMessage);
      }

      final String encodedPolyline =
          (polylineValue['encodedPolyline'] as String?)?.trim() ?? '';
      final List<LatLng> points = decodeEncodedPolyline(encodedPolyline);
      if (points.length < 2) {
        throw const RouteFailure(failureMessage);
      }

      return RouteDetails(
        polylinePoints: points,
        distanceMeters: _intFromJson(routeValue['distanceMeters']),
        durationSeconds: _durationSecondsFromGoogle(routeValue['duration']),
        source: RouteSource.googleRoutes,
        encodedPolyline: encodedPolyline,
      );
    } on RouteFailure {
      rethrow;
    } on Object {
      throw const RouteFailure(failureMessage);
    }
  }

  RouteDetails _routeFromBackendPayload(Map<String, Object?> payload) {
    final String encodedPolyline =
        (payload['encoded_polyline'] as String?)?.trim() ?? '';
    final List<LatLng> points = decodeEncodedPolyline(encodedPolyline);
    if (points.length < 2) {
      throw const RouteFailure(failureMessage);
    }

    return RouteDetails(
      polylinePoints: points,
      distanceMeters: _intFromJson(payload['distance_meters']),
      durationSeconds: _intFromJson(payload['duration_seconds']),
      source: RouteSource.backend,
      encodedPolyline: encodedPolyline,
    );
  }

  static Map<String, Object> _routeLocationPayload(LatLng position) {
    return <String, Object>{
      'location': <String, Object>{
        'latLng': <String, double>{
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      },
    };
  }

  static bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool _hasUsableCoordinates(LatLng point) {
    return point.latitude >= -90 &&
        point.latitude <= 90 &&
        point.longitude >= -180 &&
        point.longitude <= 180;
  }

  static int _intFromJson(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int _durationSecondsFromGoogle(Object? value) {
    if (value is int || value is double) {
      return _intFromJson(value);
    }
    if (value is String) {
      final String seconds =
          value.endsWith('s') ? value.substring(0, value.length - 1) : value;
      return double.tryParse(seconds)?.round() ?? 0;
    }
    return 0;
  }

  static _DecodedPolylineValue _decodePolylineValue(
    String encodedPolyline,
    int startIndex,
  ) {
    int result = 0;
    int shift = 0;
    int index = startIndex;
    int byte;

    do {
      if (index >= encodedPolyline.length) {
        throw const FormatException('Invalid encoded polyline.');
      }
      byte = encodedPolyline.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);

    final int value = (result & 1) == 1 ? ~(result >> 1) : result >> 1;
    return _DecodedPolylineValue(value: value, nextIndex: index);
  }

  static int _haversineDistanceMeters(LatLng start, LatLng end) {
    const double earthRadiusMeters = 6371000;
    final double startLatitude = _degreesToRadians(start.latitude);
    final double endLatitude = _degreesToRadians(end.latitude);
    final double deltaLatitude =
        _degreesToRadians(end.latitude - start.latitude);
    final double deltaLongitude =
        _degreesToRadians(end.longitude - start.longitude);

    final double a = math.sin(deltaLatitude / 2) * math.sin(deltaLatitude / 2) +
        math.cos(startLatitude) *
            math.cos(endLatitude) *
            math.sin(deltaLongitude / 2) *
            math.sin(deltaLongitude / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (earthRadiusMeters * c).round();
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static Future<RouteHttpResponse> _defaultHttpPost(
    Uri uri, {
    required Map<String, String> headers,
    required Object? body,
  }) async {
    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final HttpClientRequest request = await client.postUrl(uri);
      headers.forEach(request.headers.set);
      if (body != null) {
        request.write(body is String ? body : jsonEncode(body));
      }

      final HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 16));
      final String responseBody = await utf8.decoder.bind(response).join();
      return RouteHttpResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}

class _DecodedPolylineValue {
  const _DecodedPolylineValue({
    required this.value,
    required this.nextIndex,
  });

  final int value;
  final int nextIndex;
}
