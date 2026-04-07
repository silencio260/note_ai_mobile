import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String name;
  final String role;
  final String summaryStyle; // 'bullet_points' | 'paragraph' | 'key_points'
  final bool autoTranscribe;
  final bool autoSummarize;
  final String language; // BCP-47 code e.g. 'en', 'fr'
  final String transcriptionLanguage;
  final bool useSystemTheme;
  final bool darkMode;

  const UserPreferences({
    this.name = '',
    this.role = '',
    this.summaryStyle = 'bullet_points',
    this.autoTranscribe = true,
    this.autoSummarize = false,
    this.language = 'en',
    this.transcriptionLanguage = 'en',
    this.useSystemTheme = true,
    this.darkMode = false,
  });

  UserPreferences copyWith({
    String? name,
    String? role,
    String? summaryStyle,
    bool? autoTranscribe,
    bool? autoSummarize,
    String? language,
    String? transcriptionLanguage,
    bool? useSystemTheme,
    bool? darkMode,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      role: role ?? this.role,
      summaryStyle: summaryStyle ?? this.summaryStyle,
      autoTranscribe: autoTranscribe ?? this.autoTranscribe,
      autoSummarize: autoSummarize ?? this.autoSummarize,
      language: language ?? this.language,
      transcriptionLanguage:
          transcriptionLanguage ?? this.transcriptionLanguage,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'role': role,
        'summaryStyle': summaryStyle,
        'autoTranscribe': autoTranscribe,
        'autoSummarize': autoSummarize,
        'language': language,
        'transcriptionLanguage': transcriptionLanguage,
        'useSystemTheme': useSystemTheme,
        'darkMode': darkMode,
      };

  factory UserPreferences.fromMap(Map<String, dynamic> map) => UserPreferences(
        name: map['name'] as String? ?? '',
        role: map['role'] as String? ?? '',
        summaryStyle: map['summaryStyle'] as String? ?? 'bullet_points',
        autoTranscribe: map['autoTranscribe'] as bool? ?? true,
        autoSummarize: map['autoSummarize'] as bool? ?? false,
        language: map['language'] as String? ?? 'en',
        transcriptionLanguage:
            map['transcriptionLanguage'] as String? ?? 'en',
        useSystemTheme: map['useSystemTheme'] as bool? ?? true,
        darkMode: map['darkMode'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        name,
        role,
        summaryStyle,
        autoTranscribe,
        autoSummarize,
        language,
        transcriptionLanguage,
        useSystemTheme,
        darkMode,
      ];
}
