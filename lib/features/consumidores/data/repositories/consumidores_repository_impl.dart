import '../../../../core/datasources/consumidor_datasource.dart';
import '../../domain/entities/consumidor_entity.dart';
import '../../domain/entities/nuevo_consumidor_entity.dart';
import '../../domain/repositories/consumidores_repository.dart';
import '../mappers/consumidor_mapper.dart';

/// Implementación concreta del repositorio de Consumidores.
/// Usa el datasource global de core y el mapper para convertir a Entities.
class ConsumidoresRepositoryImpl implements ConsumidoresRepository {
  final ConsumidorDatasource _datasource;

  ConsumidoresRepositoryImpl(this._datasource);

  @override
  Future<ConsumidoresListEntity> getConsumidores({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    bool? activo,
  }) async {
    final response = await _datasource.getConsumidores(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      search: search,
      activo: activo,
    );

    return ConsumidorMapper.toListEntity(response);
  }

  @override
  Future<ConsumidorEntity> crearConsumidor({
    required int clienteId,
    required NuevoConsumidor consumidor,
  }) async {
    final creado = await _datasource.createConsumidor(
      clienteId: clienteId,
      data: _datosConsumidor(clienteId, consumidor),
    );

    return ConsumidorMapper.toEntity(creado);
  }

  @override
  Future<void> eliminarConsumidor({
    required int clienteId,
    required int consumidorId,
  }) async {
    await _datasource.deleteConsumidor(
      clienteId: clienteId,
      consumidorId: consumidorId,
    );
  }

  /// Cuerpo del consumidor (sirve para crear y, más adelante, actualizar).
  /// Los campos opcionales solo se envían si tienen contenido.
  Map<String, dynamic> _datosConsumidor(int clienteId, NuevoConsumidor c) {
    bool hayTexto(String? v) => v != null && v.trim().isNotEmpty;

    return <String, dynamic>{
      'clienteId': clienteId,
      'tipoIdentificacion': c.tipoIdentificacion,
      'numeroIdentificacion': c.numeroIdentificacion.trim(),
      if (hayTexto(c.digitoVerificacion))
        'digitoVerificacion': c.digitoVerificacion!.trim(),
      'nombreRazonSocial': c.nombreRazonSocial.trim(),
      if (hayTexto(c.direccion)) 'direccion': c.direccion!.trim(),
      if (hayTexto(c.email)) 'email': c.email!.trim(),
      if (hayTexto(c.telefono)) 'telefono': c.telefono!.trim(),
      'ciudadId': c.ciudadId,
      'activo': c.activo,
    };
  }
}
