import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/venta_model.dart';

/// Datasource remoto para Ventas (Facturas)
/// Realiza las llamadas HTTP a la API
class VentasRemoteDatasource {
  final Dio _dio;

  VentasRemoteDatasource(this._dio);

  /// GET /v1/pos/ventas - Lista ventas con filtros
  Future<VentasResponse> getVentas({
    required int clienteId,
    required int pageNumber,
    required int pageSize,
    String? estado,
    int? cajaId,
    int? consumidorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (estado != null) queryParams['estado'] = estado;
    if (cajaId != null) queryParams['cajaId'] = cajaId;
    if (consumidorId != null) queryParams['consumidorId'] = consumidorId;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
    }

    try {
      final response = await _dio.get(
        ApiConstants.buildUrl('/ventas'),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return VentasResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener ventas: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        message: 'Error al obtener ventas: ${e.response?.statusCode ?? "Sin conexión"} - ${e.message}',
      );
    }
  }

  /// GET /v1/pos/ventas/{id} - Obtiene una venta por ID
  Future<VentaSingleResponse> getVentaById({
    required int clienteId,
    required int ventaId,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/ventas/$ventaId'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return VentaSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener venta',
      );
    }
  }

  /// GET /v1/pos/ventas/{id}/completa - Obtiene una venta completa con detalles
  Future<VentaSingleResponse> getVentaCompleta({
    required int clienteId,
    required int ventaId,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/ventas/$ventaId/completa'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return VentaSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener venta completa',
      );
    }
  }

  /// PATCH /v1/pos/ventas/{id}/anular - Anula una venta
  Future<VentaSingleResponse> anularVenta({
    required int clienteId,
    required int ventaId,
    required int usuarioId,
    String? motivoAnulacion,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'usuarioId': usuarioId,
    };

    final body = <String, dynamic>{};
    if (motivoAnulacion != null) {
      body['motivoAnulacion'] = motivoAnulacion;
    }

    final response = await _dio.patch(
      ApiConstants.buildUrl('/ventas/$ventaId/anular'),
      queryParameters: queryParams,
      data: body,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return VentaSingleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al anular venta',
      );
    }
  }
}
