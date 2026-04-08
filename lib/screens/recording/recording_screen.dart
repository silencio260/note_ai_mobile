import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/recording/presentation/bloc/audio_record_bloc.dart';
import '../../features/recording/presentation/bloc/audio_record_event.dart';
import '../../features/recording/presentation/bloc/audio_record_state.dart';
import '../../features/recording/presentation/bloc/recording_bloc.dart';
import '../../features/recording/domain/entities/recording_entity.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import 'widgets/live_waveform.dart';
import 'widgets/language_selection_sheet.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedLanguage = 'en';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en': return 'English';
      case 'es': return 'Spanish';
      case 'fr': return 'French';
      case 'de': return 'German';
      case 'it': return 'Italian';
      case 'pt': return 'Portuguese';
      case 'zh': return 'Chinese';
      case 'ja': return 'Japanese';
      case 'ko': return 'Korean';
      default: return 'English';
    }
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
        extendBody: true,
        body: BlocConsumer<AudioRecordBloc, AudioRecordState>(
          listener: (context, state) {
            if (state.status == AudioRecordStatus.failure && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state.status == AudioRecordStatus.success && state.savedFilePath != null) {
              final authState = context.read<AuthBloc>().state;
              if (authState.user != null) {
                final newRecording = RecordingEntity(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: state.recordingTitle ?? 'Untitled',
                  filePath: state.savedFilePath!,
                  durationSeconds: state.duration.inSeconds,
                  createdAt: DateTime.now(),
                  ownerId: authState.user!.uid,
                );

                context.read<RecordingBloc>().add(SaveRecordingRequested(newRecording));

                final navigator = Navigator.of(context);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted && navigator.canPop()) {
                    navigator.pop();
                  }
                });
              }
            }
          },
          builder: (context, state) {
            final isRecording = state.status == AudioRecordStatus.recording;
            final topPadding = MediaQuery.of(context).padding.top;
            final bottomPadding = MediaQuery.of(context).padding.bottom;

            return Column(
              children: [
                // Custom Header
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
                          child: const Icon(Icons.close, size: 20, color: Colors.black87),
                        ),
                      ),
                      Text(
                        isRecording ? 'Recording...' : 'New Note',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance the close button
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isRecording) ...[
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) => LanguageSelectionSheet(
                                  selectedLanguage: _selectedLanguage,
                                  onLanguageSelected: (lang) {
                                    setState(() => _selectedLanguage = lang);
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.language, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getLanguageName(_selectedLanguage),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, size: 16),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],

                        // Timer
                        Text(
                          _formatDuration(state.duration),
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w200,
                            letterSpacing: -2,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Reactive Waveform
                        LiveWaveform(
                          amplitude: state.amplitude,
                          isRecording: isRecording,
                        ),
                        
                        const SizedBox(height: 60),
                        
                        if (!isRecording) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: TextField(
                              controller: _titleController,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'Name your note...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Audio is being captured and transcribed',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Footer Controls
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPadding + 24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _handleMainAction(context, state),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isRecording ? Colors.red : Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isRecording ? Colors.red : Colors.black)
                                    .withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isRecording 
                            ? 'Tap to stop recording'
                            : 'Tap to start recording',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleMainAction(BuildContext context, AudioRecordState state) {
    if (state.status == AudioRecordStatus.recording) {
      context.read<AudioRecordBloc>().add(const StopAudioRecording());
    } else {
      context.read<AudioRecordBloc>().add(
            StartAudioRecording(_titleController.text.trim()),
          );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
