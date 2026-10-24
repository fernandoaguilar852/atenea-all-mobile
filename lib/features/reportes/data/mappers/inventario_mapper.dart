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
      codigoBarras: codigoBarras,
      nombreProducto: nombreProducto,
      categoriaId: categoriaId,
      nombreCategoria: nombreCategoria,
      cantidadConsumida: cantidadConsumida,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      necesitaReposicion: necesitaReposicion,
      costoUnitario: costoUnitario,
      costoTotal: costoTotal,
    );
  }
}

extension InventarioResumenMapper on InventarioResumen {
  InventarioResumenEntity toEntity() {
    return InventarioResumenEntity(
      totalProductos: totalProductos,
      totalCantidadConsumida: totalCantidadConsumida,
      costoTotalInventario: costoTotalInventario,
      productosConStockBajo: productosConStockBajo,
    );
  }
}
