// Package imports:
import 'package:equatable/equatable.dart';

// Core imports:
import '/core/constants/error_codes.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  const Failure({required this.message, required this.code});

  final String message;
  final String code;

  @override
  List<Object?> get props => [message, code];
}

class StorageFailure extends Failure {
  const StorageFailure({
    required super.message,
    super.code = StorageErrorCodes.base,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code = AuthErrorCodes.base});
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code = ServerErrorCodes.base,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code = CommonErrorCodes.unknown,
  });
}
