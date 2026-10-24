import '../models/inventario_reporte.dart';
import '../../domain/entities/inventario_entity.dart';
import 'common_mappers.dart';

extension InventarioReporteMapper on InventarioReporte {
  InventarioEntity toEntity() {
    return InventarioEntity(
      encabezado: encabezado.toEntity(),
      productos: productos.map((item) => item.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination?.toEntity(),
    );
  }
}

extension InventarioRowMapper on InventarioRow {
  InventarioRowEntity toEntity() {
    return InventarioRowEntity(
      productoId: productoId,
      nombreProducto: nombreProducto,
      cantidadConsumida: cantidadConsumida,
      unidadMedida: unidadMedida,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      necesitaReposicion: necesitaReposicion,
      numeroMovimientos: numeroMovimientos,
    );
  }
}

extension InventarioResumenMapper on InventarioResumen {
  InventarioResumenEntity toEntity() {
    return InventarioResumenEntity(
      totalProductos: totalProductos,
      totalMovimientos: totalMovimientos,
      productosConStockBajo: productosConStockBajo,
    );
  }
}
