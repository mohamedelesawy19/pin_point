// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core imports:
import '/core/constants/error_codes.dart';
import '/core/errors/exceptions.dart';

abstract interface class SecureStorage {
  Future<void> store(String key, String value);

  Future<String?> retrieve(String key);

  Future<void> delete(String key);

  Future<bool> contains(String key);

  Future<Map<String, String>> getAll();

  Future<void> clear();

  Future<bool> isAvailable();
}

class FlutterSecureStorageImpl implements SecureStorage {
  const FlutterSecureStorageImpl(FlutterSecureStorage storage)
    : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<void> store(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on Exception catch (e) {
      throw StorageException(
        message: e.toString(),
        code: StorageErrorCodes.write,
      );
    }
  }

  @override
  Future<String?> retrieve(String key) async {
    try {
      return await _storage.read(key: key);
    } on Exception catch (e) {
      throw StorageException(
        message: e.toString(),
        code: StorageErrorCodes.read,
      );
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on Exception catch (e) {
      throw StorageException(
        message: e.toString(),
        code: StorageErrorCodes.delete,
      );
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } on Exception catch (e) {
      throw StorageException(
        message: e.toString(),
        code: StorageErrorCodes.clear,
      );
    }
  }

  @override
  Future<bool> contains(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } on Exception catch (e) {
      throw StorageException(
        message: e.toString(),
        code: StorageErrorCodes.contains,
      );
    }
  }

  @override
  Future<Map<String, String>> getAll() async {
    try {
      return await _storage.readAll();
    } on Exception catch (e) {
      throw StorageException(
        message: e.toString(),
        code: StorageErrorCodes.getAll,
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Test storage availability by performing a write/read/delete cycle
      const testKey = '__pin_point_availability_test__';
      const testValue = 'test';

      await _storage.write(key: testKey, value: testValue);
      final readValue = await _storage.read(key: testKey);
      await _storage.delete(key: testKey);

      final isAvailable = readValue == testValue;

      return isAvailable;
    } on Exception catch (_) {
      return false;
    }
  }
}
