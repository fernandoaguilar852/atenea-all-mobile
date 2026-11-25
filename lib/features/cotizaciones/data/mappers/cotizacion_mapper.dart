import '../../domain/entities/cotizacion_detalle_entity.dart';
import '../../domain/entities/cotizacion_entity.dart';
import '../../domain/entities/cotizacion_impresion_entity.dart';
import '../models/cotizacion_detalle_model.dart';
import '../models/cotizacion_impresion_model.dart';
import '../models/cotizacion_model.dart';

/// Mapper para convertir DTOs a Entities
class CotizacionMapper {
  /// Convierte CotizacionModel a CotizacionEntity
  static CotizacionEntity toEntity(CotizacionModel model) {
    return CotizacionEntity(
      cotizacionId: model.cotizacionId,
      clienteId: model.clienteId,
      numeroCotizacion: model.numeroCotizacion,
      consumidorNombre: model.consumidor.nombre,
      consumidorIdentificacion: model.consumidor.identificacion,
      consumidorEmail: model.consumidor.email,
      consumidorTelefono: model.consumidor.telefono,
      fechaCotizacion: DateTime.parse(model.fechaCotizacion),
      fechaValidez: DateTime.parse(model.fechaValidez),
      diasValidez: model.diasValidez,
      estaVencida: model.estaVencida,
      total: model.totales.total,
      createdAt: DateTime.parse(model.createdAt),
    );
  }

