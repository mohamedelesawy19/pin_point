import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/constants/storage_constants.dart';
import 'package:pin_point/core/storage/secure_storage.dart';
import 'package:pin_point/features/party/data/datasources/party_local_datasource.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late MockSecureStorage secureStorage;
  late PartyLocalDataSourceImpl dataSource;

  setUp(() {
    secureStorage = MockSecureStorage();

    dataSource = PartyLocalDataSourceImpl(secureStorage: secureStorage);
  });

  group('getActivePartyCode', () {
    test('should return active party code from secure storage', () async {
      // arrange
      const partyCode = 'ABC123';

      when(
        () => secureStorage.retrieve(StorageConstants.activePartyCode),
      ).thenAnswer((_) async => partyCode);

      // act
      final result = await dataSource.getActivePartyCode();

      // assert
      expect(result, partyCode);

      verify(
        () => secureStorage.retrieve(StorageConstants.activePartyCode),
      ).called(1);

      verifyNoMoreInteractions(secureStorage);
    });

    test('should return null when there is no active party code', () async {
      // arrange
      when(
        () => secureStorage.retrieve(StorageConstants.activePartyCode),
      ).thenAnswer((_) async => null);

      // act
      final result = await dataSource.getActivePartyCode();

      // assert
      expect(result, isNull);

      verify(
        () => secureStorage.retrieve(StorageConstants.activePartyCode),
      ).called(1);

      verifyNoMoreInteractions(secureStorage);
    });
  });

  group('saveActivePartyCode', () {
    test('should save active party code in secure storage', () async {
      // arrange
      const partyCode = 'ABC123';

      when(
        () => secureStorage.store(StorageConstants.activePartyCode, partyCode),
      ).thenAnswer((_) async {});

      // act
      await dataSource.saveActivePartyCode(partyCode);

      // assert
      verify(
        () => secureStorage.store(StorageConstants.activePartyCode, partyCode),
      ).called(1);

      verifyNoMoreInteractions(secureStorage);
    });
  });

  group('clearActivePartyCode', () {
    test('should delete active party code from secure storage', () async {
      // arrange
      when(
        () => secureStorage.delete(StorageConstants.activePartyCode),
      ).thenAnswer((_) async {});

      // act
      await dataSource.clearActivePartyCode();

      // assert
      verify(
        () => secureStorage.delete(StorageConstants.activePartyCode),
      ).called(1);

      verifyNoMoreInteractions(secureStorage);
    });
  });
}
