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
  final double total;
  final int numeroTransacciones;
  final List<ArqueoTransaccionEntity> transacciones;

  const ArqueoCajaEntity({
    required this.total,
    required this.numeroTransacciones,
    required this.transacciones,
  });
}

class ArqueoBancoEntity {
  final double total;
  final int numeroTransacciones;
  final List<ArqueoTransaccionEntity> transacciones;

  const ArqueoBancoEntity({
    required this.total,
    required this.numeroTransacciones,
    required this.transacciones,
  });
}

class ArqueoTransaccionEntity {
  final int transaccionId;
  final String tipo;
  final String fecha;
  final int? pagoId;
  final String formaPago;
  final double monto;

  const ArqueoTransaccionEntity({
    required this.transaccionId,
    required this.tipo,
    required this.fecha,
    this.pagoId,
    required this.formaPago,
    required this.monto,
  });
}

class ArqueoResumenEntity {
  final double totalGeneral;
  final double totalCaja;
  final double totalBanco;
  final int totalTransacciones;
  final RangoFechasEntity? rangoFechas;

  const ArqueoResumenEntity({
    required this.totalGeneral,
    required this.totalCaja,
    required this.totalBanco,
    required this.totalTransacciones,
    this.rangoFechas,
  });
}

class RangoFechasEntity {
  final String desde;
  final String hasta;

  const RangoFechasEntity({
    required this.desde,
    required this.hasta,
  });
}