  /// Convierte lista de CotizacionModel a lista de CotizacionEntity
  static List<CotizacionEntity> toEntityList(List<CotizacionModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convierte PaginacionModel a CotizacionesPaginacion
  static CotizacionesPaginacion? toPaginacionEntity(PaginacionModel? model) {
    if (model == null) return null;

    // Calcular totalPages basado en totalElement y pageSize
    final totalPages = (model.totalElement / model.pageSize).ceil();

    return CotizacionesPaginacion(
      currentPage: model.pageNumber,
      totalPages: totalPages,
      totalItems: model.totalElement,
      pageSize: model.pageSize,
      hasNext: model.hasMoreElements,
      hasPrevious: model.pageNumber > 1,
    );
  }

  /// Convierte CotizacionesResponse a CotizacionesListEntity
  static CotizacionesListEntity toListEntity(CotizacionesResponse response) {
    return CotizacionesListEntity(
      cotizaciones: toEntityList(response.data.cotizaciones),
      pagination: toPaginacionEntity(response.pagination),
    );
  }

  /// Convierte ImpresionDataModel a CotizacionImpresionEntity (para el PDF)
  static CotizacionImpresionEntity toImpresionEntity(ImpresionDataModel model) {
    final encabezado = model.encabezado;
    final cotizacion = model.cotizacion;
    final pie = model.piePagina;

    // NIT con dígito de verificación: 37810503-3
    String? nit;
    if (encabezado.nit != null && encabezado.nit!.isNotEmpty) {
      final dv = encabezado.digitoVerificacion;
      nit = (dv != null && dv.isNotEmpty) ? '${encabezado.nit}-$dv' : encabezado.nit;
    }

    // Ciudad: "Bucaramanga - Santander"
    String? ciudad;
    final ciudadNombre = encabezado.ciudad?.nombre;
    final departamento = encabezado.ciudad?.departamento;
    if (ciudadNombre != null && ciudadNombre.isNotEmpty) {
      ciudad = (departamento != null && departamento.isNotEmpty)
          ? '$ciudadNombre - $departamento'
          : ciudadNombre;
    }

    return CotizacionImpresionEntity(
      empresaNombre: encabezado.nombre,
      empresaNit: nit,
      empresaDireccion: encabezado.direccion,
      empresaTelefono: encabezado.telefono,
      empresaEmail: encabezado.email,
      empresaCiudad: ciudad,
      logoUrl: encabezado.logoUrl,
      numeroCotizacion: cotizacion.numeroCotizacion,
      fechaCotizacion: DateTime.parse(cotizacion.fechaCotizacion),
      fechaValidez: _parseFecha(cotizacion.fechaValidez),
      observacion: cotizacion.observacion,
      consumidorNombre: cotizacion.consumidor.nombre,
      consumidorIdentificacion: cotizacion.consumidor.identificacion,
      consumidorTelefono: cotizacion.consumidor.telefono,
      consumidorEmail: cotizacion.consumidor.email,
      lineas: model.detalle.map(toImpresionLineaEntity).toList(),
      subtotal: model.totales.subtotalSinImpuestos,
      totalDescuentos: model.totales.totalDescuentos,
      totalIva: model.totales.totalIva,
      total: model.totales.total,
      facturaPiePagina: pie?.facturaPiePagina,
      agradecimiento: pie?.agradecimiento,
      notas: pie?.notas,
      terminosCondiciones: pie?.terminosCondiciones,
    );
  }

  /// Convierte ImpresionLineaModel a ImpresionLineaEntity
  /// La referencia es el productoId y la descripción el nombre del producto
  static ImpresionLineaEntity toImpresionLineaEntity(ImpresionLineaModel model) {
    final productoId = model.productoId ?? model.producto?.productoId;
    final descripcion = model.producto?.nombre ??
        model.descripcion ??
        model.observacionLinea ??
        '';

    return ImpresionLineaEntity(
      cantidad: model.cantidad,
      referencia: productoId?.toString() ?? '',
      descripcion: descripcion,
      precioUnitario: model.precioUnitario,
      descuentoValor: model.descuentoValor,
      porcentajeImpuesto: model.porcentajeImpuesto ?? 0,
      totalLinea: model.totalLinea,
    );
  }

  /// Parsea una fecha yyyy-MM-dd (o ISO) sin desfase de zona horaria
  static DateTime? _parseFecha(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return parsed.isUtc ? parsed.toLocal() : parsed;
  }

  /// Convierte CotizacionLineaModel a CotizacionLineaEntity
  static CotizacionLineaEntity toLineaEntity(CotizacionLineaModel model) {
    return CotizacionLineaEntity(
      cotizacionDetalleId: model.cotizacionDetalleId,
      productoId: model.productoId,
      nombreProducto: model.nombreProducto,
      descripcion: model.descripcion,
      cantidad: model.cantidad,
      precioUnitario: model.precioUnitario,
      subtotal: model.subtotal,
      descuentoValor: model.descuentoValor,
      valorImpuesto: model.valorImpuesto,
      totalLinea: model.totalLinea,
      observacionLinea: model.observacionLinea,
    );
  }

  /// Convierte CotizacionDetalleModel a CotizacionDetalleEntity
  /// De la auditoría solo se conserva el origen (no IP ni userAgent)
  static CotizacionDetalleEntity toDetalleEntity(CotizacionDetalleModel model) {
    return CotizacionDetalleEntity(
      cotizacionId: model.cotizacionId,
      clienteId: model.clienteId,
      numeroCotizacion: model.numeroCotizacion,
      consumidorNombre: model.consumidor.nombre,
      consumidorIdentificacion: model.consumidor.identificacion,
      consumidorEmail: model.consumidor.email,
      consumidorTelefono: model.consumidor.telefono,
      fechaCotizacion: DateTime.parse(model.fechaCotizacion),
      fechaValidez: DateTime.parse(model.fechaValidez),
      diasValidez: model.diasValidez,
      estaVencida: model.estaVencida,
      subtotalSinImpuestos: model.totales.subtotalSinImpuestos,
      totalDescuentos: model.totales.totalDescuentos,
      totalImpuestos: model.totales.totalImpuestos,
      total: model.totales.total,
      observacion: model.observacion,
      origen: model.auditoria?.origenRequest,
      createdAt: DateTime.parse(model.createdAt),
      updatedAt:
          model.updatedAt != null ? DateTime.parse(model.updatedAt!) : null,
      detalles: model.detalles.map(toLineaEntity).toList(),
    );
  }
}
