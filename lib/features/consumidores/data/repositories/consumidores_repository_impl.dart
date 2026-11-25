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
  Future<ConsumidorEntity> getConsumidor({
    required int clienteId,
    required int consumidorId,
  }) async {
    final consumidor = await _datasource.getConsumidorById(
      clienteId: clienteId,
      consumidorId: consumidorId,
    );

    return ConsumidorMapper.toEntity(consumidor);
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
  Future<ConsumidorEntity> actualizarConsumidor({
    required int clienteId,
    required int consumidorId,
    required NuevoConsumidor consumidor,
  }) async {
    final actualizado = await _datasource.updateConsumidor(
      clienteId: clienteId,
      consumidorId: consumidorId,
      data: _datosConsumidor(clienteId, consumidor, esActualizacion: true),
    );

    return ConsumidorMapper.toEntity(actualizado);
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

  /// Cuerpo del consumidor (sirve para crear y para actualizar).
  ///
  /// Al CREAR, los campos opcionales solo se envían si tienen contenido y se
  /// incluye el clienteId. Al ACTUALIZAR (PATCH) no va el clienteId (ya está en
  /// el query) y un campo opcional vacío se envía como null para limpiarlo,
  /// porque omitirlo lo dejaría con su valor anterior.
  Map<String, dynamic> _datosConsumidor(
    int clienteId,
    NuevoConsumidor c, {
    bool esActualizacion = false,
  }) {
    final data = <String, dynamic>{};

    void opcional(String clave, String? valor) {
      final texto = valor?.trim() ?? '';
      if (texto.isNotEmpty) {
        data[clave] = texto;
      } else if (esActualizacion) {
        data[clave] = null;
      }
    }

    if (!esActualizacion) data['clienteId'] = clienteId;
    data['tipoIdentificacion'] = c.tipoIdentificacion;
    data['numeroIdentificacion'] = c.numeroIdentificacion.trim();
    opcional('digitoVerificacion', c.digitoVerificacion);
    data['nombreRazonSocial'] = c.nombreRazonSocial.trim();
    opcional('direccion', c.direccion);
    opcional('email', c.email);
    opcional('telefono', c.telefono);
    data['ciudadId'] = c.ciudadId;
    data['activo'] = c.activo;

    return data;
  }
}
