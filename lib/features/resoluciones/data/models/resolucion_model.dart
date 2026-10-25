import 'package:json_annotation/json_annotation.dart';

part 'resolucion_model.g.dart';

/// DTO/Model para Resolución
/// Corresponde a la estructura JSON de la API
@JsonSerializable()
class ResolucionModel {
  final int resolucionId;
  final int clienteId;
  final String prefijo;
  final int numeroDesde;
  final int numeroHasta;
  final int numeroActual;
  final String numeroResolucion;
  final String fechaResolucion; // ISO date string
  final String fechaVencimiento; // ISO date string
  final bool activo;
  final String createdAt;

  const ResolucionModel({
    required this.resolucionId,
    required this.clienteId,
    required this.prefijo,
    required this.numeroDesde,
    required this.numeroHasta,
    required this.numeroActual,
    required this.numeroResolucion,
    required this.fechaResolucion,
    required this.fechaVencimiento,
    required this.activo,
    required this.createdAt,
  });

  factory ResolucionModel.fromJson(Map<String, dynamic> json) =>
      _$ResolucionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResolucionModelToJson(this);
}

/// Respuesta de la API con data y paginación
@JsonSerializable()
class ResolucionesResponse {
  final ResolucionesData data;
  final PaginacionModel? pagination;

  const ResolucionesResponse({
    required this.data,
    this.pagination,
  });

  factory ResolucionesResponse.fromJson(Map<String, dynamic> json) =>
      _$ResolucionesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResolucionesResponseToJson(this);
}

/// Data de resoluciones
@JsonSerializable()
class ResolucionesData {
  final List<ResolucionModel> resoluciones;

  const ResolucionesData({
    required this.resoluciones,
  });

  factory ResolucionesData.fromJson(Map<String, dynamic> json) =>
      _$ResolucionesDataFromJson(json);

  Map<String, dynamic> toJson() => _$ResolucionesDataToJson(this);
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

/// Respuesta para una sola resolución
@JsonSerializable()
class ResolucionSingleResponse {
  final ResolucionModel data;

  const ResolucionSingleResponse({required this.data});

  factory ResolucionSingleResponse.fromJson(Map<String, dynamic> json) =>
      _$ResolucionSingleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ResolucionSingleResponseToJson(this);
}
