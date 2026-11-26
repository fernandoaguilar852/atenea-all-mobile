import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/catalogs_providers.dart'
    show
        cajasProvider,
        consumidoresSearchProvider,
        productosSearchProvider,
        proveedoresSearchProvider,
        tiposProductoProvider;
import '../../features/alertas_stock/presentation/providers/alertas_stock_provider.dart'
    show alertasStockProvider;
import '../../features/chat/presentation/providers/chat_provider.dart'
    show chatProvider;
import '../../features/consumidores/presentation/providers/consumidores_provider.dart'
    show consumidoresProvider;
import '../../features/cotizaciones/presentation/providers/cotizaciones_provider.dart'
    show cotizacionesProvider;
import '../../features/dashboard/presentation/providers/dashboard_provider.dart'
    show dashboardProvider;
import '../../features/movimientos/presentation/providers/movimientos_provider.dart'
    show movimientosProvider;
import '../../features/notificaciones/presentation/providers/notificaciones_provider.dart'
    show notificacionesProvider;
import '../../features/productos/presentation/providers/productos_provider.dart'
    show productosProvider;
import '../../features/reportes/presentation/providers/reportes_provider.dart'
    show
        arqueoReporteProvider,
        costoBeneficioReporteProvider,
        inventarioReporteProvider,
        stockReporteProvider,
        ventaDetalleReporteProvider,
        ventasReporteProvider;
import '../../features/resoluciones/presentation/providers/resoluciones_provider.dart'
    show resolucionesProvider;
import '../../features/ventas/presentation/providers/ventas_provider.dart'
    show ventasProvider;
import 'navigation_provider.dart' show mainScreenIndexProvider;

/// Descarta todos los datos del negocio que la app guarda en memoria.
///
/// Se llama cuando cambia el negocio de la sesión (al cerrar sesión o al
/// entrar con otro negocio en el mismo teléfono). Sin esto, los estados de
/// cada módulo seguirían vivos y mostrarían por un instante la información del
/// negocio anterior.
///
/// IMPORTANTE: al crear un módulo nuevo con un provider que guarde datos del
/// negocio, hay que agregarlo aquí.
void limpiarDatosDeSesion(WidgetRef ref) {
  // Módulos
  ref.invalidate(cotizacionesProvider);
  ref.invalidate(consumidoresProvider);
  ref.invalidate(ventasProvider);
  ref.invalidate(productosProvider);
  ref.invalidate(resolucionesProvider);
  ref.invalidate(movimientosProvider);
  ref.invalidate(dashboardProvider);
  ref.invalidate(alertasStockProvider);
  ref.invalidate(notificacionesProvider);
  ref.invalidate(chatProvider);

  // Reportes
  ref.invalidate(ventasReporteProvider);
  ref.invalidate(ventaDetalleReporteProvider);
  ref.invalidate(inventarioReporteProvider);
  ref.invalidate(arqueoReporteProvider);
  ref.invalidate(stockReporteProvider);
  ref.invalidate(costoBeneficioReporteProvider);

  // Catálogos y búsquedas que dependen del negocio
  ref.invalidate(tiposProductoProvider);
  ref.invalidate(cajasProvider);
  ref.invalidate(productosSearchProvider);
  ref.invalidate(consumidoresSearchProvider);
  ref.invalidate(proveedoresSearchProvider);

  // Vuelve a la pestaña inicial (Dashboard)
  ref.invalidate(mainScreenIndexProvider);
}
