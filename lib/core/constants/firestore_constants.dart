/// All Firestore collection names, field keys, and tuning constants
/// for firestore.
///
/// Never use raw string literals in datasource / repository code;
/// always reference these constants so a schema change is a one-line fix.
abstract final class FirestoreConstants {
  // ── Collection ────────────────────────────────────────────────────────────
  static const String partiesCollection = 'parties';

  // ── Party-code generation ─────────────────────────────────────────────────
  static const int codeLength = 6;
  static const int maxCodeGenerationRetries = 5;

  /// Only uppercase letters + digits so codes are easy to read and type.
  static const String codeCharset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // ── Business rules ────────────────────────────────────────────────────────
  static const int maxPlayersPerParty = 8;
}
