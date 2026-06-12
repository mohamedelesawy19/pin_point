// Package imports:
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Core imports:
import 'package:pin_point/core/errors/failures.dart';

// Feature imports:
import 'package:pin_point/features/party/data/datasources/party_remote_datasource.dart';
import 'package:pin_point/features/party/data/models/party_model.dart';
import 'package:pin_point/features/party/data/models/party_settings_model.dart';
import 'package:pin_point/features/party/data/models/player_model.dart';
import 'package:pin_point/features/party/data/repositories/party_repository_impl.dart';
import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';

class MockPartyRemoteDataSource extends Mock implements PartyRemoteDataSource {}

void main() {
  late MockPartyRemoteDataSource dataSource;
  late PartyRepositoryImpl repository;

  const hostPlayer = PlayerEntity(
    uid: '1',
    displayName: 'Mohamed',
    photoUrl: 'photo.jpg',
    isAnonymous: false,
    score: 0,
  );

  const player = PlayerEntity(
    uid: '2',
    displayName: 'Ahmed',
    photoUrl: 'photo2.jpg',
    isAnonymous: false,
    score: 0,
  );

  const settings = PartySettings(roundDurationSeconds: 30, totalRounds: 5);

  final partyEntity = PartyEntity(
    partyCode: 'ABC123',
    hostId: '1',
    hostName: 'Mohamed',
    partyName: 'Party',
    status: PartyStatus.waiting,
    players: const [hostPlayer],
    settings: settings,
    currentRound: 0,
    createdAt: DateTime(2026),
  );

  final partyModel = PartyModel.fromEntity(partyEntity);

  setUpAll(() {
    registerFallbackValue(
      const PlayerModel(
        uid: '',
        displayName: '',
        photoUrl: '',
        isAnonymous: false,
        score: 0,
      ),
    );
    registerFallbackValue(
      const PartySettingsModel(roundDurationSeconds: 0, totalRounds: 0),
    );
  });

  setUp(() {
    dataSource = MockPartyRemoteDataSource();
    repository = PartyRepositoryImpl(dataSource: dataSource);
  });

  group('createParty', () {
    test('returns Right(code) when datasource succeeds', () async {
      when(
        () => dataSource.createParty(
          hostPlayer: any(named: 'hostPlayer'),
          partyName: any(named: 'partyName'),
          settings: any(named: 'settings'),
        ),
      ).thenAnswer((_) async => 'ABC123');

      final result = await repository.createParty(
        hostPlayer: hostPlayer,
        partyName: 'Party',
        settings: settings,
      );

      expect(result, const Right('ABC123'));

      verify(
        () => dataSource.createParty(
          hostPlayer: PlayerModel.fromEntity(hostPlayer),
          partyName: 'Party',
          settings: PartySettingsModel.fromEntity(settings),
        ),
      ).called(1);
    });

    test('returns Left(ServerFailure) when datasource throws', () async {
      when(
        () => dataSource.createParty(
          hostPlayer: any(named: 'hostPlayer'),
          partyName: any(named: 'partyName'),
          settings: any(named: 'settings'),
        ),
      ).thenThrow(Exception('error'));

      final result = await repository.createParty(
        hostPlayer: hostPlayer,
        partyName: 'Party',
        settings: settings,
      );

      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<ServerFailure>());
        expect((failure as ServerFailure).message, contains('error'));
      }, (_) => fail('Expected Left'));
    });
  });

  group('joinParty', () {
    test('returns Right(code)', () async {
      when(
        () => dataSource.joinParty(
          partyCode: any(named: 'partyCode'),
          player: any(named: 'player'),
        ),
      ).thenAnswer((_) async => 'ABC123');

      final result = await repository.joinParty(
        partyCode: 'ABC123',
        player: player,
      );

      expect(result, const Right('ABC123'));

      verify(
        () => dataSource.joinParty(
          partyCode: 'ABC123',
          player: PlayerModel.fromEntity(player),
        ),
      ).called(1);
    });

    test('returns Left(ServerFailure)', () async {
      when(
        () => dataSource.joinParty(
          partyCode: any(named: 'partyCode'),
          player: any(named: 'player'),
        ),
      ).thenThrow(Exception('join failed'));

      final result = await repository.joinParty(
        partyCode: 'ABC123',
        player: player,
      );

      expect(result.isLeft(), true);
    });
  });

  group('startGame', () {
    test('returns Right(unit)', () async {
      when(
        () => dataSource.startGame(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.startGame(
        partyCode: 'ABC123',
        hostId: '1',
      );

      expect(result, const Right(unit));

      verify(
        () => dataSource.startGame(partyCode: 'ABC123', hostId: '1'),
      ).called(1);
    });

    test('returns Left(ServerFailure)', () async {
      when(
        () => dataSource.startGame(
          partyCode: any(named: 'partyCode'),
          hostId: any(named: 'hostId'),
        ),
      ).thenThrow(Exception());

      final result = await repository.startGame(
        partyCode: 'ABC123',
        hostId: '1',
      );

      expect(result.isLeft(), true);
    });
  });

  group('kickPlayer', () {
    test('returns Right(unit)', () async {
      when(
        () => dataSource.kickPlayer(
          partyCode: any(named: 'partyCode'),
          targetUid: any(named: 'targetUid'),
          hostId: any(named: 'hostId'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.kickPlayer(
        partyCode: 'ABC123',
        targetUid: '2',
        hostId: '1',
      );

      expect(result, const Right(unit));

      verify(
        () => dataSource.kickPlayer(
          partyCode: 'ABC123',
          targetUid: '2',
          hostId: '1',
        ),
      ).called(1);
    });

    test('returns Left(ServerFailure)', () async {
      when(
        () => dataSource.kickPlayer(
          partyCode: any(named: 'partyCode'),
          targetUid: any(named: 'targetUid'),
          hostId: any(named: 'hostId'),
        ),
      ).thenThrow(Exception());

      final result = await repository.kickPlayer(
        partyCode: 'ABC123',
        targetUid: '2',
        hostId: '1',
      );

      expect(result.isLeft(), true);
    });
  });

  group('leaveParty', () {
    test('returns Right(unit)', () async {
      when(
        () => dataSource.leaveParty(
          partyCode: any(named: 'partyCode'),
          uid: any(named: 'uid'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.leaveParty(partyCode: 'ABC123', uid: '2');

      expect(result, const Right(unit));

      verify(
        () => dataSource.leaveParty(partyCode: 'ABC123', uid: '2'),
      ).called(1);
    });

    test('returns Left(ServerFailure)', () async {
      when(
        () => dataSource.leaveParty(
          partyCode: any(named: 'partyCode'),
          uid: any(named: 'uid'),
        ),
      ).thenThrow(Exception());

      final result = await repository.leaveParty(partyCode: 'ABC123', uid: '2');

      expect(result.isLeft(), true);
    });
  });

  group('watchParty', () {
    test('maps PartyModel to PartyEntity', () async {
      when(
        () => dataSource.watchParty('ABC123'),
      ).thenAnswer((_) => Stream.value(partyModel));

      final result = repository.watchParty('ABC123');

      expect(result, emits(equals(partyEntity)));

      verify(() => dataSource.watchParty('ABC123')).called(1);
    });
  });
}
