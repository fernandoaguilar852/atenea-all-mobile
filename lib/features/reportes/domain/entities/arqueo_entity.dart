import 'common_entities.dart';

class ArqueoEntity {
  final EncabezadoEntity encabezado;
  final ArqueoDetalleEntity reporteArqueo;
  final ArqueoResumenEntity resumen;

  const ArqueoEntity({
    required this.encabezado,
    required this.reporteArqueo,
    required this.resumen,
  });
}

class ArqueoDetalleEntity {
  final ArqueoCajaEntity caja;
  final ArqueoBancoEntity banco;

  const ArqueoDetalleEntity({
    required this.caja,
    required this.banco,
  });
}

class ArqueoCajaEntity {
  final double? saldoInicial;
  final double? totalIngresos;
  final double? totalEgresos;
  final double? saldoFinal;
  final List<ArqueoTransaccionEntity> transacciones;

  const ArqueoCajaEntity({
    required this.saldoInicial,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.saldoFinal,
    required this.transacciones,
  });
}

class ArqueoBancoEntity {
  final double? saldoInicial;
  final double? totalIngresos;
  final double? totalEgresos;
  final double? saldoFinal;
  final List<ArqueoTransaccionEntity> transacciones;

  const ArqueoBancoEntity({
    required this.saldoInicial,
    required this.totalIngresos,
    required this.totalEgresos,
    required this.saldoFinal,
    required this.transacciones,
  });
}

class ArqueoTransaccionEntity {
  final int transaccionId;
  final String fecha;
  final String tipo;
  final String concepto;
  final String? numeroDocumento;
  final double monto;
  final String formaPago;
  final String? observaciones;

  const ArqueoTransaccionEntity({
    required this.transaccionId,
    required this.fecha,
    required this.tipo,
    required this.concepto,
    this.numeroDocumento,
    required this.monto,
    required this.formaPago,
    this.observaciones,
  });
}

class ArqueoResumenEntity {
  final double totalIngresosCaja;
  final double totalEgresosCaja;
  final double saldoFinalCaja;
  final double totalIngresosBanco;
  final double totalEgresosBanco;
  final double saldoFinalBanco;
  final double totalGeneral;

  const ArqueoResumenEntity({
    required this.totalIngresosCaja,
    required this.totalEgresosCaja,
    required this.saldoFinalCaja,
    required this.totalIngresosBanco,
    required this.totalEgresosBanco,
    required this.saldoFinalBanco,
    required this.totalGeneral,
  });
}
