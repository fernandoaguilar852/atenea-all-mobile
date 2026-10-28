import 'package:equatable/equatable.dart';

/// Entidad de dominio para Pago de una Venta
class VentaPagoEntity extends Equatable {
  final int ventaPagoId;
  final int ventaId;
  final int pagoId;
  final double valor;
  final String? numeroComprobante;
  final int? bancoId;
  final DateTime createdAt;

  const VentaPagoEntity({
    required this.ventaPagoId,
    required this.ventaId,
    required this.pagoId,
    required this.valor,
    this.numeroComprobante,
    this.bancoId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        ventaPagoId,
        ventaId,
        pagoId,
        valor,
        numeroComprobante,
        bancoId,
        createdAt,
      ];
}
