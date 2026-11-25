/// Valores válidos del filtro de origen de una cotización
class CotizacionOrigen {
  CotizacionOrigen._();

  static const String posInterno = 'POS-INTERNO';
  static const String webPublica = 'WEB-PUBLICA';

  /// Origen por defecto cuando no se elige ninguno
  static const String defaultOrigen = posInterno;
}

/// Entidad de dominio para Cotización
class CotizacionEntity {
  final int cotizacionId;
  final int clienteId;
  final String numeroCotizacion;
  final String consumidorNombre;
  final String? consumidorIdentificacion;
  final String? consumidorEmail;
  final String? consumidorTelefono;
  final DateTime fechaCotizacion;
  final DateTime fechaValidez;
  final int diasValidez;
  final bool estaVencida;
  final double total;
  final DateTime createdAt;

  const CotizacionEntity({
    required this.cotizacionId,
    required this.clienteId,
    required this.numeroCotizacion,
    required this.consumidorNombre,
    this.consumidorIdentificacion,
    this.consumidorEmail,
    this.consumidorTelefono,
    required this.fechaCotizacion,
    required this.fechaValidez,
    required this.diasValidez,
    required this.estaVencida,
    required this.total,
    required this.createdAt,
  });
}

/// Paginación para listado de cotizaciones
class CotizacionesPaginacion {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const CotizacionesPaginacion({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Respuesta paginada de cotizaciones
class CotizacionesListEntity {
  final List<CotizacionEntity> cotizaciones;
  final CotizacionesPaginacion? pagination;

  const CotizacionesListEntity({
    required this.cotizaciones,
    this.pagination,
  });
}
