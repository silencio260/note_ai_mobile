import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';

abstract class TranscriptionRepository {
  /// Sends the audio file to the backend to be transcribed.
  /// Returns the transcribed text (markdown formatted if applicable).
  Future<Either<Failure, String>> transcribeAudio({
    required String filePath,
    required String languageCode,
  });
}
