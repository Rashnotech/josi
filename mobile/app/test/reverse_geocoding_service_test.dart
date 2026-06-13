import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:josi_ride/core/location/reverse_geocoding_service.dart';

void main() {
  test('formats placemark into a readable address without duplicates', () {
    const ReverseGeocodingService service = ReverseGeocodingService();

    final String address = service.formatPlacemark(
      const Placemark(
        street: '',
        subLocality: 'Wuse 2',
        locality: 'Abuja',
        administrativeArea: 'Federal Capital Territory',
        country: 'Nigeria',
      ),
    );

    expect(address, 'Wuse 2, Abuja, Federal Capital Territory, Nigeria');
  });

  test('returns fallback when placemark has no readable fields', () {
    const ReverseGeocodingService service = ReverseGeocodingService();

    final String address = service.formatPlacemark(
      const Placemark(),
      fallback: 'Selected location',
    );

    expect(address, 'Selected location');
  });
}
