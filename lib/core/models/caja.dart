import 'package:json_annotation/json_annotation.dart';

part 'caja.g.dart';

@JsonSerializable()
class Caja {
  final int cajaId;
  final int clienteId;
  final int usuarioId;
  final String nombreUsuario;
  final String estado;
  final String fecha;
  final String saldoInicial;
  final String openedAt;
  final String? closedAt;

  Caja({
    required this.cajaId,
    required this.clienteId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.estado,
    required this.fecha,
    required this.saldoInicial,
    required this.openedAt,
    this.closedAt,
  });

  factory Caja.fromJson(Map<String, dynamic> json) => _$CajaFromJson(json);

  Map<String, dynamic> toJson() => _$CajaToJson(this);

  String get displayName => '$cajaId - $nombreUsuario';
}

@JsonSerializable()
class CajaData {
  final List<Caja> cajas;

  CajaData({required this.cajas});

  factory CajaData.fromJson(Map<String, dynamic> json) =>
      _$CajaDataFromJson(json);

  Map<String, dynamic> toJson() => _$CajaDataToJson(this);
}

@JsonSerializable()
class CajaResponse {
  final CajaData data;
  final CajaPagination? pagination;

  CajaResponse({
    required this.data,
    this.pagination,
  });

  factory CajaResponse.fromJson(Map<String, dynamic> json) =>
      _$CajaResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CajaResponseToJson(this);
}

@JsonSerializable()
class CajaPagination {
  final int totalElement;
  final int pageSize;
  final int pageNumber;
  final bool hasMoreElements;

  CajaPagination({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory CajaPagination.fromJson(Map<String, dynamic> json) =>
      _$CajaPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$CajaPaginationToJson(this);
}
