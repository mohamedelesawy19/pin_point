import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────

  static const primary = Color(0xFF2ED3FF);
  static const onPrimary = Color(0xFF04111F);
  static const primaryContainer = Color(0xFF114A66);
  static const onPrimaryContainer = Color(0xFFD8F8FF);

  static const secondary = Color(0xFFF5A623);
  static const onSecondary = Color(0xFF2B1C00);
  static const secondaryContainer = Color(0xFF5C4300);
  static const onSecondaryContainer = Color(0xFFFFF0C8);

  static const tertiary = Color(0xFFB56DFF);
  static const onTertiary = Color(0xFF1D0A33);
  static const tertiaryContainer = Color(0xFF43206D);
  static const onTertiaryContainer = Color(0xFFF0DEFF);

  // ── Neutral ───────────────────────────────────────────────────────────────

  static const background = Color(0xFF0A1628);
  static const onBackground = Color(0xFFF4F7FB);

  static const surface = Color(0xFF0A1628);
  static const onSurface = Color(0xFFF4F7FB);

  static const surfaceVariant = Color(0xFF1A2C48);
  static const onSurfaceVariant = Color(0xFFC2CFDD);

  static const outline = Color(0xFF4D607D);
  static const outlineVariant = Color(0xFF2B3D59);

  // ── Semantic ──────────────────────────────────────────────────────────────

  static const error = Color(0xFFFF5A5F);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFF5B1D25);
  static const onErrorContainer = Color(0xFFFFD9DC);

  static const success = Color(0xFF34E27A);
  static const onSuccess = Color(0xFF032814);
  static const successContainer = Color(0xFF145734);
  static const onSuccessContainer = Color(0xFFD8FFE8);

  static const warning = Color(0xFFFFA726);
  static const onWarning = Color(0xFF2B1700);
  static const warningContainer = Color(0xFF6A4200);
  static const onWarningContainer = Color(0xFFFFE9C5);
}
