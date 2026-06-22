// Dart imports:
import 'dart:math';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/errors/exceptions.dart';

// Feature imports:
import '/features/party/data/models/party_model.dart';
import '/features/party/data/models/party_settings_model.dart';
import '/features/party/data/models/player_model.dart';
import '/features/party/domain/entities/party_entity.dart';

abstract class PartyRemoteDataSource {
  Future<String> createParty({
    required PlayerModel hostPlayer,
    required String partyName,
    required PartySettingsModel settings,
  });
  Future<String> joinParty({
    required String partyCode,
    required PlayerModel player,
  });
  Future<void> startGame({required String partyCode, required String hostId});
  Future<void> kickPlayer({
    required String partyCode,
    required String targetUid,
    required String hostId,
  });
  Future<void> leaveParty({required String partyCode, required String uid});
  Future<PartyModel?> getParty(String partyCode);
  Stream<PartyModel> watchParty(String partyCode);
}

/*
Firestore schema (parties/{partyCode})

{
  partyCode:    String,
  hostId:       String,
  hostName:     String,
  partyName:    String,
  status:       "waiting" | "playing" | "finished",
  settings:     { roundDurationSeconds: int, totalRounds: int },
  players:      Map<uid, PlayerData>,   ← map for atomic field updates
  currentRound: int,
  createdAt:    String (ISO-8601 UTC),
}
*/

class PartyRemoteDataSourceImpl implements PartyRemoteDataSource {
  const PartyRemoteDataSourceImpl({required this._firestore});

  final FirebaseFirestore _firestore;

  // ── Private helpers ───────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _parties =>
      _firestore.collection(FirestoreConstants.partiesCollection);

  DocumentReference<Map<String, dynamic>> _partyRef(String partyCode) =>
      _parties.doc(partyCode);

  Future<String> _generateUniqueCode() async {
    final random = Random.secure();

    const digits = '0123456789';
    const length = FirestoreConstants.codeLength;
    const maxRetries = FirestoreConstants.maxCodeGenerationRetries;

    for (var attempt = 0; attempt < maxRetries; attempt++) {
      final code = List.generate(
        length,
        (_) => digits[random.nextInt(digits.length)],
      ).join();

      final exists = (await _partyRef(code).get()).exists;
      if (!exists) return code;
    }

    throw const ServerException(
      message: 'Failed to generate a unique party code. Please try again.',
    );
  }

  // ── PartyRemoteDataSource ─────────────────────────────────────────────────

  @override
  Future<String> createParty({
    required PlayerModel hostPlayer,
    required String partyName,
    required PartySettingsModel settings,
  }) async {
    try {
      final code = await _generateUniqueCode();

      final party = PartyModel(
        partyCode: code,
        hostId: hostPlayer.uid,
        hostName: hostPlayer.displayName,
        partyName: partyName,
        status: PartyStatus.waiting,
        settings: settings,
        players: [hostPlayer],
        kickedPlayers: const {},
        currentRound: 0,
        createdAt: DateTime.now().toUtc(),
      );

      await _partyRef(code).set(party.toFirestore());
      return code;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code);
    }
  }

  @override
  Future<String> joinParty({
    required String partyCode,
    required PlayerModel player,
  }) async {
    try {
      await _firestore.runTransaction<void>((tx) async {
        final ref = _partyRef(partyCode);
        final snapshot = await tx.get(ref);

        if (!snapshot.exists) {
          throw const ServerException(message: 'Party not found');
        }

        final data = snapshot.data()!;

        final status = PartyStatus.values.byName(data['status'] as String);
        if (status != PartyStatus.waiting) {
          throw const ServerException(
            message: 'Party is no longer accepting players.',
          );
        }

        // ── Block rejoining for previously kicked players ──────────────────
        final kickedPlayers =
            data['kickedPlayers'] as Map<String, dynamic>? ?? {};
        if (kickedPlayers.containsKey(player.uid)) {
          throw const ServerException(
            message: 'You have been removed from this party and cannot rejoin.',
          );
        }

        final rawPlayers = data['players'] as Map<String, dynamic>? ?? {};

        if (rawPlayers.containsKey(player.uid)) {
          throw const ServerException(
            message: 'Player is already in the party.',
          );
        }

        if (rawPlayers.length >= FirestoreConstants.maxPlayersPerParty) {
          throw const ServerException(message: 'Party is full.');
        }

        // Dot-notation key → atomic single-field update inside the map.
        tx.update(ref, {'${'players'}.${player.uid}': player.toJson()});
      });

      return partyCode;
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code);
    }
  }

  @override
  Future<void> startGame({
    required String partyCode,
    required String hostId,
  }) async {
    try {
      await _firestore.runTransaction<void>((tx) async {
        final ref = _partyRef(partyCode);
        final snapshot = await tx.get(ref);

        if (!snapshot.exists) {
          throw const ServerException(message: 'Party not found');
        }

        final data = snapshot.data()!;

        if ((data['hostId'] as String) != hostId) {
          throw const ServerException(
            message: 'Only the host can perform this action.',
          );
        }

        final status = PartyStatus.values.byName(data['status'] as String);
        if (status != PartyStatus.waiting) {
          throw const ServerException(
            message: 'Party is no longer accepting players.',
          );
        }

        tx.update(ref, {'status': PartyStatus.playing.name, 'currentRound': 1});
      });
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code);
    }
  }

  @override
  Future<void> kickPlayer({
    required String partyCode,
    required String targetUid,
    required String hostId,
  }) async {
    try {
      await _firestore.runTransaction<void>((tx) async {
        final ref = _partyRef(partyCode);
        final snapshot = await tx.get(ref);

        if (!snapshot.exists) {
          throw const ServerException(message: 'Party not found');
        }

        final data = snapshot.data()!;

        if ((data['hostId'] as String) != hostId) {
          throw const ServerException(
            message: 'Only the host can perform this action.',
          );
        }

        if (targetUid == hostId) {
          throw const ServerException(message: 'Host cannot kick themselves.');
        }

        tx.update(ref, {
          'players.$targetUid': FieldValue.delete(),
          'kickedPlayers.$targetUid': FieldValue.serverTimestamp(),
        });
      });
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code);
    }
  }

  @override
  Future<void> leaveParty({
    required String partyCode,
    required String uid,
  }) async {
    try {
      await _firestore.runTransaction<void>((tx) async {
        final ref = _partyRef(partyCode);
        final snapshot = await tx.get(ref);

        // Already gone — treat as a successful no-op.
        if (!snapshot.exists) return;

        final hostId = snapshot.data()!['hostId'] as String;

        if (hostId == uid) {
          // Host leaving → destroy the entire party so no orphaned lobbies.
          tx.delete(ref);
        } else {
          tx.update(ref, {'${'players'}.$uid': FieldValue.delete()});
        }
      });
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code);
    }
  }

  @override
  Future<PartyModel?> getParty(String partyCode) async {
    try {
      final snapshot = await _partyRef(partyCode).get();
      if (!snapshot.exists) return null;
      return PartyModel.fromFirestore(snapshot);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? e.code);
    }
  }

  @override
  Stream<PartyModel> watchParty(String partyCode) {
    return _partyRef(partyCode)
        .snapshots()
        .map((snapshot) => PartyModel.fromFirestore(snapshot))
        .handleError((Object error) {
          if (error is ServerException) throw error;
          if (error is FirebaseException) {
            throw ServerException(message: error.message ?? error.code);
          }
          throw ServerException(message: error.toString());
        });
  }
}
