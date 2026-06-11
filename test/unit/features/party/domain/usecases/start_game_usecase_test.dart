import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/start_game_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late StartGameUseCase useCase;
  late MockPartyRepository repository;

  setUp(() {
    repository = MockPartyRepository();
    useCase = StartGameUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    const params = StartGameParams(partyCode: 'ABC123', hostId: 'hostId');

    when(
      () => repository.startGame(
        partyCode: any(named: 'partyCode'),
        hostId: any(named: 'hostId'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await useCase(params);

    // Assert
    expect(result, const Right<Failure, Unit>(unit));

    verify(
      () => repository.startGame(
        partyCode: params.partyCode,
        hostId: params.hostId,
      ),
    ).called(1);

    verifyNoMoreInteractions(repository);
  });
}
