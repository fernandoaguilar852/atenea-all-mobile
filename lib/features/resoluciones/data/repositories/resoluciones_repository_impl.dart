import '../../domain/entities/resolucion_entity.dart';
import '../../domain/repositories/resoluciones_repository.dart';
import '../datasources/resoluciones_remote_datasource.dart';
import '../mappers/resolucion_mapper.dart';

/// Implementación concreta del repositorio de Resoluciones
/// Usa el datasource y los mappers para convertir DTOs a Entities
class ResolucionesRepositoryImpl implements ResolucionesRepository {
  final ResolucionesRemoteDatasource _datasource;

  ResolucionesRepositoryImpl(this._datasource);

  @override
  Future<ResolucionesListEntity> getResoluciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    bool? activo,
  }) async {
    final response = await _datasource.getResoluciones(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      activo: activo,
    );

    return ResolucionMapper.toListEntity(response);
  }

  @override
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
  }) async {
    final data = {
      'prefijo': prefijo,
      'numeroDesde': numeroDesde,
      'numeroHasta': numeroHasta,
      'numeroActual': numeroActual,
      'numeroResolucion': numeroResolucion,
      'fechaResolucion': fechaResolucion.toIso8601String().split('T')[0],
      'fechaVencimiento': fechaVencimiento.toIso8601String().split('T')[0],
      'activo': activo,
    };

    final response = await _datasource.createResolucion(
      data: data,
      clienteId: clienteId,
    );

    return ResolucionMapper.toEntity(response.data);
  }

  @override
  Future<ResolucionEntity> updateResolucion({
    required int resolucionId,
    required int clienteId,
    required String prefijo,
    required int numeroHasta,
    required int numeroActual,
    required DateTime fechaVencimiento,
    required bool activo,
  }) async {
    final data = {
      'prefijo': prefijo,
      'numeroHasta': numeroHasta,
      'numeroActual': numeroActual,
      'fechaVencimiento': fechaVencimiento.toIso8601String().split('T')[0],
      'activo': activo,
    };

    final response = await _datasource.updateResolucion(
      resolucionId: resolucionId,
      clienteId: clienteId,
      data: data,
    );

    return ResolucionMapper.toEntity(response.data);
  }

  @override
  Future<void> deleteResolucion({
    required int resolucionId,
    required int clienteId,
  }) async {
    await _datasource.deleteResolucion(
      resolucionId: resolucionId,
      clienteId: clienteId,
    );
  }
}
