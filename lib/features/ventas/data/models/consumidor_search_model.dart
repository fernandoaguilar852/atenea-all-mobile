import 'package:json_annotation/json_annotation.dart';
import 'venta_model.dart';

part 'consumidor_search_model.g.dart';

@JsonSerializable()
class ConsumidorSearchResponse {
  @JsonKey(name: 'data')
  final List<ConsumidorModel> data;

  @JsonKey(name: 'pagination')
  final PaginationResponse? pagination;

  const ConsumidorSearchResponse({
    required this.data,
    this.pagination,
  });

  factory ConsumidorSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ConsumidorSearchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumidorSearchResponseToJson(this);
}

@JsonSerializable()
class PaginationResponse {
  @JsonKey(name: 'totalElement')
  final int totalElement;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'pageNumber')
  final int pageNumber;

  @JsonKey(name: 'hasMoreElements')
  final bool hasMoreElements;

  const PaginationResponse({
    required this.totalElement,
    required this.pageSize,
    required this.pageNumber,
    required this.hasMoreElements,
  });

  factory PaginationResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationResponseToJson(this);
}
