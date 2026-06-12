// Package imports:
import 'package:equatable/equatable.dart';

/// Abstract base class for all exceptions in the system.
abstract class BaseException extends Equatable implements Exception {
  const BaseException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

// ============================================================================
// Storage Exceptions
// ============================================================================

class StorageException extends BaseException {
  const StorageException({required super.message, super.code});
}

// ============================================================================
// Authentication Exceptions
// ============================================================================

class AuthException extends BaseException {
  const AuthException({required super.message, super.code});
}

// ============================================================================
// Server Exceptions
// ============================================================================

class ServerException extends BaseException {
  const ServerException({required super.message, super.code});
}
