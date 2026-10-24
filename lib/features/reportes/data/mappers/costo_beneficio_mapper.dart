import '../models/costo_beneficio_reporte.dart';
import '../../domain/entities/costo_beneficio_entity.dart';
import 'common_mappers.dart';

extension CostoBeneficioReporteMapper on CostoBeneficioReporte {
  CostoBeneficioEntity toEntity() {
    return CostoBeneficioEntity(
      encabezado: encabezado.toEntity(),
      productos: productos.map((item) => item.toEntity()).toList(),
      resumen: resumen.toEntity(),
      metadatos: metadatos.toEntity(),
      pagination: pagination?.toEntity(),
    );
  }
}

extension CostoBeneficioRowMapper on CostoBeneficioRow {
  CostoBeneficioRowEntity toEntity() {
    return CostoBeneficioRowEntity(
      productoId: productoId,
      codigoBarras: codigoBarras,
      nombreProducto: nombreProducto,
      categoriaId: categoriaId,
      nombreCategoria: nombreCategoria,
      cantidadVendida: cantidadVendida,
      precioVenta: precioVenta,
      costoUnitario: costoUnitario,
      ingresoTotal: ingresoTotal,
      costoTotal: costoTotal,
      beneficioNeto: beneficioNeto,
      margenPorcentaje: margenPorcentaje,
    );
  }
}

extension CostoBeneficioResumenMapper on CostoBeneficioResumen {
  CostoBeneficioResumenEntity toEntity() {
    return CostoBeneficioResumenEntity(
      totalProductos: totalProductos,
      totalCantidadVendida: totalCantidadVendida,
      totalIngresos: totalIngresos,
      totalCostos: totalCostos,
      beneficioNetoTotal: beneficioNetoTotal,
      margenPromedioGeneral: margenPromedioGeneral,
    );
  }
}

extension CostoBeneficioMetadatosMapper on CostoBeneficioMetadatos {
  CostoBeneficioMetadatosEntity toEntity() {
    return CostoBeneficioMetadatosEntity(
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      diasAnalisis: diasAnalisis,
      productoMasRentable: productoMasRentable,
      mayorMargen: mayorMargen,
      productoMenosRentable: productoMenosRentable,
      menorMargen: menorMargen,
    );
  }
}
