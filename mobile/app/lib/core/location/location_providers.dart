import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/map_constants.dart';
import 'location_service.dart';
import 'reverse_geocoding_service.dart';

final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((Ref ref) {
  return const LocationService();
});

final Provider<ReverseGeocodingService> reverseGeocodingServiceProvider =
    Provider<ReverseGeocodingService>((Ref ref) {
  return const ReverseGeocodingService();
});

final FutureProvider<Position> currentLocationProvider =
    FutureProvider<Position>((Ref ref) {
  return ref.watch(locationServiceProvider).currentPosition();
});

final StateProvider<String> currentLocationAddressProvider =
    StateProvider<String>((Ref ref) {
  return 'Current Location';
});

final StateProvider<LatLng> selectedPickupProvider =
    StateProvider<LatLng>((Ref ref) {
  return MapConstants.defaultPickup;
});

final StateProvider<String> selectedPickupAddressProvider =
    StateProvider<String>((Ref ref) {
  return 'Current Location';
});

final StateProvider<LatLng> selectedDestinationProvider =
    StateProvider<LatLng>((Ref ref) {
  return MapConstants.defaultDestination;
});

final StateProvider<String> selectedDestinationAddressProvider =
    StateProvider<String>((Ref ref) {
  return '1901 Thornridge Cir. Shiloh';
});

final Provider<Map<String, Object>> tripLocationPayloadProvider =
    Provider<Map<String, Object>>((Ref ref) {
  final LatLng pickup = ref.watch(selectedPickupProvider);
  final LatLng destination = ref.watch(selectedDestinationProvider);
  final String pickupAddress = ref.watch(selectedPickupAddressProvider);
  final String destinationAddress =
      ref.watch(selectedDestinationAddressProvider);

  return <String, Object>{
    'pickup_latitude': pickup.latitude,
    'pickup_longitude': pickup.longitude,
    'pickup_address': pickupAddress,
    'destination_latitude': destination.latitude,
    'destination_longitude': destination.longitude,
    'destination_address': destinationAddress,
  };
});

final Provider<ActiveTripMapState> activeTripMapProvider =
    Provider<ActiveTripMapState>((Ref ref) {
  return ActiveTripMapState(
    pickup: ref.watch(selectedPickupProvider),
    destination: ref.watch(selectedDestinationProvider),
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
