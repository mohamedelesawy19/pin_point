import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';

import 'package:pin_point/features/party/domain/entities/party_entity.dart';
import 'package:pin_point/features/party/domain/repositories/party_repository.dart';
import 'package:pin_point/features/party/domain/usecases/create_party_usecase.dart';

class MockPartyRepository extends Mock implements PartyRepository {}

void main() {
  late CreatePartyUseCase useCase;
  late MockPartyRepository repository;

  setUpAll(() {
    registerFallbackValue(
      const PartySettings(roundDurationSeconds: 30, totalRounds: 4),
    );
  });

  setUp(() {
    repository = MockPartyRepository();
    useCase = CreatePartyUseCase(repository);
  });

  test('should delegate call to repository', () async {
    // Arrange
    const params = CreatePartyParams(
      hostId: 'hostId',
      hostName: 'hostName',
      partyName: 'partyName',
      settings: PartySettings(roundDurationSeconds: 30, totalRounds: 4),
    );

    when(
      () => repository.createParty(
        hostId: any(named: 'hostId'),
        hostName: any(named: 'hostName'),
        partyName: any(named: 'partyName'),
        settings: any(named: 'settings'),
      ),
    ).thenAnswer((_) async => const Right('partyId'));

    // Act
    final result = await useCase(params);

    // Assert
    expect(result, const Right<Failure, String>('partyId'));

    verify(
      () => repository.createParty(
        hostId: params.hostId,
        hostName: params.hostName,
        partyName: params.partyName,
        settings: params.settings,
      ),
    ).called(1);

    verifyNoMoreInteractions(repository);
  });
}
