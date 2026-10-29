import '../entities/resolucion_entity.dart';

/// Repositorio abstracto para Resoluciones
/// Define los contratos que debe cumplir la implementación
abstract class ResolucionesRepository {
  /// GET /resoluciones - Lista resoluciones con paginación
  Future<ResolucionesListEntity> getResoluciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    bool? activo,
  });

  /// POST /resoluciones - Crea una nueva resolución
  Future<ResolucionEntity> createResolucion({
    required int clienteId,
    required String prefijo,
    required int numeroDesde,
    required int numeroHasta,
    required int numeroActual,
    required String numeroResolucion,
    required DateTime fechaResolucion,
    required DateTime fechaVencimiento,
    required bool activo,
  });

  /// PATCH /resoluciones/:id - Actualiza una resolución
  Future<ResolucionEntity> updateResolucion({
    required int resolucionId,
    required int clienteId,
    required String prefijo,
    required int numeroHasta,
    required int numeroActual,
    required DateTime fechaVencimiento,
    required bool activo,
  });

  /// DELETE /resoluciones/:id - Elimina una resolución
  Future<void> deleteResolucion({
    required int resolucionId,
    required int clienteId,
  });
}
