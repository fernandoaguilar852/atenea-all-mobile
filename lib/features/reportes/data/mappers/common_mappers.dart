import '../models/reporte_encabezado.dart';
import '../../domain/entities/common_entities.dart';

/// Mappers para entidades comunes de reportes

extension ReporteEncabezadoMapper on ReporteEncabezado {
  EncabezadoEntity toEntity() {
    return EncabezadoEntity(
      clienteId: clienteId,
      nombre: nombre,
      razonSocial: razonSocial,
      nit: nit,
      digitoVerificacion: digitoVerificacion,
      tipoPersona: tipoPersona,
      regimen: regimen,
      direccion: direccion,
      telefono: telefono,
      email: email,
      logoUrl: logoUrl,
      sitioWeb: sitioWeb,
      responsableIVA: responsableIVA,
      tipoNegocio: tipoNegocio,
      estado: estado,
      plan: plan,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
      ciudadId: ciudadId,
      codigoCiiu: codigoCiiu,
      codigoPostal: codigoPostal,
      facturaElectronica: facturaElectronica,
      tipoDocumentoDefault: tipoDocumentoDefault,
      ciudad: ciudad.toEntity(),
      moneda: moneda.toEntity(),
    );
  }
}

extension ReporteCiudadMapper on ReporteCiudad {
  CiudadEntity toEntity() {
    return CiudadEntity(
      ciudadId: ciudadId,
      nombre: nombre,
      departamentoId: departamentoId,
      pais: pais,
    );
  }
}

extension ReporteMonedaMapper on ReporteMoneda {
  MonedaEntity toEntity() {
    return MonedaEntity(
      monedaId: monedaId,
      codigo: codigo,
      nombre: nombre,
      simbolo: simbolo,
      decimales: decimales,
      activo: activo,
    );
  }
}

extension ReportePaginationMapper on ReportePagination {
  PaginacionEntity toEntity() {
    return PaginacionEntity(
      currentPage: currentPage,
      pageSize: pageSize,
      totalCount: totalCount,
      hasNext: hasNext,
    );
  }
}
