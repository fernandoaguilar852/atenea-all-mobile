import '../entities/consumidor_entity.dart';

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
}
