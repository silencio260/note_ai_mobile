import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (authState.status == AuthStatus.authenticated && authState.user != null) ...[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: authState.user!.photoUrl != null
                                ? NetworkImage(authState.user!.photoUrl!)
                                : null,
                            child: authState.user!.photoUrl == null
                                ? Text(
                                    authState.user!.displayName?.isNotEmpty == true
                                        ? authState.user!.displayName![0].toUpperCase()
                                        : 'U',
                                  )
                                : null,
                          ),
                          title: Text(
                            authState.user!.displayName?.isNotEmpty == true ? authState.user!.displayName! : 'User',
                            style: theme.textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            authState.user!.email ?? 'No email associated',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ] else ...[
                        const ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text('Not signed in'),
                          subtitle: Text('Sign in to access your account'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings Options
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      subtitle: const Text('About NoteAI'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showHelpDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Actions
              Card(
                child: Column(
                  children: [
                    if (authState.status == AuthStatus.authenticated) ...[
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: const Text('Sign out of your account'),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // App Info
              Center(
                child: Text(
                  'NoteAI v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? Your local recordings will be preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About NoteAI'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'AI-powered voice note-taker',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'NoteAI helps you capture, transcribe, and summarize your voice recordings with the power of AI. Transform your thoughts into organized, searchable content.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
