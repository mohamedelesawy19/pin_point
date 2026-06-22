import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';

import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/entities/party_settings.dart';
import 'package:pin_point/features/party/domain/entities/player_entity.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/restore_party_session_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

class FakeSingleParam extends Fake implements SingleParam<String> {}

void main() {
  late RestorePartySessionUseCase useCase;
  late MockPartyRepository repo;

  const userId = 'user_1';
  const code = 'party_123';

  setUpAll(() {
    registerFallbackValue(FakeSingleParam());
  });

  setUp(() {
    repo = MockPartyRepository();
    useCase = RestorePartySessionUseCase(partyRepository: repo);
  });

  test('should return Left when getActivePartyCode fails', () async {
    // arrange
    const failure = UnknownFailure(message: 'error');

    when(
      () => repo.getActivePartyCode(),
    ).thenAnswer((_) async => const Left(failure));

    // act
    final result = await useCase(const SingleParam(userId));

    // assert
    expect(result, const Left(failure));
    verify(() => repo.getActivePartyCode()).called(1);
    verifyNever(() => repo.getParty(any()));
  });

  test('should return null when no stored code exists', () async {
    // arrange
    when(
      () => repo.getActivePartyCode(),
    ).thenAnswer((_) async => const Right(null));

    // act
    final result = await useCase(const SingleParam(userId));

    // assert
    expect(result, const Right(null));
    verify(() => repo.getActivePartyCode()).called(1);
    verifyNever(() => repo.getParty(any()));
  });

  test('should clear session and return null when party is invalid', () async {
    // arrange
    final party = PartyEntity(
      partyName: 'Test Party',
      partyCode: code,
      hostId: 'user_2',
      hostName: 'Host User',
      currentRound: 0,
      settings: const PartySettings(roundDurationSeconds: 60, totalRounds: 5),
      status: PartyStatus.finished,
      players: const [],
      kickedPlayers: const {},
      createdAt: DateTime.now(),
    );

    when(
      () => repo.getActivePartyCode(),
    ).thenAnswer((_) async => const Right(code));

    when(() => repo.getParty(code)).thenAnswer((_) async => Right(party));

    when(
      () => repo.clearActivePartyCode(),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await useCase(const SingleParam(userId));

    // assert
    expect(result, const Right(null));

    verify(() => repo.clearActivePartyCode()).called(1);
  });

  test('should return code when party is valid', () async {
    // arrange
    final party = PartyEntity(
      partyName: 'Test Party',
      partyCode: code,
      hostId: 'user_2',
      hostName: 'Host User',
      currentRound: 0,
      settings: const PartySettings(roundDurationSeconds: 60, totalRounds: 5),
      status: PartyStatus.waiting,
      players: const [
        PlayerEntity(
          uid: userId,
          displayName: 'Test User',
          isAnonymous: false,
          score: 0,
        ),
      ],
      kickedPlayers: const {},
      createdAt: DateTime.now(),
    );

    when(
      () => repo.getActivePartyCode(),
    ).thenAnswer((_) async => const Right(code));

    when(() => repo.getParty(code)).thenAnswer((_) async => Right(party));

    // act
    final result = await useCase(const SingleParam(userId));

    // assert
    expect(result, const Right(code));

    verifyNever(() => repo.clearActivePartyCode());
  });
}
