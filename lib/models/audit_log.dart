import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_enums.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

@freezed
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    required String userId,
    required String userName,
    required AuditAction action,
    required AuditEntityType entityType,
    required String description,
    required DateTime timestamp,
    String? entityId,
    @Default(<String, dynamic>{}) Map<String, dynamic> metadata,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);
}
