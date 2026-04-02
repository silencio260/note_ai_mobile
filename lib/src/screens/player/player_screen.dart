import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../config/routes_manager.dart';
import '../../features/recording/presentation/bloc/recording_bloc.dart';
import '../../features/summarization/domain/entities/summarization_job_entity.dart';
import '../../features/summarization/presentation/bloc/summarization_bloc.dart';

class PlayerScreen extends StatefulWidget {
  final String recordingId;

  const PlayerScreen({super.key, required this.recordingId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    // Delay initialization until the first build to read the recording
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<RecordingBloc>().state;
      if (state.status == RecordingStatus.success) {
        try {
          final recording = state.recordings.firstWhere((r) => r.id == widget.recordingId);
          if (File(recording.filePath).existsSync()) {
            await _audioPlayer.setFilePath(recording.filePath);
            
            _positionSub = _audioPlayer.positionStream.listen((pos) {
              if (mounted) setState(() => _position = pos);
            });
            _durationSub = _audioPlayer.durationStream.listen((dur) {
              if (mounted) setState(() => _duration = dur ?? Duration.zero);
            });
            _playerStateSub = _audioPlayer.playerStateStream.listen((state) {
              if (mounted) {
                setState(() => _isPlaying = state.playing);
                if (state.processingState == ProcessingState.completed) {
                  _audioPlayer.seek(Duration.zero);
                  _audioPlayer.pause();
                }
              }
            });
          }
        } catch (e) {
          debugPrint('Error init audio: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.pushNamed(context, Routes.chat, arguments: widget.recordingId);
            },
          )
        ],
      ),
      body: BlocBuilder<RecordingBloc, RecordingState>(
        builder: (context, refState) {
          if (refState.status == RecordingStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (refState.status == RecordingStatus.success && refState.recordings.isNotEmpty) {
            final recording = refState.recordings.firstWhere(
              (r) => r.id == widget.recordingId,
              orElse: () => throw Exception('Recording not found'),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recording.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created on ${recording.createdAt.toLocal().toString().split(' ')[0]}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Audio Player Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: _togglePlay,
                              icon: Icon(
                                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                size: 48,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  Slider(
                                    value: _duration.inMilliseconds > 0
                                        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
                                        : 0.0,
                                    onChanged: (val) {
                                      final newPos = Duration(milliseconds: (val * _duration.inMilliseconds).round());
                                      _audioPlayer.seek(newPos);
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(_position), style: theme.textTheme.labelSmall),
                                      Text(_formatDuration(_duration), style: theme.textTheme.labelSmall),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Summarization Status & Button
                  BlocBuilder<SummarizationBloc, SummarizationState>(
                    builder: (context, sumState) {
                      final job = sumState.activeJobs.firstWhere(
                        (j) => j.id == recording.id,
                        orElse: () => SummarizationJobEntity(
                          id: '',
                          textToSummarize: '',
                          status: SummarizationStatus.pending,
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ), // Fake job simply to check ID
                      );

                      // If we actually have summary text
                      if (recording.summaryText != null && recording.summaryText!.isNotEmpty) {
                        return _buildSummaryCard(context, recording.summaryText!);
                      }

                      // If no summary text, check if we are in progress
                      if (job.id == recording.id &&
                          (job.status == SummarizationStatus.processing || job.status == SummarizationStatus.pending)) {
                         return Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: Colors.amber.withValues(alpha: 0.1),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                           ),
                           child: const Row(
                             children: [
                               SizedBox(
                                 width: 20, 
                                 height: 20, 
                                 child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber)
                               ),
                               SizedBox(width: 16),
                               Expanded(child: Text('Summarization is running in background...')),
                             ],
                           )
                         );
                      }

                      // Else show button to trigger summary
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: () {
                            context.read<SummarizationBloc>().add(
                              SummarizeTextRequested(
                                recordingId: recording.id,
                                text: recording.transcriptionText ?? '',
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate AI Summary'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Transcription Section
                  Text(
                    'Transcription',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (recording.transcriptionText == null || recording.transcriptionText!.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'No transcription available. Please process the recording.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    SelectableText(
                      recording.transcriptionText!,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'AI Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SelectableText(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
