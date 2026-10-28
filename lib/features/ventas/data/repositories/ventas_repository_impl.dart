import '../../domain/entities/venta_entity.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/ventas_remote_datasource.dart';
import '../mappers/venta_mapper.dart';

class VentasRepositoryImpl implements VentasRepository {
  final VentasRemoteDatasource _remoteDatasource;

  VentasRepositoryImpl(this._remoteDatasource);

  @override
  Future<({List<VentaEntity> ventas, int totalElements, bool hasMoreElements})>
      getVentas({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? estado,
    int? cajaId,
    int? consumidorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final response = await _remoteDatasource.getVentas(
      clienteId: clienteId,
      pageNumber: pageNumber,
      pageSize: pageSize,
      estado: estado,
      cajaId: cajaId,
      consumidorId: consumidorId,
      startDate: startDate,
      endDate: endDate,
    );

    final ventas = VentaMapper.toEntityList(response.data.ventas);
    final totalElements = response.pagination?.totalElement ?? 0;
    final hasMoreElements = response.pagination?.hasMoreElements ?? false;

    return (
      ventas: ventas,
      totalElements: totalElements,
      hasMoreElements: hasMoreElements,
    );
  }

  @override
  Future<VentaEntity> getVentaById({
    required int clienteId,
    required int ventaId,
  }) async {
    final response = await _remoteDatasource.getVentaById(
      clienteId: clienteId,
      ventaId: ventaId,
    );

    return VentaMapper.toEntity(response.data);
  }

  @override
  Future<VentaEntity> getVentaCompleta({
    required int clienteId,
    required int ventaId,
  }) async {
    final response = await _remoteDatasource.getVentaCompleta(
      clienteId: clienteId,
      ventaId: ventaId,
    );

    return VentaMapper.toEntity(response.data);
  }

  @override
  Future<VentaEntity> anularVenta({
    required int clienteId,
    required int ventaId,
    required int usuarioId,
    String? motivoAnulacion,
  }) async {
    final response = await _remoteDatasource.anularVenta(
      clienteId: clienteId,
      ventaId: ventaId,
      usuarioId: usuarioId,
      motivoAnulacion: motivoAnulacion,
    );

    return VentaMapper.toEntity(response.data);
  }
}
