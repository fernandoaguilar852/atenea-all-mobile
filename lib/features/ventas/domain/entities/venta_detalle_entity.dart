import 'package:equatable/equatable.dart';

/// Entidad de dominio para Detalle de una Venta (Producto vendido)
class VentaDetalleEntity extends Equatable {
  final int ventaDetalleId;
  final int clienteId;
  final int ventaId;
  final int productoId;
  final String productoNombre;
  final String? descripcion;
  final double cantidad;
  final double precioUnitario;
  final double subtotal;
  final double descuentoValor;
  final double descuentoPorcentaje;
  final String? codigoImpuesto;
  final double porcentajeImpuesto;
  final double valorImpuesto;
  final double totalLinea;
  final DateTime createdAt;

  const VentaDetalleEntity({
    required this.ventaDetalleId,
    required this.clienteId,
    required this.ventaId,
    required this.productoId,
    required this.productoNombre,
    this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    required this.descuentoValor,
    required this.descuentoPorcentaje,
    this.codigoImpuesto,
    required this.porcentajeImpuesto,
    required this.valorImpuesto,
    required this.totalLinea,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        ventaDetalleId,
        clienteId,
        ventaId,
        productoId,
        productoNombre,
        descripcion,
        cantidad,
        precioUnitario,
        subtotal,
        descuentoValor,
        descuentoPorcentaje,
        codigoImpuesto,
        porcentajeImpuesto,
        valorImpuesto,
        totalLinea,
        createdAt,
      ];
}
