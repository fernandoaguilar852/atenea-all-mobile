import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/ciudad.dart';
import '../models/departamento.dart';
import '../utils/text_utils.dart';

/// Datasource global de ubicación: departamentos y ciudades.
/// Son catálogos sin clienteId. Piden todas las páginas hasta completar la
/// lista (ej. Antioquia tiene 125 ciudades y el API entrega 100 por página).
class UbicacionDatasource {
  final Dio _dio;

  static const int _pageSize = 100;
  static const int _maxPaginas = 20; // Salvaguarda contra bucles infinitos

  UbicacionDatasource(this._dio);

  /// GET /departamentos - Lista completa, ordenada alfabéticamente
  Future<List<Departamento>> getDepartamentos() async {
    final todos = <Departamento>[];
    var pagina = 1;

    while (pagina <= _maxPaginas) {
      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.departamentos),
        queryParameters: {'pageSize': _pageSize, 'pageNumber': pagina},
      );

      final data = response.data['data'];
      if (response.statusCode != 200 || data is! List) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener departamentos',
        );
      }

      final lista = data
          .map((json) => Departamento.fromJson(json as Map<String, dynamic>))
          .toList();
      todos.addAll(lista);

      final hayMas = response.data['pagination']?['hasMoreElements'] == true;
      if (!hayMas || lista.isEmpty) break;
      pagina++;
    }

    todos.sort((a, b) =>
        normalizarTexto(a.nombre).compareTo(normalizarTexto(b.nombre)));
    return todos;
  }

  /// GET /ciudades/:id - Una ciudad por su id (trae su departamentoId)
  Future<Ciudad> getCiudadById(int ciudadId) async {
    final response = await _dio.get(
      ApiConstants.buildUrl('${ApiConstants.ciudades}/$ciudadId'),
    );

    final data = response.data['data'];
    if (response.statusCode == 200 && data is Map<String, dynamic>) {
      return Ciudad.fromJson(data);
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Error al obtener la ciudad',
    );
  }

  /// GET /ciudades?departamentoId= - Lista completa del departamento,
  /// ordenada alfabéticamente
  Future<List<Ciudad>> getCiudades({required int departamentoId}) async {
    final todas = <Ciudad>[];
    var pagina = 1;

    while (pagina <= _maxPaginas) {
      final response = await _dio.get(
        ApiConstants.buildUrl(ApiConstants.ciudades),
        queryParameters: {
          'departamentoId': departamentoId,
          'pageSize': _pageSize,
          'pageNumber': pagina,
        },
      );

      final data = response.data['data'];
      final ciudades = data is Map ? data['ciudades'] : null;
      if (response.statusCode != 200 || ciudades is! List) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Error al obtener ciudades',
        );
      }

      final lista = ciudades
          .map((json) => Ciudad.fromJson(json as Map<String, dynamic>))
          .toList();
      todas.addAll(lista);

      final hayMas = response.data['pagination']?['hasMoreElements'] == true;
      if (!hayMas || lista.isEmpty) break;
      pagina++;
    }

    todas.sort((a, b) =>
        normalizarTexto(a.nombre).compareTo(normalizarTexto(b.nombre)));
    return todas;
  }
}
