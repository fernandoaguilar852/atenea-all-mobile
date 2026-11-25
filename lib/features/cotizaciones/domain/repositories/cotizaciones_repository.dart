import '../entities/cotizacion_entity.dart';

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
}
