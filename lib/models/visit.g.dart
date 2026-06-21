// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Visit _$VisitFromJson(Map<String, dynamic> json) => _Visit(
  id: json['id'] as String,
  visitorId: json['visitorId'] as String,
  residentId: json['residentId'] as String,
  purpose: json['purpose'] as String,
  badgeId: json['badgeId'] as String,
  badgeNumber: json['badgeNumber'] as String,
  checkedInByUserId: json['checkedInByUserId'] as String,
  checkInAt: DateTime.parse(json['checkInAt'] as String),
  status: $enumDecode(_$VisitStatusEnumMap, json['status']),
  checkOutAt: json['checkOutAt'] == null
      ? null
      : DateTime.parse(json['checkOutAt'] as String),
  checkedOutByUserId: json['checkedOutByUserId'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$VisitToJson(_Visit instance) => <String, dynamic>{
  'id': instance.id,
  'visitorId': instance.visitorId,
  'residentId': instance.residentId,
  'purpose': instance.purpose,
  'badgeId': instance.badgeId,
  'badgeNumber': instance.badgeNumber,
  'checkedInByUserId': instance.checkedInByUserId,
  'checkInAt': instance.checkInAt.toIso8601String(),
  'status': _$VisitStatusEnumMap[instance.status]!,
  'checkOutAt': instance.checkOutAt?.toIso8601String(),
  'checkedOutByUserId': instance.checkedOutByUserId,
  'notes': instance.notes,
};

const _$VisitStatusEnumMap = {
  VisitStatus.checkedIn: 'checked_in',
  VisitStatus.checkedOut: 'checked_out',
  VisitStatus.cancelled: 'cancelled',
};
