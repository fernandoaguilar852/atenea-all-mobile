import 'package:json_annotation/json_annotation.dart';

part 'notificacion_model.g.dart';

/// Modelo de datos para Notificación (snake_case desde API)
@JsonSerializable()
class NotificacionModel {
  @JsonKey(name: 'notificacionId')
  final int notificacionId;

  @JsonKey(name: 'clienteId')
  final int clienteId;

  @JsonKey(name: 'tipo')
  final String tipo;

  @JsonKey(name: 'titulo')
  final String titulo;

  @JsonKey(name: 'mensaje')
  final String mensaje;

  @JsonKey(name: 'prioridad')
  final String prioridad;

  @JsonKey(name: 'estado')
  final String estado;

  @JsonKey(name: 'resolucionId')
  final int? resolucionId;

  @JsonKey(name: 'metadata')
  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'createdAt')
  final String createdAt;

  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  @JsonKey(name: 'leidaAt')
  final String? leidaAt;

  @JsonKey(name: 'archivadaAt')
  final String? archivadaAt;

  const NotificacionModel({
    required this.notificacionId,
    required this.clienteId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.prioridad,
    required this.estado,
    this.resolucionId,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.leidaAt,
    this.archivadaAt,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) =>
      _$NotificacionModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificacionModelToJson(this);
}

/// Modelo de data que contiene solo las notificaciones
@JsonSerializable()
class NotificacionesData {
  @JsonKey(name: 'notificaciones')
  final List<NotificacionModel> notificaciones;

  const NotificacionesData({
    required this.notificaciones,
  });

  factory NotificacionesData.fromJson(Map<String, dynamic> json) =>
      _$NotificacionesDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificacionesDataToJson(this);
}

/// Modelo de respuesta completa con paginación al mismo nivel que data
@JsonSerializable()
class NotificacionesListResponse {
  @JsonKey(name: 'data')
  final NotificacionesData data;

  @JsonKey(name: 'pagination')
  final PaginationModel? pagination;

  const NotificacionesListResponse({
    required this.data,
    this.pagination,
  });

  factory NotificacionesListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificacionesListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificacionesListResponseToJson(this);
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
