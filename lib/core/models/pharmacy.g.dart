// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pharmacy _$PharmacyFromJson(Map<String, dynamic> json) => Pharmacy(
      json['id'] as String,
      idNumber: json['idNumber'] as String?,
      taxNumber: json['taxNumber'] as String?,
      code: json['code'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      municipality: json['municipality'] as String?,
      place: json['place'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      decision: json['decision'] as String?,
      email: json['email'] as String?,
      pharmacists: json['pharmacists'] as String?,
      technicians: json['technicians'] as String?,
      comment: json['comment'] as String?,
      pharmacyType: Pharmacy._pharmacyTypeFromJson(json['pharmacyType']),
      central: json['central'] as bool? ?? false,
      active: json['active'] as bool? ?? false,
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      url: json['url'] == null ? null : Uri.parse(json['url'] as String),
      lastUpdate: json['lastUpdate'] == null
          ? null
          : DateTime.parse(json['lastUpdate'] as String),
    );

Map<String, dynamic> _$PharmacyToJson(Pharmacy instance) => <String, dynamic>{
      'id': instance.id,
      'idNumber': instance.idNumber,
      'taxNumber': instance.taxNumber,
      'code': instance.code,
      'name': instance.name,
      'address': instance.address,
      'municipality': instance.municipality,
      'place': instance.place,
      'phoneNumber': instance.phoneNumber,
      'decision': instance.decision,
      'email': instance.email,
      'pharmacists': instance.pharmacists,
      'technicians': instance.technicians,
      'comment': instance.comment,
      'pharmacyType': Pharmacy._pharmacyTypeToJson(instance.pharmacyType),
      'central': instance.central,
      'active': instance.active,
      'location': instance.location,
      'url': instance.url?.toString(),
      'lastUpdate': instance.lastUpdate?.toIso8601String(),
    };
