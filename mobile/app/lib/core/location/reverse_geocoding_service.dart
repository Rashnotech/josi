import 'package:geocoding/geocoding.dart';

class ReverseGeocodingService {
  const ReverseGeocodingService();

  Future<String> addressFromCoordinates({
    required double latitude,
    required double longitude,
    String fallback = 'Selected location',
  }) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) {
        return fallback;
      }
      return formatPlacemark(placemarks.first, fallback: fallback);
    } catch (_) {
      return fallback;
    }
  }

  String formatPlacemark(
    Placemark placemark, {
    String fallback = 'Selected location',
  }) {
    final List<String> parts = <String?>[
      placemark.street,
      placemark.subLocality,
      placemark.locality,
      placemark.administrativeArea,
      placemark.country,
    ]
        .whereType<String>()
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList();

    final List<String> uniqueParts = <String>[];
    for (final String part in parts) {
      final String normalized = part.toLowerCase();
      final bool alreadyAdded = uniqueParts.any(
        (String existing) => existing.toLowerCase() == normalized,
      );
      if (!alreadyAdded) {
        uniqueParts.add(part);
      }
    }

    if (uniqueParts.isEmpty) {
      return fallback;
    }
    return uniqueParts.join(', ');
  }
}
