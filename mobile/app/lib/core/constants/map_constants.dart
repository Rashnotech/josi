import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConstants {
  const MapConstants._();

  static const LatLng abuja = LatLng(9.0765, 7.3986);
  static const LatLng defaultPickup = LatLng(9.0765, 7.3986);
  static const LatLng defaultDestination = LatLng(9.0643, 7.4898);
  static const LatLng mockRiderLocation = LatLng(9.0708, 7.4442);
  static const LatLng mockCustomerLocation = LatLng(9.0805, 7.4206);

  static const double cityZoom = 13.5;
  static const double tripZoom = 14.2;

  static CameraPosition cameraFor(
    LatLng target, {
    double zoom = cityZoom,
  }) {
    return CameraPosition(target: target, zoom: zoom);
  }

  static Marker pickupMarker(LatLng position, {String id = 'pickup'}) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: const InfoWindow(title: 'Pickup'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
  }

  static Marker destinationMarker(
    LatLng position, {
    String id = 'destination',
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: const InfoWindow(title: 'Destination'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  static Marker riderMarker(LatLng position, {String id = 'rider'}) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: const InfoWindow(title: 'Rider'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
  }

  static Marker customerMarker(LatLng position, {String id = 'customer'}) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: const InfoWindow(title: 'Customer'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );
  }
}
