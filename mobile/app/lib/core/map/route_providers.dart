import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../location/location_providers.dart';
import 'route_service.dart';

final Provider<RouteService> routeServiceProvider = Provider<RouteService>(
  (Ref ref) => RouteService(),
);

final FutureProvider<RouteDetails> selectedTripRouteProvider =
    FutureProvider<RouteDetails>((Ref ref) {
  final LatLng pickup = ref.watch(selectedPickupProvider);
  final LatLng destination = ref.watch(selectedDestinationProvider);

  return ref.watch(routeServiceProvider).routeBetween(
        pickupLatitude: pickup.latitude,
        pickupLongitude: pickup.longitude,
        destinationLatitude: destination.latitude,
        destinationLongitude: destination.longitude,
      );
});

final mapRouteProvider = FutureProvider.family<RouteDetails, MapRouteRequest>(
  (Ref ref, MapRouteRequest request) {
    return ref.watch(routeServiceProvider).routeLatLng(
          pickup: request.origin,
          destination: request.destination,
        );
  },
);

class MapRouteRequest {
  const MapRouteRequest({
    required this.origin,
    required this.destination,
  });

  final LatLng origin;
  final LatLng destination;

  @override
  bool operator ==(Object other) {
    return other is MapRouteRequest &&
        other.origin.latitude == origin.latitude &&
        other.origin.longitude == origin.longitude &&
        other.destination.latitude == destination.latitude &&
        other.destination.longitude == destination.longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
  }
}
