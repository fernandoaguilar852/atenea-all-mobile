import '../../domain/entities/cotizacion_detalle_entity.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../../domain/entities/cotizacion_impresion_entity.dart';
import '../../domain/entities/nueva_cotizacion_entity.dart';
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

  @override
  Future<CotizacionCreadaEntity> crearCotizacion({
    required int clienteId,
    required NuevaCotizacion cotizacion,
  }) async {
    final response = await _datasource.createCotizacion(
      clienteId: clienteId,
      data: _datosCabecera(cotizacion),
    );

    return CotizacionMapper.toCreadaEntity(response.data);
  }

  @override
  Future<int> crearDetalle({
    required int clienteId,
    required int cotizacionId,
    required NuevaLineaCotizacion linea,
  }) async {
    final response = await _datasource.createCotizacionDetalle(
      clienteId: clienteId,
      data: _datosLinea(cotizacionId, linea),
    );

    return response.data.cotizacionDetalleId;
  }

  @override
  Future<void> eliminarCotizacion({
    required int clienteId,
    required int cotizacionId,
  }) async {
    await _datasource.deleteCotizacion(
      clienteId: clienteId,
      cotizacionId: cotizacionId,
    );
  }

  @override
  Future<void> actualizarCotizacion({
    required int clienteId,
    required int cotizacionId,
    required NuevaCotizacion cotizacion,
    String? observacion,
  }) async {
    final data = _datosCabecera(cotizacion);
    if (observacion != null) {
      data['observacion'] = observacion.trim();
    }

    await _datasource.updateCotizacion(
      clienteId: clienteId,
      cotizacionId: cotizacionId,
      data: data,
    );
  }

  @override
  Future<void> actualizarDetalle({
    required int clienteId,
    required int cotizacionId,
    required NuevaLineaCotizacion linea,
  }) async {
    final detalleId = linea.cotizacionDetalleId;
    if (detalleId == null) {
      throw ArgumentError('La línea no tiene cotizacionDetalleId: no se puede actualizar');
    }

    await _datasource.updateCotizacionDetalle(
      clienteId: clienteId,
      cotizacionDetalleId: detalleId,
      data: _datosLinea(cotizacionId, linea),
    );
  }

  @override
  Future<void> eliminarDetalle({
    required int clienteId,
    required int cotizacionDetalleId,
  }) async {
    await _datasource.deleteCotizacionDetalle(
      clienteId: clienteId,
      cotizacionDetalleId: cotizacionDetalleId,
    );
  }

  /// Cuerpo de la cabecera (sirve para crear y para actualizar)
  Map<String, dynamic> _datosCabecera(NuevaCotizacion cotizacion) {
    return <String, dynamic>{
      'consumidorNombre': cotizacion.consumidorNombre,
      'consumidorIdentificacion': cotizacion.consumidorIdentificacion,
      // Email y teléfono solo se envían si tienen contenido
      if (cotizacion.consumidorEmail != null &&
          cotizacion.consumidorEmail!.trim().isNotEmpty)
        'consumidorEmail': cotizacion.consumidorEmail!.trim(),
      if (cotizacion.consumidorTelefono != null &&
          cotizacion.consumidorTelefono!.trim().isNotEmpty)
        'consumidorTelefono': cotizacion.consumidorTelefono!.trim(),
      'subtotalSinImpuestos': cotizacion.subtotalSinImpuestos,
      'totalDescuentos': cotizacion.totalDescuentos,
      'totalImpuestos': cotizacion.totalImpuestos,
      'totalIva': cotizacion.totalIva,
      'totalInc': cotizacion.totalInc,
      'totalIca': cotizacion.totalIca,
      'total': cotizacion.total,
    };
  }

  /// Cuerpo de una línea (sirve para crear y para actualizar)
  Map<String, dynamic> _datosLinea(int cotizacionId, NuevaLineaCotizacion linea) {
    return <String, dynamic>{
      'cotizacionId': cotizacionId,
      'productoId': linea.productoId,
      'cantidad': linea.cantidad,
      'precioUnitario': linea.precioUnitario,
      'descuentoPorcentaje': linea.descuentoPorcentaje,
      'codigoImpuesto': linea.codigoImpuesto,
      'porcentajeImpuesto':
          linea.porcentajeImpuesto > 0 ? linea.porcentajeImpuesto : null,
      'observacionLinea': linea.observacionLinea,
    };
  }
}
