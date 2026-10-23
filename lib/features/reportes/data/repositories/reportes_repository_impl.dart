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
    String? nombreProducto,
    int? categoriaId,
    int? cajaId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getVentasReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        nombreProducto: nombreProducto,
        categoriaId: categoriaId,
        cajaId: cajaId,
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
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getVentaDetalleReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
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
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getInventarioReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
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
  }) async {
    try {
      return await _remoteDatasource.getArqueoReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        cajaId: cajaId,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<StockReporte> getStockReporte({
    required int clienteId,
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getStockReporte(
        clienteId: clienteId,
        activo: activo,
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
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      return await _remoteDatasource.getCostoBeneficioReporte(
        clienteId: clienteId,
        startDate: startDate,
        endDate: endDate,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
    } catch (e) {
      rethrow;
    }
  }
}
