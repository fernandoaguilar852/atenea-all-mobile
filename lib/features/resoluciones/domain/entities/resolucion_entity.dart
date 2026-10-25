/// Entidad de dominio para Resolución de Facturación
class ResolucionEntity {
  final int resolucionId;
  final int clienteId;
  final String prefijo;
  final int numeroDesde;
  final int numeroHasta;
  final int numeroActual;
  final String numeroResolucion;
  final DateTime fechaResolucion;
  final DateTime fechaVencimiento;
  final bool activo;
  final DateTime createdAt;

  const ResolucionEntity({
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

  /// Verifica si la resolución está vencida
  bool get isVencida => fechaVencimiento.isBefore(DateTime.now());

  /// Verifica si está cerca del límite de numeración
  bool get isCercaLimite {
    final disponibles = numeroHasta - numeroActual;
    final total = numeroHasta - numeroDesde;
    return disponibles < (total * 0.1); // Menos del 10%
  }

  /// Obtiene el rango de números
  String get rangoNumeros => '$numeroDesde - $numeroHasta';

  /// Obtiene el progreso de uso (0.0 a 1.0)
  double get progreso {
    final usado = numeroActual - numeroDesde;
    final total = numeroHasta - numeroDesde;
    return total > 0 ? usado / total : 0.0;
  }
}

/// Paginación para listado de resoluciones
class ResolucionesPaginacion {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;
  final bool hasNext;
  final bool hasPrevious;

  const ResolucionesPaginacion({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.pageSize,
    required this.hasNext,
    required this.hasPrevious,
  });
}

/// Respuesta paginada de resoluciones
class ResolucionesListEntity {
  final List<ResolucionEntity> resoluciones;
  final ResolucionesPaginacion? pagination;

  const ResolucionesListEntity({
    required this.resoluciones,
    this.pagination,
  });
}
