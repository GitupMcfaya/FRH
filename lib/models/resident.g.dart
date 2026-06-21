// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resident.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Resident _$ResidentFromJson(Map<String, dynamic> json) => _Resident(
  id: json['id'] as String,
  studentId: json['studentId'] as String,
  fullName: json['fullName'] as String,
  phoneNumber: json['phoneNumber'] as String,
  block: json['block'] as String,
  roomNumber: json['roomNumber'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  programme: json['programme'] as String?,
  emergencyContact: json['emergencyContact'] as String?,
);

Map<String, dynamic> _$ResidentToJson(_Resident instance) => <String, dynamic>{
  'id': instance.id,
  'studentId': instance.studentId,
  'fullName': instance.fullName,
  'phoneNumber': instance.phoneNumber,
  'block': instance.block,
  'roomNumber': instance.roomNumber,
  'gender': _$GenderEnumMap[instance.gender]!,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'programme': instance.programme,
  'emergencyContact': instance.emergencyContact,
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
  Gender.preferNotToSay: 'prefer_not_to_say',
};
