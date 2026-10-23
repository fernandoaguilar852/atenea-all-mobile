import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/arqueo_reporte.dart';
import '../models/costo_beneficio_reporte.dart';
import '../models/inventario_reporte.dart';
import '../models/stock_reporte.dart';
import '../models/venta_detalle_reporte.dart';
import '../models/ventas_reporte.dart';

/// Datasource remoto para reportes
/// Maneja todas las llamadas HTTP a la API
class ReportesRemoteDatasource {
  final Dio _dio;

  ReportesRemoteDatasource(this._dio);

  /// Obtiene reporte de ventas desde el API
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
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (nombreProducto != null && nombreProducto.isNotEmpty) {
      queryParams['nombreProducto'] = nombreProducto;
    }
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId;
    }
    if (cajaId != null) {
      queryParams['cajaId'] = cajaId;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteVentas),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return VentasReporte.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener reporte de ventas',
      );
    }
  }

  /// Obtiene reporte de venta detallada desde el API
  Future<VentaDetalleReporte> getVentaDetalleReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteVentaDetalle),
      queryParameters: {
        'clienteId': clienteId,
        'startDate': startDate,
        'endDate': endDate,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return VentaDetalleReporte.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener reporte de venta detallada',
      );
    }
  }

  /// Obtiene reporte de inventario consumido desde el API
  Future<InventarioReporte> getInventarioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteInventarioConsumido),
      queryParameters: {
        'clienteId': clienteId,
        'startDate': startDate,
        'endDate': endDate,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return InventarioReporte.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener reporte de inventario',
      );
    }
  }

  /// Obtiene reporte de arqueo de caja desde el API
  Future<ArqueoReporte> getArqueoReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int? cajaId,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
    };

    if (cajaId != null) {
      queryParams['cajaId'] = cajaId;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteArqueoCaja),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return ArqueoReporte.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener arqueo de caja',
      );
    }
  }

  /// Obtiene reporte de stock de productos desde el API
  Future<StockReporte> getStockReporte({
    required int clienteId,
    bool? activo,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (activo != null) {
      queryParams['activo'] = activo;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteStockProductos),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return StockReporte.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener reporte de stock',
      );
    }
  }

  /// Obtiene reporte de costo-beneficio desde el API
  Future<CostoBeneficioReporte> getCostoBeneficioReporte({
    required int clienteId,
    required String startDate,
    required String endDate,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteCostoBeneficio),
      queryParameters: {
        'clienteId': clienteId,
        'startDate': startDate,
        'endDate': endDate,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return CostoBeneficioReporte.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener reporte de costo-beneficio',
      );
    }
  }
}
