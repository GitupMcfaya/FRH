// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Visitor _$VisitorFromJson(Map<String, dynamic> json) => _Visitor(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  idType: $enumDecode(_$VisitorIdTypeEnumMap, json['idType']),
  idNumber: json['idNumber'] as String,
  address: json['address'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  notes: json['notes'] as String?,
  photoPath: json['photoPath'] as String?,
);

Map<String, dynamic> _$VisitorToJson(_Visitor instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'phoneNumber': instance.phoneNumber,
  'idType': _$VisitorIdTypeEnumMap[instance.idType]!,
  'idNumber': instance.idNumber,
  'address': instance.address,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'notes': instance.notes,
  'photoPath': instance.photoPath,
};

const _$VisitorIdTypeEnumMap = {
  VisitorIdType.ghanaCard: 'ghana_card',
  VisitorIdType.passport: 'passport',
  VisitorIdType.driversLicense: 'drivers_license',
  VisitorIdType.voterId: 'voter_id',
};
