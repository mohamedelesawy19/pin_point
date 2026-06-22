/// Converts a distance in kilometres to a point value according to the
/// game's scoring rules.
///
/// This is a pure domain service with no external dependencies.
///
/// Scoring brackets:
/// - < 10 km  → 50 points
/// - < 100 km → 30 points
/// - < 500 km → 10 points
/// - ≥ 500 km →  1 point
class CalculateScoreUseCase {
  const CalculateScoreUseCase();

  int call(double distanceKm) {
    if (distanceKm < 10) return 50;
    if (distanceKm < 100) return 30;
    if (distanceKm < 500) return 10;
    return 1;
  }
}
