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
    int? productoId,
    String? nombreProducto,
    int? consumidorId,
    int? categoriaId,
    int? cajaId,
    bool? incluirAnuladas,
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

    if (productoId != null) {
      queryParams['productoId'] = productoId;
    }
    if (nombreProducto != null && nombreProducto.isNotEmpty) {
      queryParams['nombreProducto'] = nombreProducto;
    }
    if (consumidorId != null) {
      queryParams['consumidorId'] = consumidorId;
    }
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId;
    }
    if (cajaId != null) {
      queryParams['cajaId'] = cajaId;
    }
    if (incluirAnuladas != null) {
      queryParams['incluirAnuladas'] = incluirAnuladas;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteVentas),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final dataWithPagination = <String, dynamic>{
        ...response.data['data'] as Map<String, dynamic>,
        if (response.data['pagination'] != null)
          'pagination': response.data['pagination'],
      };
      return VentasReporte.fromJson(dataWithPagination);
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
    String? startDate,
    String? endDate,
    int? consumidorId,
    String? estado,
    int? productoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (consumidorId != null) {
      queryParams['consumidorId'] = consumidorId;
    }
    if (estado != null && estado.isNotEmpty) {
      queryParams['estado'] = estado;
    }
    if (productoId != null) {
      queryParams['productoId'] = productoId;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteVentaDetalle),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final dataWithPagination = <String, dynamic>{
        ...response.data['data'] as Map<String, dynamic>,
        if (response.data['pagination'] != null)
          'pagination': response.data['pagination'],
      };
      return VentaDetalleReporte.fromJson(dataWithPagination);
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
    int? productoId,
    String? tipoMovimiento,
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

    if (productoId != null) {
      queryParams['productoId'] = productoId;
    }
    if (tipoMovimiento != null && tipoMovimiento.isNotEmpty) {
      queryParams['tipoMovimiento'] = tipoMovimiento;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteInventarioConsumido),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final dataWithPagination = <String, dynamic>{
        ...response.data['data'] as Map<String, dynamic>,
        if (response.data['pagination'] != null)
          'pagination': response.data['pagination'],
      };
      return InventarioReporte.fromJson(dataWithPagination);
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
    String? tipoPago,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'startDate': startDate,
      'endDate': endDate,
    };

    if (cajaId != null) {
      queryParams['cajaId'] = cajaId;
    }
    if (tipoPago != null && tipoPago.isNotEmpty) {
      queryParams['tipoPago'] = tipoPago;
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
    String? nombreProducto,
    bool? stockBajo,
    bool? activo,
    int? tipoProductoId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (nombreProducto != null && nombreProducto.isNotEmpty) {
      queryParams['nombreProducto'] = nombreProducto;
    }
    if (stockBajo != null) {
      queryParams['stockBajo'] = stockBajo;
    }
    if (activo != null) {
      queryParams['activo'] = activo;
    }
    if (tipoProductoId != null) {
      queryParams['tipoProductoId'] = tipoProductoId;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteStockProductos),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final dataWithPagination = <String, dynamic>{
        ...response.data['data'] as Map<String, dynamic>,
        if (response.data['pagination'] != null)
          'pagination': response.data['pagination'],
      };
      return StockReporte.fromJson(dataWithPagination);
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
    int? productoId,
    int? categoriaId,
    bool? activo,
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

    if (productoId != null) {
      queryParams['productoId'] = productoId;
    }
    if (categoriaId != null) {
      queryParams['categoriaId'] = categoriaId;
    }
    if (activo != null) {
      queryParams['activo'] = activo;
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.reporteCostoBeneficio),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final dataWithPagination = <String, dynamic>{
        ...response.data['data'] as Map<String, dynamic>,
        if (response.data['pagination'] != null)
          'pagination': response.data['pagination'],
      };
      return CostoBeneficioReporte.fromJson(dataWithPagination);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener reporte de costo-beneficio',
      );
    }
  }
}
