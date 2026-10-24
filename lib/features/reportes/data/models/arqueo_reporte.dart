import 'package:json_annotation/json_annotation.dart';
import 'reporte_encabezado.dart';

part 'arqueo_reporte.g.dart';

@JsonSerializable()
class ArqueoReporte {
  final ReporteEncabezado encabezado;
  final ArqueoDetalle reporteArqueo;
  final ArqueoResumen resumen;

  ArqueoReporte({
    required this.encabezado,
    required this.reporteArqueo,
    required this.resumen,
  });

  factory ArqueoReporte.fromJson(Map<String, dynamic> json) =>
      _$ArqueoReporteFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoReporteToJson(this);
}

@JsonSerializable()
class ArqueoDetalle {
  final ArqueoCaja caja;
  final ArqueoBanco banco;

  ArqueoDetalle({
    required this.caja,
    required this.banco,
  });

  factory ArqueoDetalle.fromJson(Map<String, dynamic> json) =>
      _$ArqueoDetalleFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoDetalleToJson(this);
}

@JsonSerializable()
class ArqueoCaja {
  final double? saldoInicial;
  final double? totalIngresos;
  final double? totalEgresos;
  final double? saldoFinal;
  final List<ArqueoTransaccion> transacciones;

  ArqueoCaja({
    this.saldoInicial,
    this.totalIngresos,
    this.totalEgresos,
    this.saldoFinal,
    required this.transacciones,
  });

  factory ArqueoCaja.fromJson(Map<String, dynamic> json) =>
      _$ArqueoCajaFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoCajaToJson(this);
}

@JsonSerializable()
class ArqueoBanco {
  final double? saldoInicial;
  final double? totalIngresos;
  final double? totalEgresos;
  final double? saldoFinal;
  final List<ArqueoTransaccion> transacciones;

  ArqueoBanco({
    this.saldoInicial,
    this.totalIngresos,
    this.totalEgresos,
    this.saldoFinal,
    required this.transacciones,
  });

  factory ArqueoBanco.fromJson(Map<String, dynamic> json) =>
      _$ArqueoBancoFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoBancoToJson(this);
}

@JsonSerializable()
class ArqueoTransaccion {
  final int transaccionId;
  final String fecha;
  final String tipo;
  final String concepto;
  final String? numeroDocumento;
  final double monto;
  final String formaPago;
  final String? observaciones;

  ArqueoTransaccion({
    required this.transaccionId,
    required this.fecha,
    required this.tipo,
    required this.concepto,
    this.numeroDocumento,
    required this.monto,
    required this.formaPago,
    this.observaciones,
  });

  factory ArqueoTransaccion.fromJson(Map<String, dynamic> json) =>
      _$ArqueoTransaccionFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoTransaccionToJson(this);
}

@JsonSerializable()
class ArqueoResumen {
  final double totalIngresosCaja;
  final double totalEgresosCaja;
  final double saldoFinalCaja;
  final double totalIngresosBanco;
  final double totalEgresosBanco;
  final double saldoFinalBanco;
  final double totalGeneral;

  ArqueoResumen({
    required this.totalIngresosCaja,
    required this.totalEgresosCaja,
    required this.saldoFinalCaja,
    required this.totalIngresosBanco,
    required this.totalEgresosBanco,
    required this.saldoFinalBanco,
    required this.totalGeneral,
  });

  factory ArqueoResumen.fromJson(Map<String, dynamic> json) =>
      _$ArqueoResumenFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoResumenToJson(this);
}
