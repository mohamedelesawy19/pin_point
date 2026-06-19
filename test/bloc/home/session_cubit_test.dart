import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/core/usecases/usecase.dart';
import 'package:pin_point/features/home/presentation/bloc/session_cubit.dart';
import 'package:pin_point/features/party/domain/usecases/restore_party_session_usecase.dart';

class MockRestorePartySessionUseCase extends Mock
    implements RestorePartySessionUseCase {}

class FakeSingleParam extends Fake implements SingleParam<String> {}

void main() {
  late SessionCubit cubit;
  late MockRestorePartySessionUseCase restorePartySession;

  const uid = 'user_1';
  const partyCode = 'ABC123';

  setUpAll(() {
    registerFallbackValue(const SingleParam(''));
  });

  setUp(() {
    restorePartySession = MockRestorePartySessionUseCase();

    cubit = SessionCubit(restorePartySession: restorePartySession);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('restorePartySession', () {
    blocTest<SessionCubit, SessionState>(
      'emits [SessionChecking, SessionRestored] when session exists',
      build: () {
        when(
          () => restorePartySession(any()),
        ).thenAnswer((_) async => const Right(partyCode));

        return cubit;
      },
      act: (cubit) => cubit.restorePartySession(uid),
      expect: () => const [
        SessionChecking(),
        SessionRestored(partyCode: partyCode),
      ],
      verify: (_) {
        verify(() => restorePartySession(const SingleParam(uid))).called(1);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'emits [SessionChecking, SessionClean] when no session exists',
      build: () {
        when(
          () => restorePartySession(any()),
        ).thenAnswer((_) async => const Right(null));

        return cubit;
      },
      act: (cubit) => cubit.restorePartySession(uid),
      expect: () => const [SessionChecking(), SessionClean()],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [SessionChecking, SessionClean] when use case returns failure',
      build: () {
        when(() => restorePartySession(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );

        return cubit;
      },
      act: (cubit) => cubit.restorePartySession(uid),
      expect: () => const [SessionChecking(), SessionClean()],
    );
  });

  group('consumeSession', () {
    blocTest<SessionCubit, SessionState>(
      'emits SessionClean',
      build: () => cubit,
      seed: () => const SessionRestored(partyCode: partyCode),
      act: (cubit) => cubit.consumeSession(),
      expect: () => const [SessionClean()],
    );
  });

  group('reset', () {
    blocTest<SessionCubit, SessionState>(
      'emits SessionInitial',
      build: () => cubit,
      seed: () => const SessionRestored(partyCode: partyCode),
      act: (cubit) => cubit.reset(),
      expect: () => const [SessionInitial()],
    );
  });
}
