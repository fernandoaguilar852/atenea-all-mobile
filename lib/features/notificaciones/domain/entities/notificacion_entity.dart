/// Entidad de dominio para Notificación
class NotificacionEntity {
  final int notificacionId;
  final int clienteId;
  final String tipo; // 'RESOLUCION_VENCIMIENTO', 'NUMERACION_BAJA'
  final String titulo;
  final String mensaje;
  final String prioridad; // 'BAJA', 'MEDIA', 'ALTA', 'CRITICA'
  final String estado; // 'PENDIENTE', 'LEIDA', 'ARCHIVADA'
  final int? resolucionId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? leidaAt;
  final DateTime? archivadaAt;

  const NotificacionEntity({
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
}
