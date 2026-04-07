import 'package:equatable/equatable.dart';

import 'user_preferences.dart';

class UserEntity extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isEmailVerified;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
    this.isEmailVerified = false,
    required this.preferences,
    required this.createdAt,
    this.updatedAt,
  });

  /// Whether the user is a full authenticated user (not a guest)
  bool get isAuthenticated => !isAnonymous;

  /// Display name with fallback chain: displayName → email prefix → 'Guest'
  String get resolvedDisplayName {
    if (displayName != null && displayName!.isNotEmpty) return displayName!;
    if (email != null && email!.isNotEmpty) return email!.split('@').first;
    if (isAnonymous) return 'Guest';
    return 'User';
  }

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
    bool? isEmailVerified,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        isAnonymous,
        isEmailVerified,
        preferences,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() =>
      'UserEntity(uid: $uid, email: $email, isAnonymous: $isAnonymous)';
}
