import '../entities/cotizacion_detalle_entity.dart';
import '../entities/cotizacion_entity.dart';
import '../entities/cotizacion_impresion_entity.dart';

/// Contrato del repositorio de Cotizaciones
abstract class CotizacionesRepository {
  /// Lista cotizaciones con paginación y filtros (búsqueda y origen)
  Future<CotizacionesListEntity> getCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String origen = CotizacionOrigen.defaultOrigen,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene el detalle completo de una cotización (con sus productos)
  Future<CotizacionDetalleEntity> getCotizacionDetalle({
    required int clienteId,
    required int cotizacionId,
  });

  /// Obtiene los datos para generar el PDF de una cotización
  Future<CotizacionImpresionEntity> getCotizacionImpresion({
    required int clienteId,
    required int cotizacionId,
  });
}
