import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/active_role_provider.dart';
import '../../../../models/models.dart';
import '../../../../repositories/repository_providers.dart';

final auditControllerProvider =
    AsyncNotifierProvider<AuditController, List<AuditLog>>(AuditController.new);

class AuditController extends AsyncNotifier<List<AuditLog>> {
  @override
  Future<List<AuditLog>> build() => ref.read(auditRepositoryProvider).getAll();

  Future<void> record({
    required AuditAction action,
    required AuditEntityType entityType,
    required String description,
    String? entityId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final role = ref.read(activeRoleProvider);
    final log = AuditLog(
      id: 'audit-${DateTime.now().microsecondsSinceEpoch}',
      userId: role == UserRole.administrator
          ? 'user-admin-001'
          : 'user-reception-001',
      userName: role.displayName,
      action: action,
      entityType: entityType,
      entityId: entityId,
      description: description,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
    await ref.read(auditRepositoryProvider).append(log);
    state = AsyncData([log, ...?state.value]);
  }
}
