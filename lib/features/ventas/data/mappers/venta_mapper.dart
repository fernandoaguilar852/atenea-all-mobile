import '../../domain/entities/venta_entity.dart';
import '../../domain/entities/venta_pago_entity.dart';
import '../../domain/entities/venta_detalle_entity.dart';
import '../../domain/entities/consumidor_entity.dart';
import '../models/venta_model.dart';

class VentaMapper {
  /// Convierte ConsumidorModel a ConsumidorEntity
  static ConsumidorEntity? toConsumidorEntity(ConsumidorModel? model) {
    if (model == null) return null;
    return ConsumidorEntity(
      consumidorId: model.consumidorId,
      nombreRazonSocial: model.nombreRazonSocial,
      numeroIdentificacion: model.numeroIdentificacion,
      tipoIdentificacion: model.tipoIdentificacion,
      direccion: model.direccion,
      telefono: model.telefono,
      email: model.email,
    );
  }
  /// Convierte VentaPagoModel a VentaPagoEntity
  static VentaPagoEntity toPagoEntity(VentaPagoModel model) {
    return VentaPagoEntity(
      ventaPagoId: model.ventaPagoId,
      ventaId: model.ventaId,
      pagoId: model.pagoId,
      valor: model.valor,
      numeroComprobante: model.numeroComprobante,
      bancoId: model.bancoId,
      createdAt: DateTime.parse(model.createdAt),
    );
  }

  /// Convierte VentaDetalleModel a VentaDetalleEntity
  static VentaDetalleEntity toDetalleEntity(VentaDetalleModel model) {
    return VentaDetalleEntity(
      ventaDetalleId: model.ventaDetalleId,
      clienteId: model.clienteId,
      ventaId: model.ventaId,
      productoId: model.productoId,
      productoNombre: model.productoNombre,
      descripcion: model.descripcion,
      cantidad: model.cantidad,
      precioUnitario: model.precioUnitario,
      subtotal: model.subtotal,
      descuentoValor: model.descuentoValor,
      descuentoPorcentaje: model.descuentoPorcentaje,
      codigoImpuesto: model.codigoImpuesto,
      porcentajeImpuesto: model.porcentajeImpuesto,
      valorImpuesto: model.valorImpuesto,
      totalLinea: model.totalLinea,
      createdAt: DateTime.parse(model.createdAt),
    );
  }

  /// Convierte VentaModel a VentaEntity
  static VentaEntity toEntity(VentaModel model) {
    return VentaEntity(
      ventaId: model.ventaId,
      clienteId: model.clienteId,
      consumidorId: model.consumidorId,
      consumidorNombre: model.consumidor?.nombreRazonSocial,
      consumidor: toConsumidorEntity(model.consumidor),
      cajaId: model.cajaId,
      ordenServicioId: model.ordenServicioId,
      formaPagoId: model.formaPagoId,
      formaPagoNombre: model.formaPagoNombre,
      formaPagoTipo: model.formaPagoTipo,
      fechaVencimiento: model.fechaVencimiento != null
          ? DateTime.tryParse(model.fechaVencimiento!)
          : null,
      codigoVoucher: model.codigoVoucher,
      subtotalSinImpuestos: model.subtotalSinImpuestos,
      totalDescuentos: model.totalDescuentos,
      totalImpuestos: model.totalImpuestos,
      totalIva: model.totalIva,
      totalInc: model.totalInc,
      totalIca: model.totalIca,
      total: model.total,
      porcentajeFinanciamiento: model.porcentajeFinanciamiento,
      valorFinanciamiento: model.valorFinanciamiento,
      estado: model.estado,
      observacion: model.observacion,
      tipoDocumento: model.tipoDocumento,
      prefijoFactura: model.prefijoFactura,
      numeroFactura: model.numeroFactura,
      fechaEmision: model.fechaEmision != null
          ? DateTime.tryParse(model.fechaEmision!)
          : null,
      cufe: model.cufe,
      qrCode: model.qrCode,
      estadoDian: model.estadoDian,
      dianTrackId: model.dianTrackId,
      createdAt: DateTime.parse(model.createdAt),
      pagos: model.pagos?.map((p) => toPagoEntity(p)).toList(),
      detalles: model.detalles?.map((d) => toDetalleEntity(d)).toList(),
    );
  }

  /// Convierte lista de VentaModel a lista de VentaEntity
  static List<VentaEntity> toEntityList(List<VentaModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }
}
