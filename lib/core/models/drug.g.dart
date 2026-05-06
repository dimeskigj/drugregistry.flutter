// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Drug _$DrugFromJson(Map<String, dynamic> json) => Drug(
      json['id'] as String,
      decisionNumber: json['decisionNumber'] as String?,
      atc: json['atc'] as String?,
      latinName: json['latinName'] as String?,
      genericName: json['genericName'] as String?,
      issuingType: Drug._issuingTypeFromJson(json['issuingType']),
      ingredients: json['ingredients'] as String?,
      packaging: json['packaging'] as String?,
      strength: json['strength'] as String?,
      pharmaceuticalForm: json['pharmaceuticalForm'] as String?,
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      manualUrl: json['manualUrl'] == null
          ? null
          : Uri.parse(json['manualUrl'] as String),
      reportUrl: json['reportUrl'] == null
          ? null
          : Uri.parse(json['reportUrl'] as String),
      decisionDate: json['decisionDate'] == null
          ? null
          : DateTime.parse(json['decisionDate'] as String),
      validityDate: json['validityDate'] == null
          ? null
          : DateTime.parse(json['validityDate'] as String),
      approvalCarrier: json['approvalCarrier'] as String?,
      manufacturer: json['manufacturer'] as String?,
      priceWithVat: (json['priceWithVat'] as num?)?.toDouble(),
      priceWithoutVat: (json['priceWithoutVat'] as num?)?.toDouble(),
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$DrugToJson(Drug instance) => <String, dynamic>{
      'id': instance.id,
      'decisionNumber': instance.decisionNumber,
      'atc': instance.atc,
      'latinName': instance.latinName,
      'genericName': instance.genericName,
      'issuingType': Drug._issuingTypeToJson(instance.issuingType),
      'ingredients': instance.ingredients,
      'packaging': instance.packaging,
      'strength': instance.strength,
      'pharmaceuticalForm': instance.pharmaceuticalForm,
      'url': instance.url?.toString(),
      'manualUrl': instance.manualUrl?.toString(),
      'reportUrl': instance.reportUrl?.toString(),
      'decisionDate': instance.decisionDate?.toIso8601String(),
      'validityDate': instance.validityDate?.toIso8601String(),
      'approvalCarrier': instance.approvalCarrier,
      'manufacturer': instance.manufacturer,
      'priceWithVat': instance.priceWithVat,
      'priceWithoutVat': instance.priceWithoutVat,
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
    };
