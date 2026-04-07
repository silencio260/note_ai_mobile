import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failure.dart';

/// Base class for all use cases.
///
/// [Output] — the success type returned (e.g. `List<Recording>`)
/// [Input] — the parameters type (use [NoParams] if none required)
abstract class BaseUseCase<Output, Input> {
  Future<Either<Failure, Output>> call(Input params);
}

/// Use when a use case requires no input parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
