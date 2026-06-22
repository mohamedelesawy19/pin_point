import 'dart:math';

/// Calculates the great-circle distance between two geographic coordinates
/// using the Haversine formula.
///
/// This is a pure domain service with no external dependencies.
class CalculateDistanceUseCase {
  const CalculateDistanceUseCase();

  static const double _earthRadiusKm = 6371;

  /// Returns the distance in kilometres between (lat1, lon1) and (lat2, lon2).
  double call({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}
