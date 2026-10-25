import 'package:json_annotation/json_annotation.dart';

part 'proveedor.g.dart';

@JsonSerializable()
class Proveedor {
  final int proveedorId;
  final int clienteId;
  final String nombre;
  final String? razonSocial;
  final String? nit;
  final String? digitoVerificacion;
  final String? tipoPersona;
  final String? regimen;
  final String? codigoCiiu;
  final String? telefono;
  final String? email;
  final String? direccion;
  final int? ciudadId;
  final String? codigoPostal;
  final int? plazoPagoDias;
  final String? contactoPrincipal;
  final bool activo;
  final String createdAt;

  const Proveedor({
    required this.proveedorId,
    required this.clienteId,
    required this.nombre,
    this.razonSocial,
    this.nit,
    this.digitoVerificacion,
    this.tipoPersona,
    this.regimen,
    this.codigoCiiu,
    this.telefono,
    this.email,
    this.direccion,
    this.ciudadId,
    this.codigoPostal,
    this.plazoPagoDias,
    this.contactoPrincipal,
    required this.activo,
    required this.createdAt,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) =>
      _$ProveedorFromJson(json);

  Map<String, dynamic> toJson() => _$ProveedorToJson(this);

  String get displayName => nombre;
}

@JsonSerializable()
class ProveedoresResponse {
  final ProveedoresData data;
  final PaginacionProveedor? pagination;

  const ProveedoresResponse({
    required this.data,
    this.pagination,
  });

  factory ProveedoresResponse.fromJson(Map<String, dynamic> json) =>
      _$ProveedoresResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProveedoresResponseToJson(this);
}

@JsonSerializable()
class ProveedoresData {
  final List<Proveedor> proveedores;

  const ProveedoresData({required this.proveedores});

  factory ProveedoresData.fromJson(Map<String, dynamic> json) =>
      _$ProveedoresDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProveedoresDataToJson(this);
}

@JsonSerializable()
class PaginacionProveedor {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  const PaginacionProveedor({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginacionProveedor.fromJson(Map<String, dynamic> json) =>
      _$PaginacionProveedorFromJson(json);

  Map<String, dynamic> toJson() => _$PaginacionProveedorToJson(this);
}
