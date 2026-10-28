import '../entities/venta_entity.dart';

abstract class VentasRepository {
  /// Obtiene listado de ventas con paginación y filtros
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
  });

  /// Obtiene una venta por ID
  Future<VentaEntity> getVentaById({
    required int clienteId,
    required int ventaId,
  });

  /// Obtiene una venta completa con detalles
  Future<VentaEntity> getVentaCompleta({
    required int clienteId,
    required int ventaId,
  });

  /// Anula una venta
  Future<VentaEntity> anularVenta({
    required int clienteId,
    required int ventaId,
    required int usuarioId,
    String? motivoAnulacion,
  });
}
