import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/producto.dart';

/// Datasource para operaciones de escritura de productos (Create, Update, Delete)
class ProductoWriteDatasource {
  final Dio _dio;

  ProductoWriteDatasource(this._dio);

  /// Crea un nuevo producto
  Future<Producto> createProducto({
    required int clienteId,
    required int tipoProductoId,
    required String nombre,
    String? codExterno,
    String? codBarras,
    required double precio,
    required String unidadMedida,
    required double stockTotal,
    required double stockMinimo,
    required bool manejaStock,
    required int ivaId,
  }) async {
    final requestBody = {
      'clienteId': clienteId,
      'tipoProductoId': tipoProductoId,
      'nombre': nombre,
      if (codExterno != null && codExterno.isNotEmpty) 'codExterno': codExterno,
      if (codBarras != null && codBarras.isNotEmpty) 'codBarras': codBarras,
      'precio': precio,
      'unidadMedida': unidadMedida,
      'stockTotal': stockTotal,
      'stockMinimo': stockMinimo,
      'manejaStock': manejaStock,
      'ivaId': ivaId,
    };

    final response = await _dio.post(
      ApiConstants.buildUrl('/products'),
      data: requestBody,
    );

    if (response.statusCode == 201 && response.data['data'] != null) {
      return Producto.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['messageResponse']?['responseMessage'] ?? 'Error al crear producto',
      );
    }
  }

  /// Actualiza un producto existente
  Future<Producto> updateProducto({
    required int productoId,
    required int clienteId,
    required int tipoProductoId,
    required String nombre,
    String? codExterno,
    String? codBarras,
    required double precio,
    required String unidadMedida,
    required double stockTotal,
    required double stockMinimo,
    required bool manejaStock,
    required int ivaId,
    required bool activo,
  }) async {
    final requestBody = {
      'clienteId': clienteId,
      'tipoProductoId': tipoProductoId,
      'nombre': nombre,
      if (codExterno != null && codExterno.isNotEmpty) 'codExterno': codExterno,
      if (codBarras != null && codBarras.isNotEmpty) 'codBarras': codBarras,
      'precio': precio,
      'unidadMedida': unidadMedida,
      'stockTotal': stockTotal,
      'stockMinimo': stockMinimo,
      'manejaStock': manejaStock,
      'ivaId': ivaId,
      'activo': activo,
    };

    final response = await _dio.put(
      ApiConstants.buildUrl('/products/$productoId'),
      data: requestBody,
    );

    if (response.statusCode == 200 && response.data['data'] != null) {
      return Producto.fromJson(response.data['data']);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['messageResponse']?['responseMessage'] ?? 'Error al actualizar producto',
      );
    }
  }

  /// Elimina un producto (soft delete)
  Future<void> deleteProducto({
    required int productoId,
  }) async {
    final response = await _dio.delete(
      ApiConstants.buildUrl('/products/$productoId'),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: response.data['messageResponse']?['responseMessage'] ?? 'Error al eliminar producto',
      );
    }
  }
}
