import 'package:json_annotation/json_annotation.dart';

import '../utils/generic_factory.dart';

part 'paged_result.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PagedResult<T> {
  @JsonKey(defaultValue: <dynamic>[])
  final List<T> data;
  final int totalCount;
  final int page;
  final int size;

  PagedResult(this.data, this.totalCount, this.page, this.size);

  factory PagedResult.fromJson(Map<String, dynamic> json) =>
      _$PagedResultFromJson(json, fromJsonFactory<T>);

  Map<String, dynamic> toJson() => _$PagedResultToJson(this, toJsonFactory<T>);
}
