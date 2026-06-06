import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pin_point/core/errors/exceptions.dart';
import 'package:pin_point/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pin_point/features/auth/data/models/user_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth firebaseAuth;
  late MockGoogleSignIn googleSignIn;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    firebaseAuth = MockFirebaseAuth();
    googleSignIn = MockGoogleSignIn();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: firebaseAuth,
      googleSignIn: googleSignIn,
    );
  });

  group('signInAnonymously', () {
    test('returns UserModel when sign in succeeds', () async {
      final user = MockUser();
      final credential = MockUserCredential();

      when(() => credential.user).thenReturn(user);

      when(() => user.uid).thenReturn('123');
      when(() => user.email).thenReturn(null);
      when(() => user.displayName).thenReturn(null);
      when(() => user.photoURL).thenReturn(null);
      when(() => user.isAnonymous).thenReturn(true);

      when(
        () => firebaseAuth.signInAnonymously(),
      ).thenAnswer((_) async => credential);

      final result = await dataSource.signInAnonymously();

      expect(result, isA<UserModel>());
      expect(result.uid, '123');
      expect(result.isAnonymous, true);

      verify(() => firebaseAuth.signInAnonymously()).called(1);
    });

    test('throws AuthException when user is null', () async {
      final credential = MockUserCredential();

      when(() => credential.user).thenReturn(null);

      when(
        () => firebaseAuth.signInAnonymously(),
      ).thenAnswer((_) async => credential);

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(isA<AuthException>()),
      );
    });

    test('converts FirebaseAuthException to AuthException', () async {
      when(() => firebaseAuth.signInAnonymously()).thenThrow(
        FirebaseAuthException(code: 'auth-error', message: 'Firebase failed'),
      );

      expect(
        () => dataSource.signInAnonymously(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Firebase failed',
          ),
        ),
      );
    });
  });

  group('signOut', () {
    test('calls firebase signOut successfully', () async {
      when(() => firebaseAuth.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(() => firebaseAuth.signOut()).called(1);
    });

    test('throws AuthException when firebase throws', () async {
      when(() => firebaseAuth.signOut()).thenThrow(
        FirebaseAuthException(
          code: 'sign-out-error',
          message: 'Sign out failed',
        ),
      );

      expect(
        () => dataSource.signOut(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Sign out failed',
          ),
        ),
      );
    });
  });

  group('watchAuthState', () {
    test('emits UserModel when firebase emits user', () {
      final user = MockUser();

      when(() => user.uid).thenReturn('123');
      when(() => user.email).thenReturn('test@test.com');
      when(() => user.displayName).thenReturn('Mohamed');
      when(() => user.photoURL).thenReturn(null);
      when(() => user.isAnonymous).thenReturn(false);

      when(
        () => firebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(user));

      expect(
        dataSource.watchAuthState(),
        emits(
          isA<UserModel>()
              .having((e) => e.uid, 'uid', '123')
              .having((e) => e.email, 'email', 'test@test.com'),
        ),
      );
    });

    test('emits null when firebase emits null', () {
      when(
        () => firebaseAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));

      expect(dataSource.watchAuthState(), emits(null));
    });
  });
}
