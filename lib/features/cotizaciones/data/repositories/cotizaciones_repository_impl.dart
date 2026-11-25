import '../../domain/entities/cotizacion_detalle_entity.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../../domain/entities/cotizacion_impresion_entity.dart';
import '../../domain/repositories/cotizaciones_repository.dart';
import '../datasources/cotizaciones_remote_datasource.dart';
import '../mappers/cotizacion_mapper.dart';

/// Implementación concreta del repositorio de Cotizaciones
/// Usa el datasource y los mappers para convertir DTOs a Entities
class CotizacionesRepositoryImpl implements CotizacionesRepository {
  final CotizacionesRemoteDatasource _datasource;

  CotizacionesRepositoryImpl(this._datasource);

  @override
  Future<CotizacionesListEntity> getCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String origen = CotizacionOrigen.defaultOrigen,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _datasource.getCotizaciones(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
      origen: origen,
      startDate: startDate,
      endDate: endDate,
    );

    return CotizacionMapper.toListEntity(response);
  }

  @override
  Future<CotizacionDetalleEntity> getCotizacionDetalle({
    required int clienteId,
    required int cotizacionId,
  }) async {
    final response = await _datasource.getCotizacionDetalle(
      clienteId: clienteId,
      cotizacionId: cotizacionId,
    );

    return CotizacionMapper.toDetalleEntity(response.data);
  }

  @override
  Future<CotizacionImpresionEntity> getCotizacionImpresion({
    required int clienteId,
    required int cotizacionId,
  }) async {
    final response = await _datasource.getCotizacionImpresion(
      clienteId: clienteId,
      cotizacionId: cotizacionId,
    );

    return CotizacionMapper.toImpresionEntity(response.data);
  }
}
