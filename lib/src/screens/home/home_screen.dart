import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/date_grouping_utils.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/recording/presentation/bloc/recording_bloc.dart';
import 'widgets/recording_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch recordings specific to this user profile
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated && authState.user != null) {
      context.read<RecordingBloc>().add(LoadRecordingsRequested(authState.user!.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteAI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Navigate to settings/profile
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<RecordingBloc, RecordingState>(
        listener: (context, state) {
          if (state.status == RecordingStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == RecordingStatus.loading && state.recordings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.recordings.isEmpty) {
            return _buildEmptyState(context);
          }

          final groupedItems = DateGroupingUtils.groupRecordingsByDate(state.recordings);

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState.user != null) {
                context.read<RecordingBloc>().add(LoadRecordingsRequested(authState.user!.uid));
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: groupedItems.length,
              itemBuilder: (context, index) {
                final item = groupedItems[index];

                if (item is DateHeaderItem) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 12),
                    child: Text(
                      item.date,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                } else if (item is RecordingListItem) {
                  return RecordingCard(
                    recording: item.recording,
                    onTap: () {
                      // Navigate to Player Screen
                      Navigator.pushNamed(context, '/player', arguments: item.recording);
                    },
                    onDelete: () {
                      context.read<RecordingBloc>().add(
                        DeleteRecordingRequested(
                          recordingId: item.recording.id,
                          ownerId: item.recording.ownerId,
                        ),
                      );
                    },
                    onRename: (newTitle) {
                      final updated = item.recording.copyWith(title: newTitle);
                      context.read<RecordingBloc>().add(SaveRecordingRequested(updated));
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Recording Modal/Screen
          Navigator.pushNamed(context, '/record');
        },
        icon: const Icon(Icons.mic),
        label: const Text('Record'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_none_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No recordings yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Capture your thoughts and let Note AI transcribe and summarize them instantly.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
