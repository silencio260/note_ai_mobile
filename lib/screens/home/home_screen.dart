import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/date_grouping_utils.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/recording/presentation/bloc/recording_bloc.dart';
import 'widgets/home_header.dart';
import 'widgets/notes_toggle.dart';
import 'widgets/recording_card.dart';
import 'widgets/home_bottom_actions.dart';

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
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      context
          .read<RecordingBloc>()
          .add(LoadRecordingsRequested(authState.user!.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              onProfileTap: () {
                // Navigate to settings/profile
                // For now, simple sign out for testing
                _showProfileOptions(context);
              },
            ),
            NotesToggle(
              onToggle: (index) {
                // Handle tab toggle (eg. show folders)
                debugPrint('Tab toggled: $index');
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<RecordingBloc, RecordingState>(
                builder: (context, state) {
                  if (state.status == RecordingStatus.loading &&
                      state.recordings.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.black));
                  }

                  if (state.recordings.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final groupedItems =
                      DateGroupingUtils.groupRecordingsByDate(state.recordings);

                  return RefreshIndicator(
                    color: Colors.black,
                    onRefresh: () async {
                      final authState = context.read<AuthBloc>().state;
                      if (authState.user != null) {
                        context
                            .read<RecordingBloc>()
                            .add(LoadRecordingsRequested(authState.user!.uid));
                      }
                    },
                    child: ListView.builder(
                      // padding: const EdgeInsets.only(bottom: 20, top: 4), // Reduced padding since it's not a bottomSheet anymore
                      itemCount: groupedItems.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildOngoingSection(state);
                        }

                        final item = groupedItems[index - 1];

                        if (item is DateHeaderItem) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                            child: Text(
                              item.date,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          );
                        } else if (item is RecordingListItem) {
                          return RecordingCard(
                            recording: item.recording,
                            onTap: () {
                              Navigator.pushNamed(context, '/player',
                                  arguments: item.recording);
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
                              final updated =
                                  item.recording.copyWith(title: newTitle);
                              context
                                  .read<RecordingBloc>()
                                  .add(SaveRecordingRequested(updated));
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomActions(
        onRecordTap: () {
          Navigator.pushNamed(context, '/record');
        },
        onNewNoteTap: () {
          Navigator.pushNamed(context, '/record');
        },
      ),
    );
  }

  Widget _buildOngoingSection(RecordingState state) {
    // If no recordings are in a transcribing state, return nothing.
    // In our simplified mock, we might just show an example if the state is loading.
    bool hasProcessing = state.recordings.any((r) => r.isTranscribing);

    if (!hasProcessing) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Ongoing',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black26,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Analyzing...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                size: 80,
                color: Colors.black26, // Slightly darker for better visibility
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No recordings yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Capture your thoughts and let Note AI transcribe and summarize them instantly.',
              style:
                  TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.person),
              title: Text('Account Information'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(const AuthSignOutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
