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

  /// Forward geocoding: resolves a free-text address into coordinates.
  ///
  /// Used when selecting a saved address that predates coordinate capture
  /// (older `CustomerSavedAddress` rows saved before latitude/longitude were
  /// recorded) so the booking flow can still request a trip at a real
  /// position instead of a stale default.
  Future<Location?> coordinatesFromAddress(String address) async {
    if (address.trim().isEmpty) {
      return null;
    }
    try {
      final List<Location> locations = await locationFromAddress(address);
      return locations.isEmpty ? null : locations.first;
    } catch (_) {
      return null;
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
