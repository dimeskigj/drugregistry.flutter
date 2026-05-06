// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paged_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PagedResult<T> _$PagedResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PagedResult<T>(
      (json['data'] as List<dynamic>?)?.map(fromJsonT).toList() ?? [],
      (json['totalCount'] as num).toInt(),
      (json['page'] as num).toInt(),
      (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$PagedResultToJson<T>(
  PagedResult<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'data': instance.data.map(toJsonT).toList(),
      'totalCount': instance.totalCount,
      'page': instance.page,
      'size': instance.size,
    };
