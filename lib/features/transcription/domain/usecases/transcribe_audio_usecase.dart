import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/transcription_repository.dart';

class TranscribeAudioParams {
  final String filePath;
  final String languageCode;

  const TranscribeAudioParams({
    required this.filePath,
    required this.languageCode,
  });
}

class TranscribeAudioUseCase extends BaseUseCase<String, TranscribeAudioParams> {
  final TranscriptionRepository _repo;

  TranscribeAudioUseCase(this._repo);

  @override
  Future<Either<Failure, String>> call(TranscribeAudioParams params) {
    return _repo.transcribeAudio(
      filePath: params.filePath,
      languageCode: params.languageCode,
    );
  }
}
