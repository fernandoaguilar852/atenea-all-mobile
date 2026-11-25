/// Datos de un consumidor que se va a crear (o a actualizar, más adelante)
class NuevoConsumidor {
  final String tipoIdentificacion;
  final String numeroIdentificacion;

  /// Solo aplica para NIT (0 a 9)
  final String? digitoVerificacion;
  final String nombreRazonSocial;
  final String? direccion;
  final String? email;
  final String? telefono;

  /// Obligatoria: del consumidor solo se guarda el id de la ciudad
  final int ciudadId;
  final bool activo;

  const NuevoConsumidor({
    required this.tipoIdentificacion,
    required this.numeroIdentificacion,
    this.digitoVerificacion,
    required this.nombreRazonSocial,
    this.direccion,
    this.email,
    this.telefono,
    required this.ciudadId,
    this.activo = true,
  });
}
