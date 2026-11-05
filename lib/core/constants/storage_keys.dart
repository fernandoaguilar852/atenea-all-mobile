class StorageKeys {
  StorageKeys._();

  // Prefijo único para esta app (evita conflictos con otras apps ATENEA)
  static const String _prefix = 'atenea_local_';

  // Auth
  static const String accessToken = '${_prefix}access_token';
  static const String refreshToken = '${_prefix}refresh_token';
  static const String userId = '${_prefix}user_id';
  static const String clienteId = '${_prefix}cliente_id';
  static const String rolId = '${_prefix}rol_id';
  static const String nombre = '${_prefix}nombre';
  static const String email = '${_prefix}email';
  static const String nombreRol = '${_prefix}nombre_rol';
  static const String prefijo = '${_prefix}prefijo';
  static const String estadoPlan = '${_prefix}estado_plan';
  static const String diasActivos = '${_prefix}dias_activos';

  // Settings
  static const String themeMode = '${_prefix}theme_mode';
  static const String language = '${_prefix}language';
  static const String notifications = '${_prefix}notifications_enabled';
  static const String biometric = '${_prefix}biometric_enabled';

  // Cache
  static const String products = '${_prefix}products_cache';
  static const String clients = '${_prefix}clients_cache';
  static const String lastSync = '${_prefix}last_sync_timestamp';

  // Printer
  static const String printerAddress = '${_prefix}printer_bt_address';
  static const String printerName = '${_prefix}printer_name';
  static const String printerType = '${_prefix}printer_type';

  // Onboarding
  static const String firstLaunch = '${_prefix}first_launch';
  static const String onboardingComplete = '${_prefix}onboarding_complete';
}
