import '../models/stock_reporte.dart';
import '../../domain/entities/stock_entity.dart';
import 'common_mappers.dart';

extension StockReporteMapper on StockReporte {
  StockEntity toEntity() {
    return StockEntity(
      encabezado: encabezado.toEntity(),
      productos: productos.map((item) => item.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination?.toEntity(),
    );
  }
}

extension StockRowMapper on StockRow {
  StockRowEntity toEntity() {
    return StockRowEntity(
      productoId: productoId,
      codigoBarras: codigoBarras,
      nombreProducto: nombreProducto,
      categoriaId: categoriaId,
      nombreCategoria: nombreCategoria,
      stockActual: stockActual,
      stockMinimo: stockMinimo,
      stockMaximo: stockMaximo,
      necesitaReposicion: necesitaReposicion,
      activo: activo,
      precioVenta: precioVenta,
      costoUnitario: costoUnitario,
      valorInventario: valorInventario,
    );
  }
}

extension StockResumenMapper on StockResumen {
  StockResumenEntity toEntity() {
    return StockResumenEntity(
      totalProductos: totalProductos,
      productosActivos: productosActivos,
      productosInactivos: productosInactivos,
      productosConStockBajo: productosConStockBajo,
      productosAgotados: productosAgotados,
      valorTotalInventario: valorTotalInventario,
    );
  }
}
