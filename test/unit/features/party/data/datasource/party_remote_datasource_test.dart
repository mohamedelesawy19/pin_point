// ignore_for_file: subtype_of_sealed_class

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Core imports:
import 'package:pin_point/core/constants/firestore_constants.dart';
import 'package:pin_point/core/errors/exceptions.dart';

// Feature imports:
import 'package:pin_point/features/party/data/datasources/party_remote_datasource.dart';
import 'package:pin_point/features/party/data/models/party_model.dart';
import 'package:pin_point/features/party/data/models/party_settings_model.dart';
import 'package:pin_point/features/party/data/models/player_model.dart';
import 'package:pin_point/features/party/domain/entities/party_entity.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class FakeTransactionHandler extends Fake {}

// ── Mocks ───────────────────────────────────────────────────────────────────

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockTransaction extends Mock implements Transaction {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockStream extends Mock
    implements Stream<DocumentSnapshot<Map<String, dynamic>>> {}

class FakeDocumentReference<T> extends Fake implements DocumentReference<T> {}

class FakeCollectionReference<T> extends Fake
    implements CollectionReference<T> {}

// ── Test Fixtures ────────────────────────────────────────────────────────────

const _partyCode = '123456';
const _hostId = 'host-uid-001';
const _playerUid = 'player-uid-002';
const _partyName = 'Test Party';

const _mockHostPlayer = PlayerModel(
  uid: _hostId,
  displayName: 'Host Player',
  isAnonymous: false,
  score: 0,
);

const _mockGuestPlayer = PlayerModel(
  uid: _playerUid,
  displayName: 'Guest Player',
  isAnonymous: false,
  score: 0,
);

const _mockSettings = PartySettingsModel(
  roundDurationSeconds: 60,
  totalRounds: 5,
);

Map<String, dynamic> _waitingPartyData({Map<String, dynamic>? extraPlayers}) =>
    {
      'partyCode': _partyCode,
      'hostId': _hostId,
      'hostName': 'Host Player',
      'partyName': _partyName,
      'status': 'waiting',
      'settings': {'roundDurationSeconds': 60, 'totalRounds': 5},
      'players': {
        _hostId: {
          'uid': _hostId,
          'displayName': 'Host Player',
          'isAnonymous': false,
          'score': 0,
        },
        ...?extraPlayers,
      },
      'currentRound': 0,
      'createdAt': Timestamp.now(),
    };

// ── Main ─────────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockDocumentSnapshot mockSnapshot;
  late MockTransaction mockTransaction;
  late PartyRemoteDataSourceImpl dataSource;

  setUpAll(() {
    registerFallbackValue(Duration.zero);
    registerFallbackValue((Transaction tx) async => null);
    registerFallbackValue(FakeDocumentReference<Map<String, dynamic>>());
    registerFallbackValue(FakeDocumentReference<Object?>());
    registerFallbackValue(FakeCollectionReference<Map<String, dynamic>>());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();
    mockTransaction = MockTransaction();

    // Wire: firestore.collection(...) → mockCollection → mockDocRef
    when(
      () => mockFirestore.collection(any<String>()),
    ).thenReturn(mockCollection);
    when(() => mockCollection.doc(any<String>())).thenReturn(mockDocRef);

    dataSource = PartyRemoteDataSourceImpl(firestore: mockFirestore);
  });

  // ── Helper: simulate runTransaction ────────────────────────────────────────

  /// Captures the callback passed to [runTransaction] and executes it
  /// synchronously with [mockTransaction].
  void stubTransaction() {
    // Stub for any runTransaction call
    // We use dynamic/Object? to catch as much as possible,
    // but we may need specific ones for void/String if inference is tricky.
    when(() => mockFirestore.runTransaction<void>(any())).thenAnswer((
      invocation,
    ) async {
      final callback =
          invocation.positionalArguments[0]
              as Future<void> Function(Transaction);
      return callback(mockTransaction);
    });

    when(() => mockFirestore.runTransaction<String>(any())).thenAnswer((
      invocation,
    ) async {
      final callback =
          invocation.positionalArguments[0]
              as Future<String> Function(Transaction);
      return callback(mockTransaction);
    });

    // Also stub with named args just in case some other code uses them
    when(
      () => mockFirestore.runTransaction<void>(
        any(),
        timeout: any(named: 'timeout'),
        maxAttempts: any(named: 'maxAttempts'),
      ),
    ).thenAnswer((invocation) async {
      final callback =
          invocation.positionalArguments[0]
              as Future<void> Function(Transaction);
      return callback(mockTransaction);
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // createParty
  // ──────────────────────────────────────────────────────────────────────────

  group('createParty', () {
    setUp(() {
      // First doc-check: code does NOT exist → unique code found.
      when(() => mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any())).thenAnswer((_) async {});
    });

    test('returns the generated party code on success', () async {
      final result = await dataSource.createParty(
        hostPlayer: _mockHostPlayer,
        partyName: _partyName,
        settings: _mockSettings,
      );

      expect(result, isA<String>());
      expect(result, hasLength(FirestoreConstants.codeLength));
      verify(() => mockDocRef.set(any())).called(1);
    });

    test(
      'throws ServerException when all code-generation retries are exhausted',
      () async {
        // All codes already exist.
        when(() => mockSnapshot.exists).thenReturn(true);

        await expectLater(
          () => dataSource.createParty(
            hostPlayer: _mockHostPlayer,
            partyName: _partyName,
            settings: _mockSettings,
          ),
          throwsA(isA<ServerException>()),
        );
      },
    );

    test('wraps FirebaseException in ServerException', () async {
      when(() => mockDocRef.set(any())).thenThrow(
        FirebaseException(plugin: 'firestore', message: 'permission-denied'),
      );

      await expectLater(
        () => dataSource.createParty(
          hostPlayer: _mockHostPlayer,
          partyName: _partyName,
          settings: _mockSettings,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('permission-denied'),
          ),
        ),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // joinParty
  // ──────────────────────────────────────────────────────────────────────────

  group('joinParty', () {
    setUp(stubTransaction);

    test('returns the partyCode on success', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(_waitingPartyData());
      when(
        () => mockTransaction.update(mockDocRef, any()),
      ).thenReturn(mockTransaction);

      final result = await dataSource.joinParty(
        partyCode: _partyCode,
        player: _mockGuestPlayer,
      );

      expect(result, equals(_partyCode));
      verify(() => mockTransaction.update(mockDocRef, any())).called(1);
    });

    test('throws ServerException when party does not exist', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);

      await expectLater(
        () => dataSource.joinParty(
          partyCode: _partyCode,
          player: _mockGuestPlayer,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('not found'),
          ),
        ),
      );
    });

    test('throws ServerException when party status is not waiting', () async {
      final playingData = {..._waitingPartyData(), 'status': 'playing'};

      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(playingData);

      await expectLater(
        () => dataSource.joinParty(
          partyCode: _partyCode,
          player: _mockGuestPlayer,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'throws ServerException when player is already in the party',
      () async {
        // Data already contains _playerUid.
        final dataWithPlayer = _waitingPartyData(
          extraPlayers: {
            _playerUid: {
              'uid': _playerUid,
              'displayName': 'Guest Player',
              'isAnonymous': false,
              'score': 0,
            },
          },
        );

        when(
          () => mockTransaction.get(mockDocRef),
        ).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(true);
        when(() => mockSnapshot.data()).thenReturn(dataWithPlayer);

        await expectLater(
          () => dataSource.joinParty(
            partyCode: _partyCode,
            player: _mockGuestPlayer,
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('already in the party'),
            ),
          ),
        );
      },
    );

    test('throws ServerException when party is full', () async {
      // Build a party with maxPlayersPerParty entries.
      final fullPlayers = {
        for (var i = 0; i < FirestoreConstants.maxPlayersPerParty; i++)
          'uid-$i': {
            'uid': 'uid-$i',
            'displayName': 'Player $i',
            'isAnonymous': false,
            'score': 0,
          },
      };
      final fullData = _waitingPartyData(extraPlayers: fullPlayers);

      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(fullData);

      await expectLater(
        () => dataSource.joinParty(
          partyCode: _partyCode,
          player: _mockGuestPlayer,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('full'),
          ),
        ),
      );
    });

    test('wraps FirebaseException in ServerException', () async {
      when(
        () => mockFirestore.runTransaction<void>(
          any(),
          timeout: any(named: 'timeout'),
          maxAttempts: any(named: 'maxAttempts'),
        ),
      ).thenThrow(
        FirebaseException(plugin: 'firestore', message: 'unavailable'),
      );

      await expectLater(
        () => dataSource.joinParty(
          partyCode: _partyCode,
          player: _mockGuestPlayer,
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // startGame
  // ──────────────────────────────────────────────────────────────────────────

  group('startGame', () {
    setUp(stubTransaction);

    test('completes successfully when host starts a waiting party', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(_waitingPartyData());
      when(
        () => mockTransaction.update(mockDocRef, any()),
      ).thenReturn(mockTransaction);

      await expectLater(
        dataSource.startGame(partyCode: _partyCode, hostId: _hostId),
        completes,
      );

      verify(
        () => mockTransaction.update(mockDocRef, {
          'status': PartyStatus.playing.name,
          'currentRound': 1,
        }),
      ).called(1);
    });

    test('throws ServerException when party does not exist', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);

      await expectLater(
        () => dataSource.startGame(partyCode: _partyCode, hostId: _hostId),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException when caller is not the host', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(_waitingPartyData());

      await expectLater(
        () =>
            dataSource.startGame(partyCode: _partyCode, hostId: 'not-the-host'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Only the host'),
          ),
        ),
      );
    });

    test('throws ServerException when party is already playing', () async {
      final playingData = {..._waitingPartyData(), 'status': 'playing'};

      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(playingData);

      await expectLater(
        () => dataSource.startGame(partyCode: _partyCode, hostId: _hostId),
        throwsA(isA<ServerException>()),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // kickPlayer
  // ──────────────────────────────────────────────────────────────────────────

  group('kickPlayer', () {
    setUp(stubTransaction);

    test('removes target player when called by host', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(_waitingPartyData());
      when(
        () => mockTransaction.update(mockDocRef, any()),
      ).thenReturn(mockTransaction);

      await expectLater(
        dataSource.kickPlayer(
          partyCode: _partyCode,
          targetUid: _playerUid,
          hostId: _hostId,
        ),
        completes,
      );

      verify(
        () => mockTransaction.update(mockDocRef, {
          'players.$_playerUid': isA<FieldValue>(),
        }),
      ).called(1);
    });

    test('throws ServerException when party does not exist', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);

      await expectLater(
        () => dataSource.kickPlayer(
          partyCode: _partyCode,
          targetUid: _playerUid,
          hostId: _hostId,
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('throws ServerException when caller is not the host', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(_waitingPartyData());

      await expectLater(
        () => dataSource.kickPlayer(
          partyCode: _partyCode,
          targetUid: _playerUid,
          hostId: 'not-the-host',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Only the host'),
          ),
        ),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────────────
  // leaveParty
  // ──────────────────────────────────────────────────────────────────────────

  group('leaveParty', () {
    setUp(stubTransaction);

    test('deletes the party document when the host leaves', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(_waitingPartyData());
      when(
        () => mockTransaction.delete(mockDocRef),
      ).thenReturn(mockTransaction);

      await expectLater(
        dataSource.leaveParty(partyCode: _partyCode, uid: _hostId),
        completes,
      );

      verify(() => mockTransaction.delete(mockDocRef)).called(1);
      verifyNever(() => mockTransaction.update(any(), any()));
    });

    test('removes the player field when a non-host player leaves', () async {
      when(
        () => mockTransaction.get(mockDocRef),
      ).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);
      when(() => mockSnapshot.data()).thenReturn(
        _waitingPartyData(
          extraPlayers: {
            _playerUid: {
              'uid': _playerUid,
              'displayName': 'Guest Player',
              'isAnonymous': false,
              'score': 0,
            },
          },
        ),
      );
      when(
        () => mockTransaction.update(mockDocRef, any()),
      ).thenReturn(mockTransaction);

      await expectLater(
        dataSource.leaveParty(partyCode: _partyCode, uid: _playerUid),
        completes,
      );

      verify(
        () => mockTransaction.update(mockDocRef, {
          'players.$_playerUid': isA<FieldValue>(),
        }),
      ).called(1);
      verifyNever(() => mockTransaction.delete(any()));
    });

    test(
      'completes silently when party document does not exist (no-op)',
      () async {
        when(
          () => mockTransaction.get(mockDocRef),
        ).thenAnswer((_) async => mockSnapshot);
        when(() => mockSnapshot.exists).thenReturn(false);

        await expectLater(
          dataSource.leaveParty(partyCode: _partyCode, uid: _playerUid),
          completes,
        );

        verifyNever(() => mockTransaction.delete(any()));
        verifyNever(() => mockTransaction.update(any(), any()));
      },
    );
  });

  // ──────────────────────────────────────────────────────────────────────────
  // watchParty
  // ──────────────────────────────────────────────────────────────────────────

  group('watchParty', () {
    test('emits PartyModel when snapshot is valid', () async {
      final mockDocSnapshot = MockDocumentSnapshot();
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.data()).thenReturn(_waitingPartyData());
      when(() => mockDocSnapshot.id).thenReturn(_partyCode);

      when(
        () => mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));

      // PartyModel.fromFirestore must be able to parse _waitingPartyData().
      expect(dataSource.watchParty(_partyCode), emits(isA<PartyModel>()));
    });

    test(
      'emits ServerException when FirebaseException occurs in stream',
      () async {
        when(() => mockDocRef.snapshots()).thenAnswer(
          (_) => Stream.error(
            FirebaseException(
              plugin: 'firestore',
              message: 'permission-denied',
            ),
          ),
        );

        expect(
          dataSource.watchParty(_partyCode),
          emitsError(isA<ServerException>()),
        );
      },
    );

    test('emits ServerException for generic errors in stream', () async {
      when(
        () => mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.error(Exception('unknown error')));

      expect(
        dataSource.watchParty(_partyCode),
        emitsError(isA<ServerException>()),
      );
    });

    test('re-throws ServerException that originates in stream', () async {
      const originalException = ServerException(message: 'custom error');

      when(
        () => mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.error(originalException));

      expect(
        dataSource.watchParty(_partyCode),
        emitsError(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            equals('custom error'),
          ),
        ),
      );
    });
  });
}
