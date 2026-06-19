// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';

// Feature imports:
import '/features/party/data/datasources/party_local_datasource.dart';
import '/features/party/data/datasources/party_remote_datasource.dart';
import '/features/party/data/models/party_settings_model.dart';
import '/features/party/data/models/player_model.dart';
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/domain/entities/player_entity.dart';
import '/features/party/domain/repositories/party_repository.dart';

class PartyRepositoryImpl implements PartyRepository {
  PartyRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
  });

  final PartyRemoteDataSource _remoteDataSource;
  final PartyLocalDataSource _localDataSource;

  // ── PartyRepository ───────────────────────────────────────────────────────

  @override
  Future<Either<Failure, String>> createParty({
    required PlayerEntity hostPlayer,
    required String partyName,
    required PartySettings settings,
  }) async {
    try {
      final code = await _remoteDataSource.createParty(
        hostPlayer: PlayerModel.fromEntity(hostPlayer),
        partyName: partyName,
        settings: PartySettingsModel.fromEntity(settings),
      );

      await _localDataSource.saveActivePartyCode(code);

      return Right(code);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> joinParty({
    required String partyCode,
    required PlayerEntity player,
  }) async {
    try {
      final code = await _remoteDataSource.joinParty(
        partyCode: partyCode,
        player: PlayerModel.fromEntity(player),
      );

      await _localDataSource.saveActivePartyCode(code);

      return Right(code);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> startGame({
    required String partyCode,
    required String hostId,
  }) async {
    try {
      await _remoteDataSource.startGame(partyCode: partyCode, hostId: hostId);
      return const Right(unit);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> kickPlayer({
    required String partyCode,
    required String targetUid,
    required String hostId,
  }) async {
    try {
      await _remoteDataSource.kickPlayer(
        partyCode: partyCode,
        targetUid: targetUid,
        hostId: hostId,
      );
      return const Right(unit);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveParty({
    required String partyCode,
    required String uid,
  }) async {
    try {
      await _remoteDataSource.leaveParty(partyCode: partyCode, uid: uid);

      await _localDataSource.clearActivePartyCode();

      return const Right(unit);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getActivePartyCode() async {
    try {
      final code = await _localDataSource.getActivePartyCode();
      return Right(code);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearActivePartyCode() async {
    try {
      await _localDataSource.clearActivePartyCode();
      return const Right(unit);
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PartyEntity?>> getParty(String code) async {
    try {
      final model = await _remoteDataSource.getParty(code);
      return Right(model?.toEntity());
    } on BaseException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<PartyEntity> watchParty(String partyCode) {
    return _remoteDataSource
        .watchParty(partyCode)
        .map((model) => model.toEntity());
  }
}
