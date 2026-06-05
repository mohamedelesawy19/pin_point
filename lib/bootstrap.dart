// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core imports:
import '/core/di/injection_container.dart';
import '/core/error_handling/global_error_handler.dart';
import '/core/observers/app_bloc_observer.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Setup DI
    await InjectionContainer.init();

    // 2. Setup BLoC observer
    Bloc.observer = const AppBlocObserver();

    // 3. Setup global error handler
    FlutterError.onError = GlobalErrorHandler.onFlutterError;
    PlatformDispatcher.instance.onError = GlobalErrorHandler.onPlatformError;

    runApp(await builder());
  }, GlobalErrorHandler.onZoneError);
}
