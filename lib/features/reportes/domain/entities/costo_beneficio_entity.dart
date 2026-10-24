import 'common_entities.dart';

class CostoBeneficioEntity {
  final EncabezadoEntity encabezado;
  final List<CostoBeneficioRowEntity> productos;
  final CostoBeneficioResumenEntity resumen;
  final CostoBeneficioMetadatosEntity metadatos;
  final PaginacionEntity? pagination;

  const CostoBeneficioEntity({
    required this.encabezado,
    required this.productos,
    required this.resumen,
    required this.metadatos,
    this.pagination,
  });
}

class CostoBeneficioRowEntity {
  final int productoId;
  final String codigoBarras;
  final String nombreProducto;
  final int categoriaId;
  final String nombreCategoria;
  final int cantidadVendida;
  final double precioVenta;
  final double costoUnitario;
  final double ingresoTotal;
  final double costoTotal;
  final double beneficioNeto;
  final double margenPorcentaje;

  const CostoBeneficioRowEntity({
    required this.productoId,
    required this.codigoBarras,
    required this.nombreProducto,
    required this.categoriaId,
    required this.nombreCategoria,
    required this.cantidadVendida,
    required this.precioVenta,
    required this.costoUnitario,
    required this.ingresoTotal,
    required this.costoTotal,
    required this.beneficioNeto,
    required this.margenPorcentaje,
  });
}

class CostoBeneficioResumenEntity {
  final int totalProductos;
  final int totalCantidadVendida;
  final double totalIngresos;
  final double totalCostos;
  final double beneficioNetoTotal;
  final double margenPromedioGeneral;

  const CostoBeneficioResumenEntity({
    required this.totalProductos,
    required this.totalCantidadVendida,
    required this.totalIngresos,
    required this.totalCostos,
    required this.beneficioNetoTotal,
    required this.margenPromedioGeneral,
  });
}

class CostoBeneficioMetadatosEntity {
  final String fechaInicio;
  final String fechaFin;
  final int diasAnalisis;
  final String? productoMasRentable;
  final double? mayorMargen;
  final String? productoMenosRentable;
  final double? menorMargen;

  const CostoBeneficioMetadatosEntity({
    required this.fechaInicio,
    required this.fechaFin,
    required this.diasAnalisis,
    this.productoMasRentable,
    this.mayorMargen,
    this.productoMenosRentable,
    this.menorMargen,
  });
}
