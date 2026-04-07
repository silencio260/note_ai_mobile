import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_preferences.dart';

/// Data-layer representation of a user — handles Firestore serialization.
class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isAnonymous;
  final bool isEmailVerified;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
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

  /// Create from Firebase Auth user (no Firestore preferences yet)
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
      isEmailVerified: user.emailVerified,
      preferences: const UserPreferences(),
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      preferences: UserPreferences.fromMap(
        map['preferences'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isAnonymous': isAnonymous,
        'isEmailVerified': isEmailVerified,
        'preferences': preferences.toMap(),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      };

  UserEntity toEntity() => UserEntity(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        isAnonymous: isAnonymous,
        isEmailVerified: isEmailVerified,
        preferences: preferences,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static UserModel fromEntity(UserEntity entity) => UserModel(
        uid: entity.uid,
        email: entity.email,
        displayName: entity.displayName,
        photoUrl: entity.photoUrl,
        isAnonymous: entity.isAnonymous,
        isEmailVerified: entity.isEmailVerified,
        preferences: entity.preferences,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
