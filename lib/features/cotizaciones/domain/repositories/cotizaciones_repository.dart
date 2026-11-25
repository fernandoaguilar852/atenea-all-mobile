import '../entities/cotizacion_entity.dart';

/// Contrato del repositorio de Cotizaciones
abstract class CotizacionesRepository {
  /// Lista cotizaciones con paginación
  Future<CotizacionesListEntity> getCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
  });
}
