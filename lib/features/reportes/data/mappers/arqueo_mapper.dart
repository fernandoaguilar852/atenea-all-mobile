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
      total: total,
      numeroTransacciones: numeroTransacciones,
      transacciones: transacciones.map((item) => item.toEntity()).toList(),
    );
  }
}

extension ArqueoBancoMapper on ArqueoBanco {
  ArqueoBancoEntity toEntity() {
    return ArqueoBancoEntity(
      total: total,
      numeroTransacciones: numeroTransacciones,
      transacciones: transacciones.map((item) => item.toEntity()).toList(),
    );
  }
}

extension ArqueoTransaccionMapper on ArqueoTransaccion {
  ArqueoTransaccionEntity toEntity() {
    return ArqueoTransaccionEntity(
      transaccionId: transaccionId,
      tipo: tipo,
      fecha: fecha,
      pagoId: pagoId,
      formaPago: formaPago,
      monto: monto,
    );
  }
}

extension ArqueoResumenMapper on ArqueoResumen {
  ArqueoResumenEntity toEntity() {
    return ArqueoResumenEntity(
      totalGeneral: totalGeneral,
      totalCaja: totalCaja,
      totalBanco: totalBanco,
      totalTransacciones: totalTransacciones,
      rangoFechas: rangoFechas?.toEntity(),
    );
  }
}

extension RangoFechasMapper on RangoFechas {
  RangoFechasEntity toEntity() {
    return RangoFechasEntity(
      desde: desde,
      hasta: hasta,
    );
  }
}
