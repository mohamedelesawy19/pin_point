class AppRoutes {
  const AppRoutes._();

  // ── Main Routes ──────────────────────────────────────────────────────

  static const splash = '/';
  static const login = '/login';
  static const main = '/main';

  // Declare which routes are accessible without authentication.
  static const publicRoutes = {login};
}
