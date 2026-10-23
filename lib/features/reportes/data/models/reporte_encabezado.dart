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
  final String responsableIVA;
  final String tipoNegocio;
  final String estado;
  final String plan;
  final String fechaCreacion;
  final String fechaActualizacion;
  final int ciudadId;
  final int monedaId;
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
    required this.monedaId,
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
  final int departamentoId;

  ReporteCiudad({
    required this.ciudadId,
    required this.nombre,
    required this.departamentoId,
  });

  factory ReporteCiudad.fromJson(Map<String, dynamic> json) =>
      _$ReporteCiudadFromJson(json);

  Map<String, dynamic> toJson() => _$ReporteCiudadToJson(this);
}

@JsonSerializable()
class ReporteMoneda {
  final int monedaId;
  final String codigo;
  final String nombre;
  final String simbolo;

  ReporteMoneda({
    required this.monedaId,
    required this.codigo,
    required this.nombre,
    required this.simbolo,
  });

  factory ReporteMoneda.fromJson(Map<String, dynamic> json) =>
      _$ReporteMonedaFromJson(json);

  Map<String, dynamic> toJson() => _$ReporteMonedaToJson(this);
}

@JsonSerializable()
class ReportePagination {
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasPrevious;
  final bool hasNext;

  ReportePagination({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPrevious,
    required this.hasNext,
  });

  factory ReportePagination.fromJson(Map<String, dynamic> json) =>
      _$ReportePaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ReportePaginationToJson(this);
}
