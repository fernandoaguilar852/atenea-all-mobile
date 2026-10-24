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
  @JsonKey(defaultValue: 0.0)
  final double total;
  @JsonKey(defaultValue: 0)
  final int numeroTransacciones;
  final List<ArqueoTransaccion> transacciones;

  ArqueoCaja({
    required this.total,
    required this.numeroTransacciones,
    required this.transacciones,
  });

  factory ArqueoCaja.fromJson(Map<String, dynamic> json) =>
      _$ArqueoCajaFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoCajaToJson(this);
}

@JsonSerializable()
class ArqueoBanco {
  @JsonKey(defaultValue: 0.0)
  final double total;
  @JsonKey(defaultValue: 0)
  final int numeroTransacciones;
  final List<ArqueoTransaccion> transacciones;

  ArqueoBanco({
    required this.total,
    required this.numeroTransacciones,
    required this.transacciones,
  });

  factory ArqueoBanco.fromJson(Map<String, dynamic> json) =>
      _$ArqueoBancoFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoBancoToJson(this);
}

@JsonSerializable()
class ArqueoTransaccion {
  @JsonKey(defaultValue: 0)
  final int transaccionId;
  @JsonKey(name: 'tipoTransaccion', defaultValue: '')
  final String tipo;
  @JsonKey(name: 'fechaTransaccion', defaultValue: '')
  final String fecha;
  @JsonKey(defaultValue: 0)
  final int? pagoId;
  @JsonKey(name: 'metodoPago', defaultValue: '')
  final String formaPago;
  @JsonKey(name: 'valor', defaultValue: 0.0)
  final double monto;

  ArqueoTransaccion({
    required this.transaccionId,
    required this.tipo,
    required this.fecha,
    this.pagoId,
    required this.formaPago,
    required this.monto,
  });

  factory ArqueoTransaccion.fromJson(Map<String, dynamic> json) =>
      _$ArqueoTransaccionFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoTransaccionToJson(this);
}

@JsonSerializable()
class ArqueoResumen {
  @JsonKey(defaultValue: 0.0)
  final double totalGeneral;
  @JsonKey(defaultValue: 0.0)
  final double totalCaja;
  @JsonKey(defaultValue: 0.0)
  final double totalBanco;
  @JsonKey(defaultValue: 0)
  final int totalTransacciones;
  @JsonKey(defaultValue: null)
  final RangoFechas? rangoFechas;

  ArqueoResumen({
    required this.totalGeneral,
    required this.totalCaja,
    required this.totalBanco,
    required this.totalTransacciones,
    this.rangoFechas,
  });

  factory ArqueoResumen.fromJson(Map<String, dynamic> json) =>
      _$ArqueoResumenFromJson(json);

  Map<String, dynamic> toJson() => _$ArqueoResumenToJson(this);
}

@JsonSerializable()
class RangoFechas {
  @JsonKey(defaultValue: '')
  final String desde;
  @JsonKey(defaultValue: '')
  final String hasta;

  RangoFechas({
    required this.desde,
    required this.hasta,
  });

  factory RangoFechas.fromJson(Map<String, dynamic> json) =>
      _$RangoFechasFromJson(json);

  Map<String, dynamic> toJson() => _$RangoFechasToJson(this);
}
