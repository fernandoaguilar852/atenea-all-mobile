import '../entities/consumidor_entity.dart';
import '../entities/nuevo_consumidor_entity.dart';

/// Contrato del repositorio de Consumidores
abstract class ConsumidoresRepository {
  /// Lista consumidores con paginación y filtros (búsqueda y estado activo)
  Future<ConsumidoresListEntity> getConsumidores({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    bool? activo,
  });

  /// Obtiene un consumidor por su id (detalle)
  Future<ConsumidorEntity> getConsumidor({
    required int clienteId,
    required int consumidorId,
  });

  /// Crea un consumidor y devuelve el creado
  Future<ConsumidorEntity> crearConsumidor({
    required int clienteId,
    required NuevoConsumidor consumidor,
  });

  /// Actualiza un consumidor existente y devuelve el actualizado
  Future<ConsumidorEntity> actualizarConsumidor({
    required int clienteId,
    required int consumidorId,
    required NuevoConsumidor consumidor,
  });

  /// Elimina un consumidor
  Future<void> eliminarConsumidor({
    required int clienteId,
    required int consumidorId,
  });
}
