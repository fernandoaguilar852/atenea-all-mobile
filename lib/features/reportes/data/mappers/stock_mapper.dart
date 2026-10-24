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
      nombreProducto: nombreProducto,
      codigoBarras: codigoBarras,
      unidadMedida: unidadMedida,
      stockActual: stockActual,
      stockDisponible: stockDisponible,
      stockMinimo: stockMinimo,
      necesitaReposicion: necesitaReposicion,
      precioVenta: precioVenta,
      activo: activo,
    );
  }
}

extension StockResumenMapper on StockResumen {
  StockResumenEntity toEntity() {
    return StockResumenEntity(
      totalProductos: totalProductos,
      productosConStockBajo: productosConStockBajo,
      valorTotalInventario: valorTotalInventario,
    );
  }
}
