import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/map_constants.dart';
import 'location_service.dart';

final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((Ref ref) {
  return const LocationService();
});

final FutureProvider<Position> currentLocationProvider =
    FutureProvider<Position>((Ref ref) {
  return ref.watch(locationServiceProvider).currentPosition();
});

final StateProvider<LatLng> selectedPickupProvider =
    StateProvider<LatLng>((Ref ref) {
  return MapConstants.defaultPickup;
});

final StateProvider<LatLng> selectedDestinationProvider =
    StateProvider<LatLng>((Ref ref) {
  return MapConstants.defaultDestination;
});

final Provider<ActiveTripMapState> activeTripMapProvider =
    Provider<ActiveTripMapState>((Ref ref) {
  return const ActiveTripMapState(
    pickup: MapConstants.defaultPickup,
    destination: MapConstants.defaultDestination,
    rider: MapConstants.mockRiderLocation,
  );
});

class ActiveTripMapState {
  const ActiveTripMapState({
    required this.pickup,
    required this.destination,
    required this.rider,
  });

  final LatLng pickup;
  final LatLng destination;
  final LatLng rider;

  Set<Marker> get customerTripMarkers => <Marker>{
        MapConstants.pickupMarker(pickup),
        MapConstants.destinationMarker(destination),
        MapConstants.riderMarker(rider),
      };

  Set<Marker> get riderTripMarkers => <Marker>{
        MapConstants.customerMarker(pickup),
        MapConstants.destinationMarker(destination),
        MapConstants.riderMarker(rider),
      };
}

extension PositionLatLng on Position {
  LatLng get latLng => LatLng(latitude, longitude);
}
