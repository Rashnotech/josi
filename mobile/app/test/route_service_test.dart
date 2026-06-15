import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:josi_ride/core/map/route_service.dart';

void main() {
  test('decodes an encoded Google polyline into map points', () {
    final List<LatLng> points = RouteService.decodeEncodedPolyline(
      '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    );

    expect(points, hasLength(3));
    expect(points[0].latitude, closeTo(38.5, 0.00001));
    expect(points[0].longitude, closeTo(-120.2, 0.00001));
    expect(points[1].latitude, closeTo(40.7, 0.00001));
    expect(points[1].longitude, closeTo(-120.95, 0.00001));
    expect(points[2].latitude, closeTo(43.252, 0.00001));
    expect(points[2].longitude, closeTo(-126.453, 0.00001));
  });

  test('calls the Laravel-ready backend route endpoint', () async {
    Uri? requestUri;
    Map<String, Object?>? requestBody;

    final RouteService service = RouteService(
      backendRouteEndpoint: 'https://api.josi.test/api/v1/maps/route',
      httpPost: (
        Uri uri, {
        required Map<String, String> headers,
        required Object? body,
      }) async {
        requestUri = uri;
        requestBody = jsonDecode(body! as String) as Map<String, Object?>;
        return const RouteHttpResponse(
          statusCode: 200,
          body:
              '{"distance_meters":8500,"duration_seconds":1200,"encoded_polyline":"_p~iF~ps|U_ulLnnqC_mqNvxq`@"}',
        );
      },
    );

    final RouteDetails route = await service.routeBetween(
      pickupLatitude: 9.0765,
      pickupLongitude: 7.3986,
      destinationLatitude: 9.0579,
      destinationLongitude: 7.4951,
    );

    expect(requestUri?.path, '/api/v1/maps/route');
    expect(requestBody?['pickup_latitude'], 9.0765);
    expect(requestBody?['pickup_longitude'], 7.3986);
    expect(requestBody?['destination_latitude'], 9.0579);
    expect(requestBody?['destination_longitude'], 7.4951);
    expect(route.source, RouteSource.backend);
    expect(route.distanceMeters, 8500);
    expect(route.durationSeconds, 1200);
    expect(route.distanceLabel, '8.5 km');
    expect(route.durationLabel, '20 min');
    expect(route.polylinePoints, hasLength(3));
  });

  test('uses a straight-line fallback when no route API is configured',
      () async {
    final RouteService service = RouteService();

    final RouteDetails route = await service.routeLatLng(
      pickup: const LatLng(9.0765, 7.3986),
      destination: const LatLng(9.0579, 7.4951),
    );

    expect(route.source, RouteSource.fallback);
    expect(route.polylinePoints, hasLength(2));
    expect(route.distanceMeters, greaterThan(8000));
    expect(route.durationSeconds, greaterThan(60));
  });

  test('returns a clean failure when a configured route call fails', () async {
    final RouteService service = RouteService(
      googleRoutesApiKey: 'dev-key',
      httpPost: (
        Uri uri, {
        required Map<String, String> headers,
        required Object? body,
      }) async {
        return const RouteHttpResponse(statusCode: 500, body: '{}');
      },
    );

    expect(
      service.routeLatLng(
        pickup: const LatLng(9.0765, 7.3986),
        destination: const LatLng(9.0579, 7.4951),
      ),
      throwsA(
        isA<RouteFailure>().having(
          (RouteFailure failure) => failure.message,
          'message',
          RouteService.failureMessage,
        ),
      ),
    );
  });
}
