// Package imports:
import 'package:dartz/dartz.dart';

// Core imports:
import '/core/errors/failures.dart';

// Feature imports:
import '/features/party/domain/entities/party_entity.dart';
import '/features/party/domain/entities/party_settings.dart';
import '/features/party/domain/entities/player_entity.dart';

abstract class PartyRepository {
  Future<Either<Failure, String>> createParty({
    required PlayerEntity hostPlayer,
    required String partyName,
    required PartySettings settings,
  });
  Future<Either<Failure, String>> joinParty({
    required String partyCode,
    required PlayerEntity player,
  });
  Future<Either<Failure, Unit>> startGame({
    required String partyCode,
    required String hostId,
  });
  Future<Either<Failure, Unit>> kickPlayer({
    required String partyCode,
    required String targetUid,
    required String hostId,
  });
  Future<Either<Failure, Unit>> leaveParty({
    required String partyCode,
    required String uid,
  });
  Future<Either<Failure, String?>> getActivePartyCode();
  Future<Either<Failure, Unit>> clearActivePartyCode();
  Future<Either<Failure, PartyEntity?>> getParty(String code);
  Stream<PartyEntity> watchParty(String partyCode);
}

/*
Party Flow:

createParty or joinParty → watchParty (stream) → startGame
                         ↘ kickPlayer
                         ↘ leaveParty
*/
