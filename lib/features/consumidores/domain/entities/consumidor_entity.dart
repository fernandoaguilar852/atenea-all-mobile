/// Entidad de dominio para Consumidor (cliente del negocio)
class ConsumidorEntity {
  final int consumidorId;
  final int clienteId;
  final String tipoIdentificacion;
  final String numeroIdentificacion;
  final String? digitoVerificacion;
  final String nombreRazonSocial;
  final String? direccion;
  final String? email;
  final String? telefono;
  final int? ciudadId;
  final bool activo;
  final DateTime creadoEn;

  const ConsumidorEntity({
    required this.consumidorId,
    required this.clienteId,
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    this.digitoVerificacion,
    required this.nombreRazonSocial,
    this.direccion,
    this.email,
    this.telefono,
    this.ciudadId,
    required this.activo,
    required this.creadoEn,
  });

  /// Número de identificación con su dígito de verificación si lo tiene
  /// (ej. "860024041-6" para un NIT); si no, solo el número.
  String get identificacionCompleta {
    final dv = digitoVerificacion;
    return (dv != null && dv.isNotEmpty)
        ? '$numeroIdentificacion-$dv'
        : numeroIdentificacion;
  }
}

/// Paginación para listado de consumidores
class ConsumidoresPaginacion {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const ConsumidoresPaginacion({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Respuesta paginada de consumidores
class ConsumidoresListEntity {
  final List<ConsumidorEntity> consumidores;
  final ConsumidoresPaginacion? pagination;

  const ConsumidoresListEntity({
    required this.consumidores,
    this.pagination,
  });
}
