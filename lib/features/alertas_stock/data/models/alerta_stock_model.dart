import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/alerta_stock_entity.dart';

part 'alerta_stock_model.g.dart';

/// Modelo de Alerta de Stock para serialización JSON
@JsonSerializable()
class AlertaStockModel {
  @JsonKey(name: 'alertaId')
  final int alertaId;

  @JsonKey(name: 'productoId')
  final int productoId;

  @JsonKey(name: 'clienteId')
  final int clienteId;

  @JsonKey(name: 'nombreProducto')
  final String nombreProducto;

  @JsonKey(name: 'stockActual')
  final int stockActual;

  @JsonKey(name: 'stockMinimo')
  final int stockMinimo;

  @JsonKey(name: 'fechaAlerta')
  final String fechaAlerta;

  @JsonKey(name: 'updatedAt')
  final String? updatedAt;

  @JsonKey(name: 'porcentajeStock')
  final double? porcentajeStock;

  @JsonKey(name: 'diasEnAlerta')
  final int diasEnAlerta;

  const AlertaStockModel({
    required this.alertaId,
    required this.productoId,
    required this.clienteId,
    required this.nombreProducto,
    required this.stockActual,
    required this.stockMinimo,
    required this.fechaAlerta,
    this.updatedAt,
    this.porcentajeStock,
    required this.diasEnAlerta,
  });

  factory AlertaStockModel.fromJson(Map<String, dynamic> json) =>
      _$AlertaStockModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlertaStockModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  AlertaStockEntity toEntity() {
    return AlertaStockEntity(
      alertaId: alertaId,
      productoId: productoId,
      clienteId: clienteId,
      nombreProducto: nombreProducto,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      fechaAlerta: DateTime.parse(fechaAlerta),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      porcentajeStock: porcentajeStock,
      diasEnAlerta: diasEnAlerta,
    );
  }
}

/// Modelo para la data del response
@JsonSerializable()
class AlertasStockData {
  @JsonKey(name: 'alertas')
  final List<AlertaStockModel> alertas;

  const AlertasStockData({
    required this.alertas,
  });

  factory AlertasStockData.fromJson(Map<String, dynamic> json) =>
      _$AlertasStockDataFromJson(json);

  Map<String, dynamic> toJson() => _$AlertasStockDataToJson(this);
}

/// Modelo de paginación
@JsonSerializable()
class PaginationModel {
  @JsonKey(name: 'totalElement')
  final int totalElement;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'pageNumber')
  final int pageNumber;

  @JsonKey(name: 'hasMoreElements')
  final bool hasMoreElements;

  const PaginationModel({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
}

/// Modelo del response completo del API
@JsonSerializable()
class AlertasStockListResponse {
  @JsonKey(name: 'data')
  final AlertasStockData data;

  @JsonKey(name: 'pagination')
  final PaginationModel? pagination;

  const AlertasStockListResponse({
    required this.data,
    this.pagination,
  });

  factory AlertasStockListResponse.fromJson(Map<String, dynamic> json) =>
      _$AlertasStockListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AlertasStockListResponseToJson(this);

  /// Convierte a response de dominio
  AlertasStockResponse toAlertasStockResponse() {
    return AlertasStockResponse(
      alertas: data.alertas.map((model) => model.toEntity()).toList(),
      totalElement: pagination?.totalElement ?? 0,
      pageSize: pagination?.pageSize ?? 10,
      pageNumber: pagination?.pageNumber ?? 1,
      hasMoreElements: pagination?.hasMoreElements ?? false,
    );
  }
}
