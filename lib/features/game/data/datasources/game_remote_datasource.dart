// Dart imports:
import 'dart:math';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// Core imports:
import '/core/constants/firestore_constants.dart';
import '/core/errors/exceptions.dart';

// Feature imports:
import '/features/game/data/models/game_round_model.dart';
import '/features/game/data/models/game_session_model.dart';
import '/features/game/data/models/landmark_model.dart';
import '/features/game/data/models/player_answer_model.dart';
import '/features/game/domain/entities/game_round_entity.dart';
import '/features/game/domain/entities/game_session_entity.dart';

abstract class GameRemoteDataSource {
  Future<void> initializeGameSession({
    required String partyCode,
    required String hostId,
    required int totalRounds,
    required Map<String, int> initialPlayerScores,
  });

  Future<void> startRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required LandmarkModel landmark,
    required int durationSeconds,
  });

  Future<void> endRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required List<PlayerAnswerModel> processedAnswers,
    required Map<String, int> updatedPlayerScores,
  });

  Future<void> endGame({required String partyCode, required String hostId});

  Future<void> submitAnswer({
    required String partyCode,
    required String playerId,
    required String playerName,
    String? photoUrl,
    required int roundIndex,
    required double latitude,
    required double longitude,
  });

  Stream<GameSessionModel> watchGameSession(String partyCode);

  Future<List<PlayerAnswerModel>> getRoundAnswers({
    required String partyCode,
    required int roundIndex,
  });

  Future<List<LandmarkModel>> getLandmarks({int count = 5});
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  const GameRemoteDataSourceImpl({required this._firestore});

  final FirebaseFirestore _firestore;

  // ── Private helpers ───────────────────────────────────────────────────────

  DocumentReference<GameSessionModel> _sessionDoc(String partyCode) =>
      _firestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .withConverter<GameSessionModel>(
            fromFirestore: (snapshot, _) =>
                GameSessionModel.fromFirestore(snapshot.data()!),
            toFirestore: (model, _) => model.toFirestore(),
          )
          .doc(partyCode);

  CollectionReference<PlayerAnswerModel> _answersCol(String partyCode) =>
      _firestore
          .collection(FirestoreConstants.gameSessionsCollection)
          .doc(partyCode)
          .collection(FirestoreConstants.answersCollection)
          .withConverter<PlayerAnswerModel>(
            fromFirestore: (snapshot, _) =>
                PlayerAnswerModel.fromFirestore(snapshot.data()!),
            toFirestore: (model, _) => model.toFirestore(),
          );

  Future<GameSessionModel> _getVerifiedSession({
    required String partyCode,
    required String hostId,
  }) async {
    final snapshot = await _sessionDoc(partyCode).get();

    final session = snapshot.data();

    if (!snapshot.exists || session == null) {
      throw ServerException(
        message: 'Game session "$partyCode" not found.',
        code: 'not-found',
      );
    }

    if (session.hostId != hostId) {
      throw const ServerException(
        message: 'Only the game host can perform this action.',
        code: 'permission-denied',
      );
    }

    return session;
  }

  // ── Host operations ────────────────────────────────────────────────────────

  @override
  Future<void> initializeGameSession({
    required String partyCode,
    required String hostId,
    required int totalRounds,
    required Map<String, int> initialPlayerScores,
  }) async {
    try {
      final session = GameSessionModel(
        partyCode: partyCode,
        hostId: hostId,
        status: GameStatus.initializing,
        currentRoundIndex: 0,
        totalRounds: totalRounds,
        playerScores: initialPlayerScores,
      );

      await _sessionDoc(partyCode).set(session);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in initializeGameSession',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> startRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required LandmarkModel landmark,
    required int durationSeconds,
  }) async {
    try {
      final session = await _getVerifiedSession(
        partyCode: partyCode,
        hostId: hostId,
      );

      if (session.status == GameStatus.finished) {
        throw const ServerException(
          message: 'Cannot start a round in a finished game.',
          code: 'invalid-state',
        );
      }

      if (session.currentRoundIndex >= session.totalRounds) {
        throw const ServerException(
          message: 'All rounds have already been played.',
          code: 'invalid-state',
        );
      }

      final now = DateTime.now().toUtc();

      final round = GameRoundModel(
        roundIndex: roundIndex,
        landmark: landmark,
        startedAt: now,
        endsAt: now.add(Duration(seconds: durationSeconds)),
        status: RoundStatus.active,
      );

      await _sessionDoc(partyCode).update({
        'status': GameStatus.roundActive.name,
        'currentRoundIndex': roundIndex,
        'currentRound': round.toFirestore(),
        'roundResults': null,
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in startRound',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> endRound({
    required String partyCode,
    required String hostId,
    required int roundIndex,
    required List<PlayerAnswerModel> processedAnswers,
    required Map<String, int> updatedPlayerScores,
  }) async {
    try {
      final session = await _getVerifiedSession(
        partyCode: partyCode,
        hostId: hostId,
      );

      if (session.status != GameStatus.roundActive) {
        throw const ServerException(
          message: 'No active round to end.',
          code: 'invalid-state',
        );
      }

      if (session.currentRoundIndex != roundIndex) {
        throw const ServerException(
          message: 'Round index mismatch.',
          code: 'invalid-state',
        );
      }

      final roundResults = processedAnswers
          .map((a) => a.toFirestore())
          .toList();

      // Dot-notation key updates the nested status field without overwriting
      // the rest of the currentRound map.
      await _sessionDoc(partyCode).update({
        'roundResults': roundResults,
        'playerScores': updatedPlayerScores,
        'currentRound.status': RoundStatus.results.name,
      });
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in endRound',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> endGame({
    required String partyCode,
    required String hostId,
  }) async {
    try {
      final session = await _getVerifiedSession(
        partyCode: partyCode,
        hostId: hostId,
      );

      if (session.status == GameStatus.finished) {
        return;
      }

      await _sessionDoc(partyCode).update({'status': GameStatus.finished.name});
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in endGame',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Player operations ──────────────────────────────────────────────────────

  @override
  Future<void> submitAnswer({
    required String partyCode,
    required String playerId,
    required String playerName,
    String? photoUrl,
    required int roundIndex,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final answer = PlayerAnswerModel(
        playerId: playerId,
        playerName: playerName,
        photoUrl: photoUrl,
        roundIndex: roundIndex,
        latitude: latitude,
        longitude: longitude,
        distanceKm: 0.0, // Populated by the host during endRound.
        score: 0, // Populated by the host during endRound.
        submittedAt: DateTime.now().toUtc(),
      );

      // Composite key enforces one submission per player per round.
      final docId = '${roundIndex}_$playerId';
      await _answersCol(partyCode).doc(docId).set(answer);
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in submitAnswer',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ── Shared operations ──────────────────────────────────────────────────────

  @override
  Stream<GameSessionModel> watchGameSession(String partyCode) {
    return _sessionDoc(partyCode).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        throw ServerException(
          message: 'Game session "$partyCode" not found.',
          code: 'not-found',
        );
      }

      return snapshot.data()!;
    });
  }

  @override
  Future<List<PlayerAnswerModel>> getRoundAnswers({
    required String partyCode,
    required int roundIndex,
  }) async {
    try {
      final snapshot = await _answersCol(
        partyCode,
      ).where('roundIndex', isEqualTo: roundIndex).get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in getRoundAnswers',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LandmarkModel>> getLandmarks({int count = 5}) async {
    try {
      // Fetch a pool 4× the requested count (clamped to a reasonable ceiling)
      // then sample randomly client-side.
      final fetchLimit = (count * 4).clamp(20, 200);

      final snapshot = await _firestore
          .collection(FirestoreConstants.landmarksCollection)
          .withConverter<LandmarkModel>(
            fromFirestore: (snapshot, _) {
              return LandmarkModel.fromFirestore({
                ...snapshot.data()!,
                'id': snapshot.id,
              });
            },
            toFirestore: (model, _) => model.toFirestore(),
          )
          .limit(fetchLimit)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(
          message: 'No landmarks found in the database.',
          code: 'not-found',
        );
      }

      final all = snapshot.docs.map((doc) => doc.data()).toList()
        ..shuffle(Random());
      return all.take(count).toList();
    } on ServerException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Firestore error in getLandmarks',
        code: e.code,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
