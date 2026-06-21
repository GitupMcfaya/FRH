import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String fullName,
    required String email,
    required UserRole role,
    required bool isActive,
    required DateTime createdAt,
    DateTime? lastLoginAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserPermissions on User {
  bool get isAdministrator => role == UserRole.administrator;

  bool get canManageUsers => isAdministrator;
  bool get canManageResidents => isAdministrator;
  bool get canConfigureSettings => isAdministrator;
  bool get canViewAuditLogs => isAdministrator;
  bool get canProcessVisits => isActive;
  bool get canViewReports => isActive;
}
