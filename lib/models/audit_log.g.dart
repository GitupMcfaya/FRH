// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => _AuditLog(
  id: json['id'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  action: $enumDecode(_$AuditActionEnumMap, json['action']),
  entityType: $enumDecode(_$AuditEntityTypeEnumMap, json['entityType']),
  description: json['description'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  entityId: json['entityId'] as String?,
  metadata:
      json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'userName': instance.userName,
  'action': _$AuditActionEnumMap[instance.action]!,
  'entityType': _$AuditEntityTypeEnumMap[instance.entityType]!,
  'description': instance.description,
  'timestamp': instance.timestamp.toIso8601String(),
  'entityId': instance.entityId,
  'metadata': instance.metadata,
};

const _$AuditActionEnumMap = {
  AuditAction.login: 'login',
  AuditAction.logout: 'logout',
  AuditAction.residentCreated: 'resident_created',
  AuditAction.residentUpdated: 'resident_updated',
  AuditAction.residentDeactivated: 'resident_deactivated',
  AuditAction.visitorCreated: 'visitor_created',
  AuditAction.visitorUpdated: 'visitor_updated',
  AuditAction.checkIn: 'check_in',
  AuditAction.checkOut: 'check_out',
  AuditAction.userCreated: 'user_created',
  AuditAction.userUpdated: 'user_updated',
  AuditAction.settingsUpdated: 'settings_updated',
};

const _$AuditEntityTypeEnumMap = {
  AuditEntityType.authentication: 'authentication',
  AuditEntityType.user: 'user',
  AuditEntityType.resident: 'resident',
  AuditEntityType.visitor: 'visitor',
  AuditEntityType.visit: 'visit',
  AuditEntityType.badge: 'badge',
  AuditEntityType.settings: 'settings',
};
