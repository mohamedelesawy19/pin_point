class AppRoutes {
  const AppRoutes._();

  // ── Main Routes ──────────────────────────────────────────────────────

  static const splash = '/';
  static const login = '/login';
  static const main = '/main';

  // ── Party Routes ─────────────────────────────────────────────────────

  static const createParty = '/party/create';
  static const lobby = '/party/lobby';
  static const resumeLobby = '/party/lobby/resume';

  // Declare which routes are accessible without authentication.
  static const publicRoutes = {login};
}
