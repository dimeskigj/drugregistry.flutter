import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'issuing_type.dart';

part 'drug.g.dart';

@JsonSerializable()
class Drug extends Equatable {
  final String id;
  final String? decisionNumber;
  final String? atc;
  final String? latinName;
  final String? genericName;
  @JsonKey(fromJson: _issuingTypeFromJson, toJson: _issuingTypeToJson)
  final IssuingType? issuingType;
  final String? ingredients;
  final String? packaging;
  final String? strength;
  final String? pharmaceuticalForm;
  final Uri? url;
  final Uri? manualUrl;
  final Uri? reportUrl;
  final DateTime? decisionDate;
  final DateTime? validityDate;
  final String? approvalCarrier;
  final String? manufacturer;
  final double? priceWithVat;
  final double? priceWithoutVat;
  final DateTime? lastUpdate;

  const Drug(
    this.id, {
    this.decisionNumber,
    this.atc,
    this.latinName,
    this.genericName,
    this.issuingType,
    this.ingredients,
    this.packaging,
    this.strength,
    this.pharmaceuticalForm,
    this.url,
    this.manualUrl,
    this.reportUrl,
    this.decisionDate,
    this.validityDate,
    this.approvalCarrier,
    this.manufacturer,
    this.priceWithVat,
    this.priceWithoutVat,
    this.lastUpdate,
  });

  factory Drug.fromJson(Map<String, dynamic> json) => _$DrugFromJson(json);

  Map<String, dynamic> toJson() => _$DrugToJson(this);

  static IssuingType? _issuingTypeFromJson(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return switch (value.toInt()) {
        0 => IssuingType.overTheCounter,
        1 => IssuingType.prescriptionOnly,
        2 => IssuingType.hospitalOnly,
        _ => throw ArgumentError.value(value, 'issuingType'),
      };
    }

    if (value is String) {
      return switch (value.toLowerCase()) {
        '0' || 'overthecounter' => IssuingType.overTheCounter,
        '1' || 'prescriptiononly' => IssuingType.prescriptionOnly,
        '2' || 'hospitalonly' => IssuingType.hospitalOnly,
        _ => throw ArgumentError.value(value, 'issuingType'),
      };
    }

    throw ArgumentError.value(value, 'issuingType');
  }

  static int? _issuingTypeToJson(IssuingType? value) {
    return switch (value) {
      IssuingType.overTheCounter => 0,
      IssuingType.prescriptionOnly => 1,
      IssuingType.hospitalOnly => 2,
      null => null,
    };
  }

  @override
  List<Object?> get props => [id];
}
