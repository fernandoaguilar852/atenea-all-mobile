import '../../../../core/datasources/consumidor_datasource.dart';
import '../../domain/entities/consumidor_entity.dart';
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
}
