import '../config/app_env.dart';

/// Centralized API Endpoints with helper logic for dynamic paths.
///
/// This class handles all URL construction, ensuring that base URLs,
/// versioning, and path parameters are managed in one location.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL derived from compile-time environment variables
  static const String baseUrl = AppEnv.cloudFunctionsBaseUrl;

  // ─── AUTH ────────────────────────────────────────────────────────────────
  static const String login = '$baseUrl/login';
  static const String signup = '$baseUrl/signup';
  static const String deleteAccount = '$baseUrl/user/delete';

  // ─── RECORDINGS ─────────────────────────────────────────────────────────
  static const String transcribe = '$baseUrl/transcribe';
  static const String summarize = '$baseUrl/summarize';
  static const String listRecordings = '$baseUrl/recordings';

  /// Helper to get a specific recording detail URL
  static String recordingDetail(String id) => '$baseUrl/recordings/$id';
  
  /// Helper for transcription status polling
  static String transcriptionStatus(String jobId) => '$baseUrl/transcribe/status/$jobId';

  // ─── AI CHAT ──────────────────────────────────────────────────────────────
  static const String chat = '$baseUrl/chat';
  static const String streamChat = '$baseUrl/chat/stream';

  // ─── SETTINGS & SUBSCRIPTIONS ─────────────────────────────────────────────
  static const String config = '$baseUrl/app/config';
  static const String syncPreferences = '$baseUrl/user/preferences';
}
