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
  static const getCurrentUser = 'AUTH_GET_CURRENT_USER';
  static const watchAuthState = 'AUTH_WATCH_AUTH_STATE';
}

abstract final class UserErrorCodes {
  static const base = 'USER_ERROR';
  static const ensureUserProfile = 'USER_ENSURE_USER_PROFILE';
  static const getUserProfile = 'USER_GET_USER_PROFILE';
  static const updateDisplayName = 'USER_UPDATE_DISPLAY_NAME';
  static const updatePhotoUrl = 'USER_UPDATE_PHOTO_URL';
}

abstract final class ServerErrorCodes {
  static const base = 'SERVER_ERROR';
}
