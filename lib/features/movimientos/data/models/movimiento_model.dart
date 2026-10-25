import 'package:json_annotation/json_annotation.dart';

part 'movimiento_model.g.dart';

/// DTO/Model para Movimiento de Inventario
/// Corresponde a la estructura JSON de la API
@JsonSerializable()
class MovimientoModel {
  final int movimientoId;
  final int productoId;
  final String? nombreProducto; // nombre del producto desde JOIN
  final int usuarioId;
  final int clienteId;
  final int? proveedorId;
  final int? cajaId;
  final int? pagoId;
  final int? ventaId;
  final String tipo; // 'entrada', 'salida', 'venta', etc.
  final dynamic costo; // Puede venir como number o null
  final dynamic impuesto; // Puede venir como number o null
  final dynamic descuentoUnidad; // Puede venir como number o null
  final dynamic cantidad; // NUMERIC viene como number
  final String? observacion;
  final String fecha; // ISO date string
  final String createdAt;
  final String? updatedAt;
  final int? updatedByUsuarioId;
  final String? deletedAt;
  final int? deletedByUsuarioId;
  final String? deleteReason;

  const MovimientoModel({
    required this.movimientoId,
    required this.productoId,
    this.nombreProducto,
    required this.usuarioId,
    required this.clienteId,
    this.proveedorId,
    this.cajaId,
    this.pagoId,
    this.ventaId,
    required this.tipo,
    this.costo,
    this.impuesto,
    this.descuentoUnidad,
    required this.cantidad,
    this.observacion,
    required this.fecha,
    required this.createdAt,
    this.updatedAt,
    this.updatedByUsuarioId,
    this.deletedAt,
    this.deletedByUsuarioId,
    this.deleteReason,
  });

  factory MovimientoModel.fromJson(Map<String, dynamic> json) =>
      _$MovimientoModelFromJson(json);

  Map<String, dynamic> toJson() => _$MovimientoModelToJson(this);
}

/// Respuesta de la API con data y paginación
@JsonSerializable()
class MovimientosResponse {
  final MovimientosData data;
  final PaginacionModel? pagination;

  const MovimientosResponse({
    required this.data,
    this.pagination,
  });

  factory MovimientosResponse.fromJson(Map<String, dynamic> json) =>
      _$MovimientosResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovimientosResponseToJson(this);
}

/// Data de movimientos
@JsonSerializable()
class MovimientosData {
  final List<MovimientoModel> movimientos;

  const MovimientosData({
    required this.movimientos,
  });

  factory MovimientosData.fromJson(Map<String, dynamic> json) =>
      _$MovimientosDataFromJson(json);

  Map<String, dynamic> toJson() => _$MovimientosDataToJson(this);
}

/// Model de paginación
@JsonSerializable()
class PaginacionModel {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const PaginacionModel({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginacionModel.fromJson(Map<String, dynamic> json) =>
      _$PaginacionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginacionModelToJson(this);
}

/// Respuesta para un solo movimiento
@JsonSerializable()
class MovimientoSingleResponse {
  final MovimientoModel data;

  const MovimientoSingleResponse({required this.data});

  factory MovimientoSingleResponse.fromJson(Map<String, dynamic> json) =>
      _$MovimientoSingleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovimientoSingleResponseToJson(this);
}
