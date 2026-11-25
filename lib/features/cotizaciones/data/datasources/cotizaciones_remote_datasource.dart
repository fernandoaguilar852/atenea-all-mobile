import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../models/cotizacion_detalle_creado_model.dart';
import '../models/cotizacion_detalle_model.dart';
import '../models/cotizacion_impresion_model.dart';
import '../models/cotizacion_model.dart';

/// Datasource remoto para Cotizaciones
/// Realiza las llamadas HTTP a la API
class CotizacionesRemoteDatasource {
  final Dio _dio;

  CotizacionesRemoteDatasource(this._dio);

  /// Formatea una fecha como yyyy-MM-dd
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// GET /cotizaciones - Lista cotizaciones con paginación y filtros
  Future<CotizacionesResponse> getCotizaciones({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 10,
    String? search,
    String origen = CotizacionOrigen.defaultOrigen,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'origen': origen,
    };

    // Solo se envía el filtro de búsqueda si tiene contenido
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    // Las fechas se envían como yyyy-MM-dd y solo si tienen valor
    if (startDate != null) {
      queryParams['startDate'] = _formatDate(startDate);
    }
    if (endDate != null) {
      queryParams['endDate'] = _formatDate(endDate);
    }

    final response = await _dio.get(
      ApiConstants.buildUrl(ApiConstants.cotizaciones),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return CotizacionesResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener cotizaciones',
      );
    }
  }

  /// GET /cotizaciones/:id/detalles - Obtiene una cotización con sus detalles
  Future<CotizacionDetalleResponse> getCotizacionDetalle({
    required int clienteId,
    required int cotizacionId,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('${ApiConstants.cotizaciones}/$cotizacionId/detalles'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return CotizacionDetalleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener el detalle de la cotización',
      );
    }
  }

  /// GET /cotizaciones/:id/impresion - Datos para generar el PDF de la cotización
  Future<CotizacionImpresionResponse> getCotizacionImpresion({
    required int clienteId,
    required int cotizacionId,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('${ApiConstants.cotizaciones}/$cotizacionId/impresion'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return CotizacionImpresionResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener los datos de impresión de la cotización',
      );
    }
  }

  /// POST /cotizaciones - Crea la cabecera de una cotización
  /// La respuesta tiene la misma forma que el detalle (sin líneas)
  Future<CotizacionDetalleResponse> createCotizacion({
    required int clienteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      ApiConstants.buildUrl(ApiConstants.cotizaciones),
      queryParameters: {'clienteId': clienteId},
      data: data,
    );

    if (response.statusCode == 201 && response.data['data'] != null) {
      return CotizacionDetalleResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al crear la cotización',
      );
    }
  }

  /// POST /cotizacion-detalles - Crea UNA línea de una cotización existente
  Future<CotizacionDetalleCreadoResponse> createCotizacionDetalle({
    required int clienteId,
    required Map<String, dynamic> data,
  }) async {
    final response = await _dio.post(
      ApiConstants.buildUrl(ApiConstants.cotizacionDetalles),
      queryParameters: {'clienteId': clienteId},
      data: data,
    );

    if (response.statusCode == 201 && response.data['data'] != null) {
      return CotizacionDetalleCreadoResponse.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al crear el detalle de la cotización',
      );
    }
  }

  /// DELETE /cotizaciones/:id - Elimina una cotización
  Future<void> deleteCotizacion({
    required int clienteId,
    required int cotizacionId,
  }) async {
    final response = await _dio.delete(
      ApiConstants.buildUrl('${ApiConstants.cotizaciones}/$cotizacionId'),
      queryParameters: {'clienteId': clienteId},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al eliminar la cotización',
      );
    }

    // La API responde data.deleted = true cuando se eliminó
    final body = response.data;
    if (body is Map && body['data'] is Map && body['data']['deleted'] == false) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'No se pudo eliminar la cotización',
      );
    }
  }
}
