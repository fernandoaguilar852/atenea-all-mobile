import '../models/venta_detalle_reporte.dart';
import '../../domain/entities/venta_detalle_entity.dart';
import 'common_mappers.dart';

extension VentaDetalleReporteMapper on VentaDetalleReporte {
  VentaDetalleEntity toEntity() {
    return VentaDetalleEntity(
      encabezado: encabezado.toEntity(),
      ventas: ventas.map((item) => item.toEntity()).toList(),
      resumen: resumen.toEntity(),
      pagination: pagination?.toEntity(),
    );
  }
}

extension VentaDetalleRowMapper on VentaDetalleRow {
  VentaDetalleRowEntity toEntity() {
    return VentaDetalleRowEntity(
      ventaId: ventaId,
      fechaVenta: fechaVenta,
      numeroFactura: numeroFactura,
      nombreCliente: nombreCliente,
      documentoCliente: documentoCliente,
      emailCliente: emailCliente,
      telefonoCliente: telefonoCliente,
      nombreCajero: nombreCajero,
      nombreCaja: nombreCaja,
      subtotal: subtotal,
      descuento: descuento,
      iva: iva,
      total: total,
      formaPago: formaPago,
      estadoVenta: estadoVenta,
      detalles: detalles.map((item) => item.toEntity()).toList(),
    );
  }
}

extension VentaDetalleLineaMapper on VentaDetalleLinea {
  VentaDetalleLineaEntity toEntity() {
    return VentaDetalleLineaEntity(
      productoId: productoId,
      nombreProducto: nombreProducto,
      codigoBarras: codigoBarras,
      cantidad: cantidad,
      precioUnitario: precioUnitario,
      descuento: descuento,
      subtotal: subtotal,
      iva: iva,
      total: total,
    );
  }
}

extension VentaDetalleResumenMapper on VentaDetalleResumen {
  VentaDetalleResumenEntity toEntity() {
    return VentaDetalleResumenEntity(
      totalVentas: totalVentas,
      totalSubtotal: totalSubtotal,
      totalDescuento: totalDescuento,
      totalIVA: totalIVA,
      totalGeneral: totalGeneral,
    );
  }
}
