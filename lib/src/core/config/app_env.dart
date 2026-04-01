/// AppEnv — reads all compile-time environment variables via --dart-define-from-file
///
/// Usage: flutter run --dart-define-from-file=env/dev.json
class AppEnv {
  AppEnv._();

  /// Whether the app is running in development mode
  static const bool developmentMode =
      bool.fromEnvironment('development_mode', defaultValue: false);

  /// Whether this is the founders/special version
  static const bool foundersVersion =
      bool.fromEnvironment('founders_version', defaultValue: false);

  /// Whether special version features are enabled
  static const bool specialVersionMode =
      bool.fromEnvironment('special_version_mode', defaultValue: false);

  // ─── Firebase ────────────────────────────────────────────────────────────
  static const String firebaseApiKeyAndroid =
      String.fromEnvironment('firebase_api_key_android');

  static const String firebaseApiKeyIos =
      String.fromEnvironment('firebase_api_key_ios');

  // ─── Backend ─────────────────────────────────────────────────────────────
  /// Base URL for all Firebase Cloud Functions
  static const String cloudFunctionsBaseUrl =
      String.fromEnvironment('cloud_functions_base_url');

  // ─── AdMob (deferred) ────────────────────────────────────────────────────
  static const String bannerAdId =
      String.fromEnvironment('banner_ad_id');

  static const String interstitialAdId =
      String.fromEnvironment('interstitial_ad_id');

  static const String appOpenAdId =
      String.fromEnvironment('app_open_ad_id');

  static const String rewardedAdId =
      String.fromEnvironment('rewarded_ad_id');

  static const String nativeAdId =
      String.fromEnvironment('native_ad_id');

  // ─── Push Notifications (deferred) ───────────────────────────────────────
  static const String oneSignalAppId =
      String.fromEnvironment('one_signal_app_id');

  // ─── RevenueCat (deferred) ───────────────────────────────────────────────
  static const String revenueCatApiKeyAndroid =
      String.fromEnvironment('revenue_cat_api_key_android');

  // ─── Analytics (deferred) ────────────────────────────────────────────────
  static const String posthogApiKey =
      String.fromEnvironment('posthog_api_key');

  // ─── Feedback ────────────────────────────────────────────────────────────
  static const String feedBackNestApiKey =
      String.fromEnvironment('feed_back_nest_api_key');
}
