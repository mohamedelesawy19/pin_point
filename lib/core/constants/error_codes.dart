abstract final class CommonErrorCodes {
  static const unknown = 'UNKNOWN_ERROR';
}

abstract final class StorageErrorCodes {
  static const base = 'STORAGE_ERROR';
  static const write = 'STORAGE_WRITE';
  static const read = 'STORAGE_READ';
  static const delete = 'STORAGE_DELETE';
  static const clear = 'STORAGE_CLEAR';
  static const contains = 'STORAGE_CONTAINS';
  static const getAll = 'STORAGE_GET_ALL';
}

abstract final class AuthErrorCodes {
  static const base = 'AUTH_ERROR';
  static const signInWithGoogle = 'AUTH_SIGN_IN_WITH_GOOGLE';
  static const signInAnonymously = 'AUTH_SIGN_IN_ANONYMOUSLY';
  static const signOut = 'AUTH_SIGN_OUT';
  static const watchAuthState = 'AUTH_WATCH_AUTH_STATE';
}
