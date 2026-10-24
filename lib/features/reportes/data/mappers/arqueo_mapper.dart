import '../models/arqueo_reporte.dart';
import '../../domain/entities/arqueo_entity.dart';
import 'common_mappers.dart';

extension ArqueoReporteMapper on ArqueoReporte {
  ArqueoEntity toEntity() {
    return ArqueoEntity(
      encabezado: encabezado.toEntity(),
      reporteArqueo: reporteArqueo.toEntity(),
      resumen: resumen.toEntity(),
    );
  }
}

extension ArqueoDetalleMapper on ArqueoDetalle {
  ArqueoDetalleEntity toEntity() {
    return ArqueoDetalleEntity(
      caja: caja.toEntity(),
      banco: banco.toEntity(),
    );
  }
}

extension ArqueoCajaMapper on ArqueoCaja {
  ArqueoCajaEntity toEntity() {
    return ArqueoCajaEntity(
      saldoInicial: saldoInicial,
      totalIngresos: totalIngresos,
      totalEgresos: totalEgresos,
      saldoFinal: saldoFinal,
      transacciones: transacciones.map((item) => item.toEntity()).toList(),
    );
  }
}

extension ArqueoBancoMapper on ArqueoBanco {
  ArqueoBancoEntity toEntity() {
    return ArqueoBancoEntity(
      saldoInicial: saldoInicial,
      totalIngresos: totalIngresos,
      totalEgresos: totalEgresos,
      saldoFinal: saldoFinal,
      transacciones: transacciones.map((item) => item.toEntity()).toList(),
    );
  }
}

extension ArqueoTransaccionMapper on ArqueoTransaccion {
  ArqueoTransaccionEntity toEntity() {
    return ArqueoTransaccionEntity(
      transaccionId: transaccionId,
      fecha: fecha,
      tipo: tipo,
      concepto: concepto,
      numeroDocumento: numeroDocumento,
      monto: monto,
      formaPago: formaPago,
      observaciones: observaciones,
    );
  }
}

extension ArqueoResumenMapper on ArqueoResumen {
  ArqueoResumenEntity toEntity() {
    return ArqueoResumenEntity(
      totalIngresosCaja: totalIngresosCaja,
      totalEgresosCaja: totalEgresosCaja,
      saldoFinalCaja: saldoFinalCaja,
      totalIngresosBanco: totalIngresosBanco,
      totalEgresosBanco: totalEgresosBanco,
      saldoFinalBanco: saldoFinalBanco,
      totalGeneral: totalGeneral,
    );
  }
}
