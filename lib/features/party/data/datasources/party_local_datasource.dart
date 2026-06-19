import '/core/constants/storage_constants.dart';
import '/core/storage/secure_storage.dart';

abstract class PartyLocalDataSource {
  Future<String?> getActivePartyCode();
  Future<void> saveActivePartyCode(String code);
  Future<void> clearActivePartyCode();
}

class PartyLocalDataSourceImpl implements PartyLocalDataSource {
  const PartyLocalDataSourceImpl({required this.secureStorage});

  final SecureStorage secureStorage;

  @override
  Future<String?> getActivePartyCode() async {
    return secureStorage.retrieve(StorageConstants.activePartyCode);
  }

  @override
  Future<void> saveActivePartyCode(String code) async {
    await secureStorage.store(StorageConstants.activePartyCode, code);
  }

  @override
  Future<void> clearActivePartyCode() async {
    await secureStorage.delete(StorageConstants.activePartyCode);
  }
}
