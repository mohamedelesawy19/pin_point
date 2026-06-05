// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core imports:
import '/core/di/service_locator.dart';
import '/core/storage/secure_storage.dart';

/// Storage module for registering all storage-related dependencies.
class StorageModule {
  StorageModule._();

  static Future<void> register() async {
    await _registerSecureStorage();

    debugPrint('✅ Storage dependencies registered');
  }

  // ========================================================================
  // Secure Storage Registration
  // ========================================================================

  static Future<void> _registerSecureStorage() async {
    ServiceLocator.registerLazySingleton<SecureStorage>(
      () => const FlutterSecureStorageImpl(
        FlutterSecureStorage(
          iOptions: IOSOptions(
            accessibility: KeychainAccessibility.first_unlock_this_device,
          ),
        ),
      ),
    );
  }
}
