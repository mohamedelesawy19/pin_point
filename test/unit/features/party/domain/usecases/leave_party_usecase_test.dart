import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/leave_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late LeavePartyUseCase useCase;
  late MockPartyRepository repository;

  setUp(() {
    repository = MockPartyRepository();
    useCase = LeavePartyUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    const params = LeavePartyParams(partyCode: 'ABC123', playerId: 'playerId');

    when(
      () => repository.leaveParty(
        partyCode: any(named: 'partyCode'),
        uid: any(named: 'uid'),
      ),
    ).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await useCase(params);

    // Assert
    expect(result, const Right<Failure, Unit>(unit));

    verify(
      () => repository.leaveParty(
        partyCode: params.partyCode,
        uid: params.playerId,
      ),
    ).called(1);

    verifyNoMoreInteractions(repository);
  });
}
