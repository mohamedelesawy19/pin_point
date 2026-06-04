import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/constants/error_codes.dart';
import 'package:pin_point/core/errors/exceptions.dart';
import 'package:pin_point/core/storage/secure_storage.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late FlutterSecureStorage mockStorage;
  late FlutterSecureStorageImpl secureStorage;

  const key = 'test_key';
  const value = 'test_value';

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    secureStorage = FlutterSecureStorageImpl(mockStorage);
  });

  group('store', () {
    test('should write value successfully', () async {
      when(
        () => mockStorage.write(key: key, value: value),
      ).thenAnswer((_) async {});

      await secureStorage.store(key, value);

      verify(() => mockStorage.write(key: key, value: value)).called(1);
    });

    test('should throw StorageException on failure', () async {
      when(
        () => mockStorage.write(key: key, value: value),
      ).thenThrow(Exception('write failed'));

      expect(
        () => secureStorage.store(key, value),
        throwsA(
          isA<StorageException>().having(
            (e) => e.code,
            'code',
            StorageErrorCodes.write,
          ),
        ),
      );
    });
  });

  group('retrieve', () {
    test('should return stored value', () async {
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => value);

      final result = await secureStorage.retrieve(key);

      expect(result, value);

      verify(() => mockStorage.read(key: key)).called(1);
    });

    test('should return null when key does not exist', () async {
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

      final result = await secureStorage.retrieve(key);

      expect(result, isNull);
    });

    test('should throw StorageException on failure', () async {
      when(
        () => mockStorage.read(key: key),
      ).thenThrow(Exception('read failed'));

      expect(
        () => secureStorage.retrieve(key),
        throwsA(
          isA<StorageException>().having(
            (e) => e.code,
            'code',
            StorageErrorCodes.read,
          ),
        ),
      );
    });
  });

  group('delete', () {
    test('should delete key successfully', () async {
      when(() => mockStorage.delete(key: key)).thenAnswer((_) async {});

      await secureStorage.delete(key);

      verify(() => mockStorage.delete(key: key)).called(1);
    });

    test('should throw StorageException on failure', () async {
      when(
        () => mockStorage.delete(key: key),
      ).thenThrow(Exception('delete failed'));

      expect(
        () => secureStorage.delete(key),
        throwsA(
          isA<StorageException>().having(
            (e) => e.code,
            'code',
            StorageErrorCodes.delete,
          ),
        ),
      );
    });
  });

  group('clear', () {
    test('should clear storage successfully', () async {
      when(() => mockStorage.deleteAll()).thenAnswer((_) async {});

      await secureStorage.clear();

      verify(() => mockStorage.deleteAll()).called(1);
    });

    test('should throw StorageException on failure', () async {
      when(() => mockStorage.deleteAll()).thenThrow(Exception('clear failed'));

      expect(
        () => secureStorage.clear(),
        throwsA(
          isA<StorageException>().having(
            (e) => e.code,
            'code',
            StorageErrorCodes.clear,
          ),
        ),
      );
    });
  });

  group('contains', () {
    test('should return true when key exists', () async {
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => value);

      final result = await secureStorage.contains(key);

      expect(result, isTrue);
    });

    test('should return false when key does not exist', () async {
      when(() => mockStorage.read(key: key)).thenAnswer((_) async => null);

      final result = await secureStorage.contains(key);

      expect(result, isFalse);
    });

    test('should throw StorageException on failure', () async {
      when(
        () => mockStorage.read(key: key),
      ).thenThrow(Exception('contains failed'));

      expect(
        () => secureStorage.contains(key),
        throwsA(
          isA<StorageException>().having(
            (e) => e.code,
            'code',
            StorageErrorCodes.contains,
          ),
        ),
      );
    });
  });

  group('getAll', () {
    test('should return all stored values', () async {
      final data = {'key1': 'value1', 'key2': 'value2'};

      when(() => mockStorage.readAll()).thenAnswer((_) async => data);

      final result = await secureStorage.getAll();

      expect(result, data);
    });

    test('should throw StorageException on failure', () async {
      when(() => mockStorage.readAll()).thenThrow(Exception('get all failed'));

      expect(
        () => secureStorage.getAll(),
        throwsA(
          isA<StorageException>().having(
            (e) => e.code,
            'code',
            StorageErrorCodes.getAll,
          ),
        ),
      );
    });
  });

  group('isAvailable', () {
    test('should return true when storage is available', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'test');

      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      final result = await secureStorage.isAvailable();

      expect(result, isTrue);
    });

    test('should return false when storage throws exception', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception());

      final result = await secureStorage.isAvailable();

      expect(result, isFalse);
    });
  });
}
