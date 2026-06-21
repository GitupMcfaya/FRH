import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum UserRole { administrator, receptionist }

@JsonEnum(fieldRename: FieldRename.snake)
enum Gender { male, female, other, preferNotToSay }

@JsonEnum(fieldRename: FieldRename.snake)
enum VisitorIdType { ghanaCard, passport, driversLicense, voterId }

@JsonEnum(fieldRename: FieldRename.snake)
enum VisitStatus { checkedIn, checkedOut, cancelled }

@JsonEnum(fieldRename: FieldRename.snake)
enum VisitorBadgeStatus { available, assigned, unavailable }

@JsonEnum(fieldRename: FieldRename.snake)
enum AuditAction {
  login,
  logout,
  residentCreated,
  residentUpdated,
  residentDeactivated,
  visitorCreated,
  visitorUpdated,
  checkIn,
  checkOut,
  userCreated,
  userUpdated,
  settingsUpdated,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum AuditEntityType {
  authentication,
  user,
  resident,
  visitor,
  visit,
  badge,
  settings,
}
