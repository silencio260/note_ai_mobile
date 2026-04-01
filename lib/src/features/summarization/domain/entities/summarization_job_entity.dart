import 'package:equatable/equatable.dart';

enum SummarizationStatus { pending, processing, completed, failed }

class SummarizationJobEntity extends Equatable {
  final String id; // usually corresponds to recordingId
  final String textToSummarize;
  final SummarizationStatus status;
  final String? resultSummary;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SummarizationJobEntity({
    required this.id,
    required this.textToSummarize,
    this.status = SummarizationStatus.pending,
    this.resultSummary,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  SummarizationJobEntity copyWith({
    SummarizationStatus? status,
    String? resultSummary,
    String? errorMessage,
    DateTime? updatedAt,
  }) {
    return SummarizationJobEntity(
      id: id,
      textToSummarize: textToSummarize,
      status: status ?? this.status,
      resultSummary: resultSummary ?? this.resultSummary,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        textToSummarize,
        status,
        resultSummary,
        errorMessage,
        createdAt,
        updatedAt,
      ];
}
