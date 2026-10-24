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
      nombreProducto: nombreProducto,
      nombreCategoria: nombreCategoria,
      cantidadVendida: cantidadVendida,
      precioVentaUnitario: precioVentaUnitario,
      subtotal: subtotal,
      descuentosAplicados: descuentosAplicados,
      impuestosAplicados: impuestosAplicados,
      totalVentas: totalVentas,
      numeroTransacciones: numeroTransacciones,
    );
  }
}

extension VentasResumenMapper on VentasResumen {
  VentasResumenEntity toEntity() {
    return VentasResumenEntity(
      totalProductosVendidos: totalProductosVendidos,
      totalTransacciones: totalTransacciones,
      subtotalGeneral: subtotalGeneral,
      descuentosGeneral: descuentosGeneral,
      impuestosGeneral: impuestosGeneral,
      totalGeneral: totalGeneral,
    );
  }
}
