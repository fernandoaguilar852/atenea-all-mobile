import '../models/ventas_reporte.dart';
import '../../domain/entities/ventas_entity.dart';
import 'common_mappers.dart';

extension VentasReporteMapper on VentasReporte {
  VentasEntity toEntity() {
    return VentasEntity(
      encabezado: encabezado.toEntity(),
      reporteVentas: reporteVentas.map((item) => item.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination?.toEntity(),
    );
  }
}

extension VentaRowMapper on VentaRow {
  VentaRowEntity toEntity() {
    return VentaRowEntity(
      productoId: productoId,
      codigoBarras: codigoBarras,
      nombreProducto: nombreProducto,
      categoriaId: categoriaId,
      nombreCategoria: nombreCategoria,
      precioVentaUnitario: precioVentaUnitario,
      cantidadVendida: cantidadVendida,
      totalVentas: totalVentas,
    );
  }
}

extension VentasResumenMapper on VentasResumen {
  VentasResumenEntity toEntity() {
    return VentasResumenEntity(
      totalProductosVendidos: totalProductosVendidos,
      totalCantidadVendida: totalCantidadVendida,
      totalVentas: totalVentas,
    );
  }
}
