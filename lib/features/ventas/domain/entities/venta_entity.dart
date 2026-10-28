import 'package:equatable/equatable.dart';
import 'venta_pago_entity.dart';
import 'venta_detalle_entity.dart';
import 'consumidor_entity.dart';

/// Entidad de dominio para Venta (Factura)
class VentaEntity extends Equatable {
  final int ventaId;
  final int clienteId;
  final int? consumidorId;
  final String? consumidorNombre; // Nombre del consumidor para mostrar en lista
  final ConsumidorEntity? consumidor; // Objeto completo del consumidor
  final int? cajaId;
  final int? ordenServicioId;
  final int? formaPagoId;
  final String? formaPagoNombre;
  final String? formaPagoTipo; // CONTADO o CREDITO
  final DateTime? fechaVencimiento;
  final String? codigoVoucher;

  // Montos
  final double subtotalSinImpuestos;
  final double totalDescuentos;
  final double totalImpuestos;
  final double totalIva;
  final double totalInc;
  final double totalIca;
  final double total;
  final double porcentajeFinanciamiento;
  final double valorFinanciamiento;

  // Estado
  final String estado; // pagada, anulada, pendiente
  final String? observacion;

  // Facturación DIAN
  final String? tipoDocumento; // POS, FE, NC, ND
  final String? prefijoFactura;
  final String? numeroFactura;
  final DateTime? fechaEmision;
  final String? cufe;
  final String? qrCode;
  final String? estadoDian; // PENDIENTE, ACEPTADA, RECHAZADA, ERROR
  final String? dianTrackId;

  final DateTime createdAt;

  // Pagos y detalles (solo cuando se carga venta completa)
  final List<VentaPagoEntity>? pagos;
  final List<VentaDetalleEntity>? detalles;

  const VentaEntity({
    required this.ventaId,
    required this.clienteId,
    this.consumidorId,
    this.consumidorNombre,
    this.consumidor,
    this.cajaId,
    this.ordenServicioId,
    this.formaPagoId,
    this.formaPagoNombre,
    this.formaPagoTipo,
    this.fechaVencimiento,
    this.codigoVoucher,
    required this.subtotalSinImpuestos,
    required this.totalDescuentos,
    required this.totalImpuestos,
    required this.totalIva,
    required this.totalInc,
    required this.totalIca,
    required this.total,
    required this.porcentajeFinanciamiento,
    required this.valorFinanciamiento,
    required this.estado,
    this.observacion,
    this.tipoDocumento,
    this.prefijoFactura,
    this.numeroFactura,
    this.fechaEmision,
    this.cufe,
    this.qrCode,
    this.estadoDian,
    this.dianTrackId,
    required this.createdAt,
    this.pagos,
    this.detalles,
  });

  /// Retorna el número completo de factura (prefijo + número)
  String? get numeroCompletoFactura {
    if (prefijoFactura != null && numeroFactura != null) {
      return '$prefijoFactura-$numeroFactura';
    }
    return numeroFactura;
  }

  /// Retorna true si la venta está anulada
  bool get esAnulada => estado.toLowerCase() == 'anulada';

  /// Retorna true si la venta está pagada
  bool get esPagada => estado.toLowerCase() == 'pagada';

  /// Retorna true si la venta está pendiente
  bool get esPendiente => estado.toLowerCase() == 'pendiente';

  @override
  List<Object?> get props => [
        ventaId,
        clienteId,
        consumidorId,
        consumidorNombre,
        consumidor,
        cajaId,
        ordenServicioId,
        formaPagoId,
        formaPagoNombre,
        formaPagoTipo,
        fechaVencimiento,
        codigoVoucher,
        subtotalSinImpuestos,
        totalDescuentos,
        totalImpuestos,
        totalIva,
        totalInc,
        totalIca,
        total,
        porcentajeFinanciamiento,
        valorFinanciamiento,
        estado,
        observacion,
        tipoDocumento,
        prefijoFactura,
        numeroFactura,
        fechaEmision,
        cufe,
        qrCode,
        estadoDian,
        dianTrackId,
        createdAt,
        pagos,
        detalles,
      ];
}
