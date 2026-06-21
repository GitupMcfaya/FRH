import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/model_enums.dart';

final activeRoleProvider = NotifierProvider<ActiveRoleController, UserRole>(
  ActiveRoleController.new,
);

class ActiveRoleController extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.receptionist;

  void select(UserRole role) => state = role;
}

bool canAccessPath(UserRole role, String path) {
  if (role == UserRole.administrator) return true;
  return const {
    '/dashboard',
    '/residents',
    '/visitors',
    '/check-in',
    '/active-visitors',
    '/history',
  }.contains(path);
}

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
    UserRole.administrator => 'Administrator',
    UserRole.receptionist => 'Receptionist',
  };

  String get displayName => switch (this) {
    UserRole.administrator => 'Abena Owusu',
    UserRole.receptionist => 'Esi Addo',
  };

  String get initials => switch (this) {
    UserRole.administrator => 'AO',
    UserRole.receptionist => 'EA',
  };
}
