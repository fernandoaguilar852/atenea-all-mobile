import 'package:json_annotation/json_annotation.dart';

part 'tipo_producto.g.dart';

@JsonSerializable()
class TipoProducto {
  final int tipoProductoId;
  final int clienteId;
  final String nombre;
  final String descripcion;
  final bool activo;
  final String createdAt;

  TipoProducto({
    required this.tipoProductoId,
    required this.clienteId,
    required this.nombre,
    required this.descripcion,
    required this.activo,
    required this.createdAt,
  });

  factory TipoProducto.fromJson(Map<String, dynamic> json) =>
      _$TipoProductoFromJson(json);

  Map<String, dynamic> toJson() => _$TipoProductoToJson(this);
}

@JsonSerializable()
class TipoProductoResponse {
  final List<TipoProducto> data;
  final Pagination? pagination;

  TipoProductoResponse({
    required this.data,
    this.pagination,
  });

  factory TipoProductoResponse.fromJson(Map<String, dynamic> json) =>
      _$TipoProductoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TipoProductoResponseToJson(this);
}

@JsonSerializable()
class Pagination {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  Pagination({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
