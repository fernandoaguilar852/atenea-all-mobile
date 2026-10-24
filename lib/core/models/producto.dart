import 'package:json_annotation/json_annotation.dart';

part 'producto.g.dart';

@JsonSerializable()
class Producto {
  final int productoId;
  final int clienteId;
  final int tipoProductoId;
  final String nombre;
  final String? codExterno;
  final String? codBarras;
  final String? imagen;
  final double precio;
  final String unidadMedida;
  final String sigla;
  final double stockTotal;
  final double stockMinimo;
  final bool manejaStock;
  final bool activo;
  final int ivaId;
  final double ivaPorcentaje;
  final String ivaDescripcion;

  Producto({
    required this.productoId,
    required this.clienteId,
    required this.tipoProductoId,
    required this.nombre,
    this.codExterno,
    this.codBarras,
    this.imagen,
    required this.precio,
    required this.unidadMedida,
    required this.sigla,
    required this.stockTotal,
    required this.stockMinimo,
    required this.manejaStock,
    required this.activo,
    required this.ivaId,
    required this.ivaPorcentaje,
    required this.ivaDescripcion,
  });

  factory Producto.fromJson(Map<String, dynamic> json) =>
      _$ProductoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductoToJson(this);

  String get displayName => '$productoId - $nombre';
}

@JsonSerializable()
class ProductoData {
  final List<Producto> products;

  ProductoData({required this.products});

  factory ProductoData.fromJson(Map<String, dynamic> json) =>
      _$ProductoDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductoDataToJson(this);
}

@JsonSerializable()
class ProductoPagination {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  ProductoPagination({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory ProductoPagination.fromJson(Map<String, dynamic> json) =>
      _$ProductoPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ProductoPaginationToJson(this);
}

@JsonSerializable()
class ProductoResponse {
  final ProductoData data;
  final ProductoPagination? pagination;

  ProductoResponse({
    required this.data,
    this.pagination,
  });

  factory ProductoResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductoResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductoResponseToJson(this);
}
