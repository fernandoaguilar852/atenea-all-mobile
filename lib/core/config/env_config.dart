class EnvConfig {
  EnvConfig._();

  // Environment Type
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // API Configuration - API Gateway Global (Balanceador)
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue:
        'https://wzoknle6j7.execute-api.us-east-1.amazonaws.com/Prod',
  );

  // Features Flags
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );

  // App Configuration
  static const int sessionTimeoutMinutes = int.fromEnvironment(
    'SESSION_TIMEOUT_MINUTES',
    defaultValue: 240, // 4 hours
  );

  static const int cacheExpirationHours = int.fromEnvironment(
    'CACHE_EXPIRATION_HOURS',
    defaultValue: 24,
  );

  // Debug Configuration
  static const bool showPerformanceOverlay = bool.fromEnvironment(
    'SHOW_PERFORMANCE_OVERLAY',
    defaultValue: false,
  );

  static const bool debugShowMaterialGrid = bool.fromEnvironment(
    'DEBUG_SHOW_MATERIAL_GRID',
    defaultValue: false,
  );

  static const bool debugShowCheckedModeBanner = bool.fromEnvironment(
    'DEBUG_SHOW_CHECKED_MODE_BANNER',
    defaultValue: true,
  );
}
