import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../models/producto.dart';

/// Datasource para productos
class ProductoDatasource {
  final Dio _dio;

  ProductoDatasource(this._dio);

  /// Lista productos con paginación
  Future<ProductoResponse> getProductos({
    required int clienteId,
    int pageNumber = 1,
    int pageSize = 20,
    String? search,
    int? tipoProductoId,
  }) async {
    final queryParams = <String, dynamic>{
      'clienteId': clienteId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (tipoProductoId != null) {
      queryParams['tipoProductoId'] = tipoProductoId;
    }

    debugPrint('🌐 DATASOURCE enviando petición GET /products con params:');
    debugPrint('   $queryParams');

    final response = await _dio.get(
      ApiConstants.buildUrl('/products'),
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final productoResponse = ProductoResponse.fromJson(response.data);
      debugPrint('✅ Respuesta recibida: ${productoResponse.data.products.length} productos');
      return productoResponse;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener productos',
      );
    }
  }

  /// Busca productos por nombre
  Future<List<Producto>> searchProductos({
    required int clienteId,
    required String search,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('/products'),
      queryParameters: {
        'clienteId': clienteId,
        'search': search,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final ProductoData productoData = ProductoData.fromJson(response.data['data']);
      return productoData.products;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al buscar productos',
      );
    }
  }

  /// Obtiene un producto específico por ID
  Future<Producto> getProductoById({
    required int productoId,
    required int clienteId,
  }) async {
    debugPrint('🔍 DATASOURCE obteniendo producto ID: $productoId');

    final response = await _dio.get(
      ApiConstants.buildUrl('/products/$productoId'),
      queryParameters: {
        'clienteId': clienteId,
      },
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      final producto = Producto.fromJson(response.data['data']);
      debugPrint('✅ Producto obtenido: ${producto.nombre}');
      return producto;
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Error al obtener producto',
      );
    }
  }
}
