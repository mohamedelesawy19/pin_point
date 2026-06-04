// Package imports:
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Core imports:
import '/core/router/app_routes.dart';

class MainRoutes {
  const MainRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      path: AppRoutes.initial,
      builder: (context, state) => const Scaffold(),
    ),
  ];
}
