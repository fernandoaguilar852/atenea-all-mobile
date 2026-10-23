class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ATENEA POS';
  static const String appNameShort = 'ATENEA';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String keyAccessToken = 'atenea_access_token';
  static const String keyRefreshToken = 'atenea_refresh_token';
  static const String keyUserData = 'atenea_user_data';
  static const String keyRememberMe = 'atenea_remember_me';
  static const String keyThemeMode = 'atenea_theme_mode';
  static const String keyLanguage = 'atenea_language';
  static const String keyFirstLaunch = 'atenea_first_launch';

  // Pagination
  static const int defaultPageSize = 20;
  static const int defaultPageNumber = 1;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minEmailLength = 5;
  static const int maxEmailLength = 100;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration typingDebounce = Duration(milliseconds: 300);

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const Duration shortCacheExpiration = Duration(minutes: 30);

  // Session
  static const Duration sessionTimeout = Duration(hours: 4);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);

  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String currencyFormat = '\$#,##0.00';

  // Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxFileSize = 10 * 1024 * 1024; // 10 MB

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
