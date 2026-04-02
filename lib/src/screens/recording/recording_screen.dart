import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/recording/presentation/bloc/audio_record_bloc.dart';
import '../../features/recording/presentation/bloc/audio_record_event.dart';
import '../../features/recording/presentation/bloc/audio_record_state.dart';
import '../../features/recording/presentation/bloc/recording_bloc.dart';
import '../../features/recording/domain/entities/recording_entity.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AudioRecordBloc, AudioRecordState>(
        listener: (context, state) {
          if (state.status == AudioRecordStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state.status == AudioRecordStatus.success && state.savedFilePath != null) {
            final authState = context.read<AuthBloc>().state;
            if (authState.user != null) {
              // Create the RecordingEntity and save it
              final newRecording = RecordingEntity(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: state.recordingTitle ?? 'Untitled',
                filePath: state.savedFilePath!,
                durationSeconds: state.duration.inSeconds,
                createdAt: DateTime.now(),
                ownerId: authState.user!.uid,
              );

              // Tell RecordingBloc to save it
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

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _getStatusText(state),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Circle Pulse around microphone
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRecording)
                        TweenAnimationBuilder(
                          tween: Tween(begin: 1.0, end: 1.2 + (state.amplitude * 0.5)),
                          duration: const Duration(milliseconds: 100),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.error.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => _handleMainAction(context, state),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecording 
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: (isRecording 
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary).withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  if (isRecording) ...[
                    Text(
                      'Duration: ${_formatDuration(state.duration)}',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recording in progress...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  Text(
                    isRecording 
                        ? 'Tap the red button to stop recording'
                        : 'Tap to start recording',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  if (!isRecording) ...[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter recording title (optional)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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

  String _getStatusText(AudioRecordState state) {
    switch(state.status) {
      case AudioRecordStatus.recording:
        return 'Recording...';
      case AudioRecordStatus.initializing:
        return 'Starting...';
      case AudioRecordStatus.stopping:
        return 'Saving...';
      default:
        return 'Ready to Record';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
