// Package imports:
import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  const Failure({required this.message, required this.code});

  final String message;
  final String code;

  @override
  List<Object?> get props => [message, code];
}
