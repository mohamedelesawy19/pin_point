// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/party/data/datasources/party_remote_datasource.dart';
import '/features/party/data/models/party_settings_model.dart';
import '/features/party/data/models/player_model.dart';
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/domain/entities/player_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  PartyRepositoryImpl({required this._dataSource});

  final PartyRemoteDataSource _dataSource;

  // ── PartyRepository ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> createParty({
    required PlayerEntity hostPlayer,
    required String partyName,
    required PartySettings settings,
  }) async {
    try {
      final code = await _dataSource.createParty(
        hostPlayer: PlayerModel.fromEntity(hostPlayer),
        partyName: partyName,
        settings: PartySettingsModel.fromEntity(settings),
      );

      return Right(code);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> joinParty({
    required String partyCode,
    required PlayerEntity player,
  }) async {
    try {
      final code = await _dataSource.joinParty(
        partyCode: partyCode,
        player: PlayerModel.fromEntity(player),
      );
      return Right(code);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> startGame({
    required String partyCode,
    required String hostId,
  }) async {
    try {
      await _dataSource.startGame(partyCode: partyCode, hostId: hostId);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> kickPlayer({
    required String partyCode,
    required String targetUid,
    required String hostId,
  }) async {
    try {
      await _dataSource.kickPlayer(
        partyCode: partyCode,
        targetUid: targetUid,
        hostId: hostId,
      );
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveParty({
    required String partyCode,
    required String uid,
  }) async {
    try {
      await _dataSource.leaveParty(partyCode: partyCode, uid: uid);
      return const Right(unit);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<PartyEntity> watchParty(String partyCode) {
    return _dataSource.watchParty(partyCode).map((model) => model.toEntity());
  }
}
