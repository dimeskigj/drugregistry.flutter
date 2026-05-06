import 'package:equatable/equatable.dart';
import 'package:flutter_drug_registry/core/models/location.dart';
import 'package:flutter_drug_registry/core/models/pharmacy_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pharmacy.g.dart';

@JsonSerializable()
class Pharmacy extends Equatable {
  final String id;
  final String? idNumber;
  final String? taxNumber;
  final String? code;
  final String? name;
  final String? address;
  final String? municipality;
  final String? place;
  final String? phoneNumber;
  final String? decision;
  final String? email;
  final String? pharmacists;
  final String? technicians;
  final String? comment;
  @JsonKey(fromJson: _pharmacyTypeFromJson, toJson: _pharmacyTypeToJson)
  final PharmacyType? pharmacyType;
  final bool central;
  final bool active;
  final Location? location;
  final Uri? url;
  final DateTime? lastUpdate;

  const Pharmacy(
    this.id, {
    this.idNumber,
    this.taxNumber,
    this.code,
    this.name,
    this.address,
    this.municipality,
    this.place,
    this.phoneNumber,
    this.decision,
    this.email,
    this.pharmacists,
    this.technicians,
    this.comment,
    this.pharmacyType,
    this.central = false,
    this.active = false,
    this.location,
    this.url,
    this.lastUpdate,
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) =>
      _$PharmacyFromJson(json);

  Map<String, dynamic> toJson() => _$PharmacyToJson(this);

  static PharmacyType? _pharmacyTypeFromJson(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return switch (value.toInt()) {
        0 => PharmacyType.pharmacyStation,
        1 => PharmacyType.hospital,
        2 => PharmacyType.insulin,
        3 => PharmacyType.privateHealthInstitution,
        4 => PharmacyType.mobilePharmacy,
        _ => throw ArgumentError.value(value, 'pharmacyType'),
      };
    }

    if (value is String) {
      final normalized = value.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      return switch (normalized) {
        '0' || 'pharmacystation' => PharmacyType.pharmacyStation,
        '1' || 'hospital' => PharmacyType.hospital,
        '2' || 'insulin' => PharmacyType.insulin,
        '3' ||
        'privatehealthinstitution' => PharmacyType.privateHealthInstitution,
        '4' || 'mobilepharmacy' => PharmacyType.mobilePharmacy,
        _ => throw ArgumentError.value(value, 'pharmacyType'),
      };
    }

    throw ArgumentError.value(value, 'pharmacyType');
  }

  static String? _pharmacyTypeToJson(PharmacyType? value) {
    return switch (value) {
      PharmacyType.pharmacyStation => 'pharmacyStation',
      PharmacyType.hospital => 'hospital',
      PharmacyType.insulin => 'insulin',
      PharmacyType.privateHealthInstitution => 'privateHealthInstitution',
      PharmacyType.mobilePharmacy => 'mobilePharmacy',
      null => null,
    };
  }

  @override
  List<Object?> get props => [id];
}
