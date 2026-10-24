// Entidades comunes compartidas entre todos los reportes
// Estas son las versiones Domain de los modelos de Data

/// Encabezado del reporte con información del cliente
class EncabezadoEntity {
  final int clienteId;
  final String nombre;
  final String razonSocial;
  final String nit;
  final String digitoVerificacion;
  final String tipoPersona;
  final String regimen;
  final String direccion;
  final String telefono;
  final String email;
  final String? logoUrl;
  final String? sitioWeb;
  final String responsableIVA;
  final String tipoNegocio;
  final String estado;
  final String plan;
  final String fechaCreacion;
  final String fechaActualizacion;
  final int ciudadId;
  final String? codigoCiiu;
  final String? codigoPostal;
  final bool? facturaElectronica;
  final String? tipoDocumentoDefault;
  final CiudadEntity ciudad;
  final MonedaEntity moneda;

  const EncabezadoEntity({
    required this.clienteId,
    required this.nombre,
    required this.razonSocial,
    required this.nit,
    required this.digitoVerificacion,
    required this.tipoPersona,
    required this.regimen,
    required this.direccion,
    required this.telefono,
    required this.email,
    this.logoUrl,
    this.sitioWeb,
    required this.responsableIVA,
    required this.tipoNegocio,
    required this.estado,
    required this.plan,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.ciudadId,
    this.codigoCiiu,
    this.codigoPostal,
    this.facturaElectronica,
    this.tipoDocumentoDefault,
    required this.ciudad,
    required this.moneda,
  });
}

/// Ciudad del cliente
class CiudadEntity {
  final int ciudadId;
  final String nombre;
  final String departamentoId;
  final String pais;

  const CiudadEntity({
    required this.ciudadId,
    required this.nombre,
    required this.departamentoId,
    required this.pais,
  });
}

/// Moneda utilizada en el reporte
class MonedaEntity {
  final int monedaId;
  final String codigo;
  final String nombre;
  final String simbolo;
  final int decimales;
  final bool activo;

  const MonedaEntity({
    required this.monedaId,
    required this.codigo,
    required this.nombre,
    required this.simbolo,
    required this.decimales,
    required this.activo,
  });
}

/// Información de paginación del reporte
class PaginacionEntity {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final bool hasNext;

  const PaginacionEntity({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.hasNext,
  });

  /// Calcula el número total de páginas
  int get totalPages => totalCount > 0 ? ((totalCount - 1) ~/ pageSize) + 1 : 0;

  /// Indica si hay página anterior
  bool get hasPrevious => currentPage > 1;
}
