// Package imports:
import 'package:flutter/foundation.dart';

// Core imports:
import '/core/di/di_modules/auth_module.dart';
import '/core/di/di_modules/party_module.dart';
import '/core/di/di_modules/storage_module.dart';
import '/core/di/service_locator.dart';

/// Main dependency injection container that orchestrates the registration
/// of all application dependencies.
///
/// This class follows the modular approach where each logical group of
/// dependencies is registered in separate modules for better organization
/// and maintainability.
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize all dependencies
///   await InjectionContainer.init();
///
///   runApp(PinPoint());
/// }
/// ```
class InjectionContainer {
  InjectionContainer._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (_isInitialized) {
      debugPrint('Dependencies already initialized');
      return;
    }

    try {
      debugPrint('🚀 Initializing dependencies...');

      // Register dependencies in order of priority
      // Storage dependencies (secure storage, etc.)
      await StorageModule.register();

      // Auth feature dependencies
      await AuthModule.register();

      // Party feature dependencies
      await PartyModule.register();

      // Wait for all async dependencies to be ready
      debugPrint('⏳ Waiting for async dependencies...');
      await ServiceLocator.allReady(timeout: const Duration(seconds: 30));

      _isInitialized = true;
      debugPrint('✅ Dependencies initialized successfully');
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to initialize dependencies: $error');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<void> reset() async {
    debugPrint('🔄 Resetting dependencies...');
    await ServiceLocator.reset();
    _isInitialized = false;
    debugPrint('✅ Dependencies reset successfully');
  }

  static Future<void> reinit() async {
    await reset();
    await init();
  }

  static void createScope(String scopeName) {
    debugPrint('🔧 Creating scope: $scopeName');
    ServiceLocator.pushNewScope(scopeName: scopeName);
  }

  static Future<void> destroyScope() async {
    final scopeName = ServiceLocator.currentScopeName;
    debugPrint('🗑️ Destroying scope: $scopeName');
    await ServiceLocator.popScope();
  }
}
