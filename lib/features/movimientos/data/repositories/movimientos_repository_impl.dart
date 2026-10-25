import '../../domain/entities/movimiento_entity.dart';
import '../../domain/repositories/movimientos_repository.dart';
import '../datasources/movimientos_remote_datasource.dart';
import '../mappers/movimiento_mapper.dart';

/// Implementación concreta del repositorio de Movimientos
/// Usa el datasource y los mappers para convertir DTOs a Entities
class MovimientosRepositoryImpl implements MovimientosRepository {
  final MovimientosRemoteDatasource _datasource;

  MovimientosRepositoryImpl(this._datasource);

  @override
  Future<MovimientosListEntity> getMovimientos({
    required int clienteId,
    int? productoId,
    int? proveedorId,
    TipoMovimiento? tipo,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool includeDeleted = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _datasource.getMovimientos(
      clienteId: clienteId,
      productoId: productoId,
      proveedorId: proveedorId,
      tipo: tipo != null ? MovimientoMapper.tipoMovimientoToString(tipo) : null,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      includeDeleted: includeDeleted,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );

    return MovimientoMapper.toListEntity(response);
  }

  @override
  Future<MovimientoEntity> getMovimientoById({
    required int movimientoId,
    required int clienteId,
  }) async {
    final response = await _datasource.getMovimientoById(
      movimientoId: movimientoId,
      clienteId: clienteId,
    );

    return MovimientoMapper.toEntity(response.data);
  }

  @override
  Future<MovimientoEntity> createMovimiento({
    required int productoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    required TipoMovimiento tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required double cantidad,
    String? observacion,
    required DateTime fecha,
  }) async {
    final data = {
      'productoId': productoId,
      'usuarioId': usuarioId,
      'clienteId': clienteId,
      if (proveedorId != null) 'proveedorId': proveedorId,
      if (pagoId != null) 'pagoId': pagoId,
      if (cajaId != null) 'cajaId': cajaId,
      if (ventaId != null) 'ventaId': ventaId,
      'tipo': MovimientoMapper.tipoMovimientoToString(tipo),
      'costo': costo,
      'impuesto': impuesto,
      'descuentoUnidad': descuentoUnidad,
      'cantidad': cantidad,
      if (observacion != null) 'observacion': observacion,
      'fecha': fecha.toIso8601String(),
    };

    final response = await _datasource.createMovimiento(data: data);
    return MovimientoMapper.toEntity(response.data);
  }

  @override
  Future<MovimientoEntity> updateMovimiento({
    required int movimientoId,
    required int productoId,
    required int usuarioId,
    required int clienteId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    required TipoMovimiento tipo,
    required double costo,
    required double impuesto,
    required double descuentoUnidad,
    required double cantidad,
    String? observacion,
    required DateTime fecha,
    required int updatedByUsuarioId,
  }) async {
    final data = {
      'productoId': productoId,
      'usuarioId': usuarioId,
      'clienteId': clienteId,
      if (proveedorId != null) 'proveedorId': proveedorId,
      if (pagoId != null) 'pagoId': pagoId,
      if (cajaId != null) 'cajaId': cajaId,
      if (ventaId != null) 'ventaId': ventaId,
      'tipo': MovimientoMapper.tipoMovimientoToString(tipo),
      'costo': costo,
      'impuesto': impuesto,
      'descuentoUnidad': descuentoUnidad,
      'cantidad': cantidad,
      if (observacion != null) 'observacion': observacion,
      'fecha': fecha.toIso8601String(),
      'updatedByUsuarioId': updatedByUsuarioId,
    };

    final response = await _datasource.updateMovimiento(
      movimientoId: movimientoId,
      clienteId: clienteId,
      data: data,
    );

    return MovimientoMapper.toEntity(response.data);
  }

  @override
  Future<MovimientoEntity> patchMovimiento({
    required int movimientoId,
    required int clienteId,
    int? productoId,
    int? usuarioId,
    int? proveedorId,
    int? pagoId,
    int? cajaId,
    int? ventaId,
    TipoMovimiento? tipo,
    double? costo,
    double? impuesto,
    double? descuentoUnidad,
    double? cantidad,
    String? observacion,
    DateTime? fecha,
    required int updatedByUsuarioId,
  }) async {
    final data = <String, dynamic>{
      'updatedByUsuarioId': updatedByUsuarioId,
    };

    if (productoId != null) data['productoId'] = productoId;
    if (usuarioId != null) data['usuarioId'] = usuarioId;
    if (proveedorId != null) data['proveedorId'] = proveedorId;
    if (pagoId != null) data['pagoId'] = pagoId;
    if (cajaId != null) data['cajaId'] = cajaId;
    if (ventaId != null) data['ventaId'] = ventaId;
    if (tipo != null) data['tipo'] = MovimientoMapper.tipoMovimientoToString(tipo);
    if (costo != null) data['costo'] = costo;
    if (impuesto != null) data['impuesto'] = impuesto;
    if (descuentoUnidad != null) data['descuentoUnidad'] = descuentoUnidad;
    if (cantidad != null) data['cantidad'] = cantidad;
    if (observacion != null) data['observacion'] = observacion;
    if (fecha != null) data['fecha'] = fecha.toIso8601String();

    final response = await _datasource.patchMovimiento(
      movimientoId: movimientoId,
      clienteId: clienteId,
      data: data,
    );

    return MovimientoMapper.toEntity(response.data);
  }

  @override
  Future<void> deleteMovimiento({
    required int movimientoId,
    required int clienteId,
    required int deletedByUsuarioId,
    String? deleteReason,
  }) async {
    final data = {
      'deletedByUsuarioId': deletedByUsuarioId,
      if (deleteReason != null) 'deleteReason': deleteReason,
    };

    await _datasource.deleteMovimiento(
      movimientoId: movimientoId,
      clienteId: clienteId,
      data: data,
    );
  }
}
