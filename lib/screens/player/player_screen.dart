import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../config/routes_manager.dart';
import '../../features/recording/presentation/bloc/recording_bloc.dart';
import '../../features/summarization/presentation/bloc/summarization_bloc.dart';
import 'widgets/audio_waveform_player.dart';

class PlayerScreen extends StatefulWidget {
  final String recordingId;

  const PlayerScreen({super.key, required this.recordingId});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;

  int _selectedTabIndex = 0; // 0 for Note, 1 for Transcript

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
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

  void _seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void _changeSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
      _audioPlayer.setSpeed(_playbackSpeed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<RecordingBloc, RecordingState>(
          builder: (context, refState) {
            if (refState.status == RecordingStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }

            if (refState.status == RecordingStatus.success) {
              final recording = refState.recordings.firstWhere(
                (r) => r.id == widget.recordingId,
                orElse: () => throw Exception('Recording not found'),
              );

              final topPadding = MediaQuery.of(context).padding.top;
              final bottomPadding = MediaQuery.of(context).padding.bottom;

              return Column(
                children: [
                  // Immersive Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.arrow_back, size: 20, color: Colors.black87),
                          ),
                        ),
                        const Text(
                          'Note Detail',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, Routes.chat, arguments: widget.recordingId),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.more_horiz, size: 20, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            // Title section
                            Text(
                              recording.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Created on ${recording.createdAt.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                            const SizedBox(height: 24),

                            // Player Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                children: [
                                  AudioWaveformPlayer(
                                    position: _position,
                                    duration: _duration,
                                    seed: widget.recordingId,
                                    onSeek: _seek,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_position),
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        _formatDuration(_duration),
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        onPressed: () => _seek(_position - const Duration(seconds: 10)),
                                        icon: const Icon(Icons.replay_10, size: 30),
                                      ),
                                      GestureDetector(
                                        onTap: _togglePlay,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            _isPlaying ? Icons.pause : Icons.play_arrow,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _seek(_position + const Duration(seconds: 10)),
                                        icon: const Icon(Icons.forward_10, size: 30),
                                      ),
                                      GestureDetector(
                                        onTap: _changeSpeed,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Text(
                                            '${_playbackSpeed.toStringAsFixed(1)}x',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Tab Switcher
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  _buildTabButton(0, '📝 Note'),
                                  _buildTabButton(1, '🎙️ Transcript'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Content
                            _selectedTabIndex == 0
                                ? _buildNoteContent(recording)
                                : _buildTranscriptContent(recording),

                            SizedBox(height: bottomPadding + 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: _buildNoteToolsButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteContent(dynamic recording) {
    return BlocBuilder<SummarizationBloc, SummarizationState>(
      builder: (context, sumState) {
        if (recording.summaryText != null && recording.summaryText.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview & Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                recording.summaryText,
                style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              const Text(
                'Key Concepts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Mocked key concepts for visual
              _buildConceptItem('Recording Topic', 'This is a discussion about the mobile app design and the Note AI features.'),
              _buildConceptItem('Immersive UI', 'The focus is on borderless, edge-to-edge layouts that offer a premium user experience.'),
            ],
          );
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No summary yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Generate an AI summary to see the key insights from this recording.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SummarizationBloc>().add(
                          SummarizeTextRequested(
                            recordingId: recording.id,
                            text: recording.transcriptionText ?? '',
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Generate AI Summary'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConceptItem(String term, String definition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(term, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(definition, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildTranscriptContent(dynamic recording) {
    if (recording.transcriptionText == null || recording.transcriptionText.isEmpty) {
      return const Center(child: Text('No transcript available.'));
    }
    return SelectableText(
      recording.transcriptionText,
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildNoteToolsButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () {}, // Add note tools logic
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: const Text('Note Tools'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
