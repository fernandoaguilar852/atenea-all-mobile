import '../../domain/repositories/reportes_repository.dart';
import '../datasources/reportes_remote_datasource.dart';
import '../models/arqueo_reporte.dart';
import '../models/costo_beneficio_reporte.dart';
import '../models/inventario_reporte.dart';
import '../models/stock_reporte.dart';
import '../models/venta_detalle_reporte.dart';
import '../models/ventas_reporte.dart';

/// Implementación del repositorio de reportes
/// Coordina el acceso a datos desde datasources
class ReportesRepositoryImpl implements ReportesRepository {
  final ReportesRemoteDatasource _remoteDatasource;

  ReportesRepositoryImpl(this._remoteDatasource);

  @override
  Future<VentasReporte> getVentasReporte({
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
      return await _remoteDatasource.getVentasReporte(
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<VentaDetalleReporte> getVentaDetalleReporte({
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
      return await _remoteDatasource.getVentaDetalleReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        consumidorId: consumidorId,
        estado: estado,
        productoId: productoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<InventarioReporte> getInventarioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? productoId,
    String? tipoMovimiento,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getInventarioReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        tipoMovimiento: tipoMovimiento,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ArqueoReporte> getArqueoReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? cajaId,
    String? tipoPago,
  }) async {
    try {
      return await _remoteDatasource.getArqueoReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        cajaId: cajaId,
        tipoPago: tipoPago,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockReporte> getStockReporte({
    required int clienteId,
    String? nombreProducto,
    bool? stockBajo,
    bool? activo,
    int? tipoProductoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getStockReporte(
        clienteId: clienteId,
        nombreProducto: nombreProducto,
        stockBajo: stockBajo,
        activo: activo,
        tipoProductoId: tipoProductoId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CostoBeneficioReporte> getCostoBeneficioReporte({
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
      return await _remoteDatasource.getCostoBeneficioReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        productoId: productoId,
        categoriaId: categoriaId,
        activo: activo,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }
}
