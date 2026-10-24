import '../../domain/repositories/reportes_repository.dart';
import '../../domain/entities/arqueo_entity.dart';
import '../../domain/entities/costo_beneficio_entity.dart';
import '../../domain/entities/inventario_entity.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/venta_detalle_entity.dart';
import '../../domain/entities/ventas_entity.dart';
import '../datasources/reportes_remote_datasource.dart';
import '../mappers/arqueo_mapper.dart';
import '../mappers/costo_beneficio_mapper.dart';
import '../mappers/inventario_mapper.dart';
import '../mappers/stock_mapper.dart';
import '../mappers/venta_detalle_mapper.dart';
import '../mappers/ventas_mapper.dart';

/// Implementación del repositorio de reportes
/// Coordina el acceso a datos desde datasources
class ReportesRepositoryImpl implements ReportesRepository {
  final ReportesRemoteDatasource _remoteDatasource;

  ReportesRepositoryImpl(this._remoteDatasource);

  @override
  Future<VentasEntity> getVentasReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    String? nombreProducto,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    bool? incluirAnuladas,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final dto = await _remoteDatasource.getVentasReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        nombreProducto: nombreProducto,
        consumidorId: consumidorId,
        categoriaId: categoriaId,
        cajaId: cajaId,
        incluirAnuladas: incluirAnuladas,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<VentaDetalleEntity> getVentaDetalleReporte({
    required int clienteId,
    String? startDate,
    String? endDate,
    int? consumidorId,
    String? estado,
    int? productoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final dto = await _remoteDatasource.getVentaDetalleReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        consumidorId: consumidorId,
        estado: estado,
        productoId: productoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InventarioEntity> getInventarioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    String? tipoMovimiento,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final dto = await _remoteDatasource.getInventarioReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        tipoMovimiento: tipoMovimiento,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ArqueoEntity> getArqueoReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? cajaId,
    String? tipoPago,
  }) async {
    try {
      final dto = await _remoteDatasource.getArqueoReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        cajaId: cajaId,
        tipoPago: tipoPago,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockEntity> getStockReporte({
    required int clienteId,
    String? nombreProducto,
    bool? stockBajo,
    bool? activo,
    int? tipoProductoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final dto = await _remoteDatasource.getStockReporte(
        clienteId: clienteId,
        nombreProducto: nombreProducto,
        stockBajo: stockBajo,
        activo: activo,
        tipoProductoId: tipoProductoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CostoBeneficioEntity> getCostoBeneficioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    int? categoriaId,
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final dto = await _remoteDatasource.getCostoBeneficioReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        categoriaId: categoriaId,
        activo: activo,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
