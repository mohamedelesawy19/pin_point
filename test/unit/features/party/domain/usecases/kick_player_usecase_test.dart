import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/kick_player_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late KickPlayerUseCase useCase;
  late MockPartyRepository repository;

  setUp(() {
    repository = MockPartyRepository();
    useCase = KickPlayerUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    const params = KickPlayerParams(
      partyCode: 'ABC123',
      targetUid: 'targetUid',
      hostId: 'hostId',
    );

    when(
      () => repository.kickPlayer(
        partyCode: any(named: 'partyCode'),
        targetUid: any(named: 'targetUid'),
        hostId: any(named: 'hostId'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await useCase(params);

    // Assert
    expect(result, const Right<Failure, Unit>(unit));

    verify(
      () => repository.kickPlayer(
        partyCode: params.partyCode,
        targetUid: params.targetUid,
        hostId: params.hostId,
      ),
    ).called(1);

    verifyNoMoreInteractions(repository);
  });
}
