class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String clienteId = 'cliente_id';
  static const String rolId = 'rol_id';
  static const String nombre = 'nombre';
  static const String email = 'email';
  static const String nombreRol = 'nombre_rol';
  static const String prefijo = 'prefijo';
  static const String estadoPlan = 'estado_plan';
  static const String diasActivos = 'dias_activos';

  // Settings
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notifications = 'notifications_enabled';
  static const String biometric = 'biometric_enabled';

  // Cache
  static const String products = 'products_cache';
  static const String clients = 'clients_cache';
  static const String lastSync = 'last_sync_timestamp';

  // Printer
  static const String printerAddress = 'printer_bt_address';
  static const String printerName = 'printer_name';
  static const String printerType = 'printer_type';

  // Onboarding
  static const String firstLaunch = 'first_launch';
  static const String onboardingComplete = 'onboarding_complete';
}
