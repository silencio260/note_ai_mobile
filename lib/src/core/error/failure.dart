import 'package:equatable/equatable.dart';

/// Base failure class for all domain-layer errors
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

// ─── Network ─────────────────────────────────────────────────────────────────

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class NoInternetConnectionFailure extends Failure {
  const NoInternetConnectionFailure()
      : super('No internet connection. Please check your network and try again.');
}

// ─── Auth ─────────────────────────────────────────────────────────────────────

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// ─── Storage ──────────────────────────────────────────────────────────────────

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

// ─── Domain ───────────────────────────────────────────────────────────────────

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ─── Recording ────────────────────────────────────────────────────────────────

class RecordingFailure extends Failure {
  const RecordingFailure(super.message);
}

// ─── AI ───────────────────────────────────────────────────────────────────────

class AITranscriptionFailure extends Failure {
  const AITranscriptionFailure(super.message);
}

class AISummaryFailure extends Failure {
  const AISummaryFailure(super.message);
}

class AIChatFailure extends Failure {
  const AIChatFailure(super.message);
}
