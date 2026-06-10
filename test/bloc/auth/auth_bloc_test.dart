import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/failures.dart';
import 'package:pin_point/features/auth/domain/entities/user_entity.dart';
import 'package:pin_point/features/auth/domain/usecases/sign_in_anonymously_usecase.dart';
import 'package:pin_point/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:pin_point/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:pin_point/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:pin_point/features/auth/presentation/bloc/auth_bloc.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignInAnonymouslyUseCase extends Mock
    implements SignInAnonymouslyUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

class MockWatchAuthStateUseCase extends Mock implements WatchAuthStateUseCase {}

class _FakeFailure extends Failure {
  const _FakeFailure(String message)
    : super(message: message, code: 'fake_failure');
}

// ── Shared Test Fixtures ─────────────────────────────────────────────────────

const _kErrorMessage = 'Something went wrong';
const _tFailure = _FakeFailure(_kErrorMessage);

const _tStreamUser = UserEntity(
  uid: 'stream-uid',
  email: 'stream@example.com',
  displayName: 'Stream User',
  isAnonymous: false,
);

const _tSignedInUser = UserEntity(
  uid: 'signed-in-uid',
  email: 'signed-in@example.com',
  displayName: 'Signed In User',
  isAnonymous: false,
);

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockSignInWithGoogleUseCase mockSignInWithGoogle;
  late MockSignInAnonymouslyUseCase mockSignInAnonymously;
  late MockSignOutUseCase mockSignOut;
  late MockWatchAuthStateUseCase mockWatchAuthState;

  AuthBloc buildBloc() => AuthBloc(
    signInWithGoogle: mockSignInWithGoogle,
    signInAnonymously: mockSignInAnonymously,
    signOut: mockSignOut,
    watchAuthState: mockWatchAuthState,
  );

  setUp(() {
    mockSignInWithGoogle = MockSignInWithGoogleUseCase();
    mockSignInAnonymously = MockSignInAnonymouslyUseCase();
    mockSignOut = MockSignOutUseCase();
    mockWatchAuthState = MockWatchAuthStateUseCase();
  });

  // ── Initial state ──────────────────────────────────────────────────────────

  group('AuthBloc — initial state', () {
    test('is AuthInitial before any event is added', () {
      final bloc = buildBloc();
      expect(bloc.state, const AuthInitial());
      bloc.close();
    });
  });

  group('AuthBloc — SignInWithGoogleEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading] on success '
      '(AuthAuthenticated is driven by the auth-state stream, not here)',
      build: () {
        when(() => mockSignInWithGoogle()).thenAnswer(
          (_) async => const Right<Failure, UserEntity>(_tSignedInUser),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      expect: () => [const AuthLoading()],
      verify: (_) => verify(() => mockSignInWithGoogle()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockSignInWithGoogle(),
        ).thenAnswer((_) async => const Left<Failure, UserEntity>(_tFailure));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: _kErrorMessage),
      ],
      verify: (_) => verify(() => mockSignInWithGoogle()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'does NOT call signInAnonymously or signOut',
      build: () {
        when(() => mockSignInWithGoogle()).thenAnswer(
          (_) async => const Right<Failure, UserEntity>(_tSignedInUser),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInWithGoogleEvent()),
      verify: (_) {
        verifyNever(() => mockSignInAnonymously());
        verifyNever(() => mockSignOut());
      },
    );
  });

  // ── SignInAnonymouslyEvent ─────────────────────────────────────────────────

  group('AuthBloc — SignInAnonymouslyEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading] on success',
      build: () {
        when(() => mockSignInAnonymously()).thenAnswer(
          (_) async => const Right<Failure, UserEntity>(_tSignedInUser),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInAnonymouslyEvent()),
      expect: () => [const AuthLoading()],
      verify: (_) => verify(() => mockSignInAnonymously()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockSignInAnonymously(),
        ).thenAnswer((_) async => const Left<Failure, UserEntity>(_tFailure));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInAnonymouslyEvent()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: _kErrorMessage),
      ],
      verify: (_) => verify(() => mockSignInAnonymously()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'does NOT call signInWithGoogle or signOut',
      build: () {
        when(() => mockSignInAnonymously()).thenAnswer(
          (_) async => const Right<Failure, UserEntity>(_tSignedInUser),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignInAnonymouslyEvent()),
      verify: (_) {
        verifyNever(() => mockSignInWithGoogle());
        verifyNever(() => mockSignOut());
      },
    );
  });

  // ── SignOutEvent ───────────────────────────────────────────────────────────

  group('AuthBloc — SignOutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading] on success',
      build: () {
        when(
          () => mockSignOut(),
        ).thenAnswer((_) async => const Right<Failure, Unit>(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [const AuthLoading()],
      verify: (_) => verify(() => mockSignOut()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockSignOut(),
        ).thenAnswer((_) async => const Left<Failure, Unit>(_tFailure));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      expect: () => [
        const AuthLoading(),
        const AuthError(message: _kErrorMessage),
      ],
      verify: (_) => verify(() => mockSignOut()).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'does NOT call signInWithGoogle or signInAnonymously',
      build: () {
        when(
          () => mockSignOut(),
        ).thenAnswer((_) async => const Right<Failure, Unit>(unit));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SignOutEvent()),
      verify: (_) {
        verifyNever(() => mockSignInWithGoogle());
        verifyNever(() => mockSignInAnonymously());
      },
    );
  });

  // ── AuthStartedEvent ───────────────────────────────────────────────────────
  group('AuthBloc — AuthStartedEvent (auth-state stream)', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when stream emits a non-null user',
      build: () {
        when(
          () => mockWatchAuthState(),
        ).thenAnswer((_) => Stream.value(_tStreamUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStartedEvent()),
      expect: () => [const AuthAuthenticated(user: _tStreamUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when stream emits null',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer((_) => Stream.value(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStartedEvent()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'handles multiple consecutive auth state changes',
      build: () {
        when(() => mockWatchAuthState()).thenAnswer(
          (_) => Stream.fromIterable([_tStreamUser, null, _tStreamUser]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStartedEvent()),
      expect: () => [
        const AuthAuthenticated(user: _tStreamUser),
        const AuthUnauthenticated(),
        const AuthAuthenticated(user: _tStreamUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'calls watchAuthState exactly once',
      build: () {
        when(
          () => mockWatchAuthState(),
        ).thenAnswer((_) => Stream.value(_tStreamUser));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthStartedEvent()),
      verify: (_) => verify(() => mockWatchAuthState()).called(1),
    );
  });

  // ── State equality ─────────────────────────────────────────────────────────

  group('AuthState — equality', () {
    test('AuthInitial instances are equal', () {
      expect(const AuthInitial(), equals(const AuthInitial()));
    });

    test('AuthLoading instances are equal', () {
      expect(const AuthLoading(), equals(const AuthLoading()));
    });

    test('AuthUnauthenticated instances are equal', () {
      expect(const AuthUnauthenticated(), equals(const AuthUnauthenticated()));
    });

    test('AuthError instances with same message are equal', () {
      expect(
        const AuthError(message: 'err'),
        equals(const AuthError(message: 'err')),
      );
    });

    test('AuthError instances with different messages are NOT equal', () {
      expect(
        const AuthError(message: 'err A'),
        isNot(equals(const AuthError(message: 'err B'))),
      );
    });

    test('AuthAuthenticated instances with same user are equal', () {
      expect(
        const AuthAuthenticated(user: _tStreamUser),
        equals(const AuthAuthenticated(user: _tStreamUser)),
      );
    });
  });
}
