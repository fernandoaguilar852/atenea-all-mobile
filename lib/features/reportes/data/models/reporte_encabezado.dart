import 'package:json_annotation/json_annotation.dart';

part 'reporte_encabezado.g.dart';

@JsonSerializable()
class ReporteEncabezado {
  final int clienteId;
  final String nombre;
  final String razonSocial;
  final String nit;
  final String digitoVerificacion;
  final String tipoPersona;
  final String regimen;
  final String direccion;
  final String telefono;
  final String email;
  final String? logoUrl;
  final String? sitioWeb;
  @JsonKey(name: 'responsableIVA', defaultValue: '')
  final String responsableIVA;
  final String tipoNegocio;
  @JsonKey(name: 'estado', defaultValue: '')
  final String estado;
  @JsonKey(name: 'plan', defaultValue: '')
  final String plan;
  @JsonKey(name: 'fechaCreacion', defaultValue: '')
  final String fechaCreacion;
  @JsonKey(name: 'fechaActualizacion', defaultValue: '')
  final String fechaActualizacion;
  final int ciudadId;
  @JsonKey(name: 'codigoCiiu', defaultValue: '')
  final String? codigoCiiu;
  @JsonKey(name: 'codigoPostal', defaultValue: '')
  final String? codigoPostal;
  @JsonKey(name: 'facturaElectronica', defaultValue: false)
  final bool? facturaElectronica;
  @JsonKey(name: 'tipoDocumentoDefault', defaultValue: 'POS')
  final String? tipoDocumentoDefault;
  final ReporteCiudad ciudad;
  final ReporteMoneda moneda;

  ReporteEncabezado({
    required this.clienteId,
    required this.nombre,
    required this.razonSocial,
    required this.nit,
    required this.digitoVerificacion,
    required this.tipoPersona,
    required this.regimen,
    required this.direccion,
    required this.telefono,
    required this.email,
    this.logoUrl,
    this.sitioWeb,
    required this.responsableIVA,
    required this.tipoNegocio,
    required this.estado,
    required this.plan,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.ciudadId,
    this.codigoCiiu,
    this.codigoPostal,
    this.facturaElectronica,
    this.tipoDocumentoDefault,
    required this.ciudad,
    required this.moneda,
  });

  factory ReporteEncabezado.fromJson(Map<String, dynamic> json) =>
      _$ReporteEncabezadoFromJson(json);

  Map<String, dynamic> toJson() => _$ReporteEncabezadoToJson(this);
}

@JsonSerializable()
class ReporteCiudad {
  final int ciudadId;
  final String nombre;
  @JsonKey(name: 'departamento')
  final String departamentoId;
  @JsonKey(name: 'pais', defaultValue: '')
  final String pais;

  ReporteCiudad({
    required this.ciudadId,
    required this.nombre,
    required this.departamentoId,
    required this.pais,
  });

  factory ReporteCiudad.fromJson(Map<String, dynamic> json) =>
      _$ReporteCiudadFromJson(json);

  Map<String, dynamic> toJson() => _$ReporteCiudadToJson(this);
}

@JsonSerializable()
class ReporteMoneda {
  final int monedaId;
  @JsonKey(name: 'codigoIso')
  final String codigo;
  final String nombre;
  final String simbolo;
  @JsonKey(name: 'decimales', defaultValue: 2)
  final int decimales;
  @JsonKey(name: 'activo', defaultValue: true)
  final bool activo;

  ReporteMoneda({
    required this.monedaId,
    required this.codigo,
    required this.nombre,
    required this.simbolo,
    required this.decimales,
    required this.activo,
  });

  factory ReporteMoneda.fromJson(Map<String, dynamic> json) =>
      _$ReporteMonedaFromJson(json);

  Map<String, dynamic> toJson() => _$ReporteMonedaToJson(this);
}

@JsonSerializable()
class ReportePagination {
  @JsonKey(name: 'pageNumber')
  final int currentPage;
  final int pageSize;
  @JsonKey(name: 'totalElement')
  final int totalCount;
  @JsonKey(name: 'hasMoreElements')
  final bool hasNext;

  ReportePagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.hasNext,
  });

  factory ReportePagination.fromJson(Map<String, dynamic> json) =>
      _$ReportePaginationFromJson(json);

  int get totalPages => totalCount > 0 ? ((totalCount - 1) ~/ pageSize) + 1 : 0;
  bool get hasPrevious => currentPage > 1;

  Map<String, dynamic> toJson() => _$ReportePaginationToJson(this);
}
