// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VisitorBadge _$VisitorBadgeFromJson(Map<String, dynamic> json) =>
    _VisitorBadge(
      id: json['id'] as String,
      badgeNumber: json['badgeNumber'] as String,
      status: $enumDecode(_$VisitorBadgeStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedVisitId: json['assignedVisitId'] as String?,
    );

Map<String, dynamic> _$VisitorBadgeToJson(_VisitorBadge instance) =>
    <String, dynamic>{
      'id': instance.id,
      'badgeNumber': instance.badgeNumber,
      'status': _$VisitorBadgeStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'assignedVisitId': instance.assignedVisitId,
    };

const _$VisitorBadgeStatusEnumMap = {
  VisitorBadgeStatus.available: 'available',
  VisitorBadgeStatus.assigned: 'assigned',
  VisitorBadgeStatus.unavailable: 'unavailable',
};
