class ApiConstants {
  ApiConstants._();

  // Base URL
  static const String baseUrl =
      'https://0kdi3on5i8.execute-api.us-east-1.amazonaws.com/Prod';

  // API Version
  static const String apiVersion = 'v1';
  static const String apiPrefix = 'pos';

  // Endpoints Base
  static const String auth = '/login';
  static const String refresh = '/login/refresh-token';
  static const String logout = '/login/logout';
  static const String recuperar = '/login/recuperar';
  static const String resetPassword = '/login/reset-password-with-code';
  static const String cambiarPassword = '/login/cambiar-password';
  static const String validarToken = '/login/validar-token';

  static const String ventas = '/ventas';
  static const String ventaDetalles = '/venta-detalles';
  static const String products = '/products';
  static const String clientes = '/clientes';
  static const String consumidores = '/consumidores';
  static const String cartera = '/cartera';
  static const String apartados = '/apartados';
  static const String cotizaciones = '/cotizaciones';
  static const String ordenesServicio = '/ordenes-servicio';
  static const String cajas = '/cajas';
  static const String arqueosCaja = '/arqueos-caja';
  static const String movimientosInventario = '/movimientos-inventario';
  static const String reportes = '/reportes';
  static const String notificaciones = '/notificaciones';
  static const String formaPago = '/forma-pago';
  static const String usuarios = '/usuarios';
  static const String permissions = '/permissions';

  // Headers
  static const String headerMessageUuid = 'message-uuid';
  static const String headerRequestAppId = 'request-app-id';
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';

  // Header Values
  static const String appId = 'ATENEA-MOBILE-APP';
  static const String contentTypeJson = 'application/json';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl/$apiVersion/$apiPrefix$endpoint';
  }
}
