import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/movimiento_model.dart';

/// Datasource remoto para Movimientos de Inventario
/// Realiza las llamadas HTTP a la API
class MovimientosRemoteDatasource {
  final Dio _dio;

  MovimientosRemoteDatasource(this._dio);

  /// GET /movimientos-inventario - Lista movimientos con filtros
  Future<MovimientosResponse> getMovimientos({
    required int clienteId,
    int? productoId,
    int? proveedorId,
    String? tipo,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool includeDeleted = false,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (productoId != null) queryParams['productoId'] = productoId;
    if (proveedorId != null) queryParams['proveedorId'] = proveedorId;
    if (tipo != null) queryParams['tipo'] = tipo;
    if (includeDeleted) queryParams['includeDeleted'] = 'true';
    if (fechaDesde != null) {
      queryParams['fechaDesde'] = fechaDesde.toIso8601String().split('T')[0];
    }
    if (fechaHasta != null) {
      queryParams['fechaHasta'] = fechaHasta.toIso8601String().split('T')[0];
    }

    final response = await _dio.get(
      ApiConstants.buildUrl('/movimientos-inventario'),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return MovimientosResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener movimientos',
      );
    }
  }

  /// GET /movimientos-inventario/{id} - Obtiene un movimiento por ID
  Future<MovimientoSingleResponse> getMovimientoById({
    required int movimientoId,
    required int clienteId,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/movimientos-inventario/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return MovimientoSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener movimiento',
      );
    }
  }

  /// POST /movimientos-inventario - Crea un nuevo movimiento
  Future<MovimientoSingleResponse> createMovimiento({
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      ApiConstants.buildUrl('/movimientos-inventario'),
      data: data,
    );

    if (response.statusCode == 201 && response.data['data'] != null) {
      return MovimientoSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al crear movimiento',
      );
    }
  }

  /// PUT /movimientos-inventario/{id} - Actualiza un movimiento completo
  Future<MovimientoSingleResponse> updateMovimiento({
    required int movimientoId,
    required int clienteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.put(
      ApiConstants.buildUrl('/movimientos-inventario/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
      data: data,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return MovimientoSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al actualizar movimiento',
      );
    }
  }

  /// PATCH /movimientos-inventario/{id} - Actualiza un movimiento parcialmente
  Future<MovimientoSingleResponse> patchMovimiento({
    required int movimientoId,
    required int clienteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.patch(
      ApiConstants.buildUrl('/movimientos-inventario/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
      data: data,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return MovimientoSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al actualizar movimiento',
      );
    }
  }

  /// DELETE /movimientos-inventario/{id} - Elimina un movimiento (soft delete)
  Future<void> deleteMovimiento({
    required int movimientoId,
    required int clienteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.delete(
      ApiConstants.buildUrl('/movimientos-inventario/$movimientoId'),
      queryParameters: {'clienteId': clienteId},
      data: data,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al eliminar movimiento',
      );
    }
  }
}
