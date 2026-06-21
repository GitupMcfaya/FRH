import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/user.dart';
import '../../../../models/model_enums.dart';
import '../../../../repositories/repository_providers.dart';
import '../../../audit/presentation/controllers/audit_controller.dart';

final usersControllerProvider =
    AsyncNotifierProvider<UsersController, List<User>>(UsersController.new);

class UsersController extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() => ref.read(userRepositoryProvider).getAll();

  Future<User> save(User user) async {
    final repository = ref.read(userRepositoryProvider);
    final saved = user.id.isEmpty
        ? await repository.create(user)
        : await repository.update(user);
    state = AsyncData(
      [
        ...(state.value ?? const <User>[]).where((item) => item.id != saved.id),
        saved,
      ]..sort((a, b) => a.fullName.compareTo(b.fullName)),
    );
    await ref
        .read(auditControllerProvider.notifier)
        .record(
          action: user.id.isEmpty
              ? AuditAction.userCreated
              : AuditAction.userUpdated,
          entityType: AuditEntityType.user,
          entityId: saved.id,
          description:
              '${user.id.isEmpty ? 'Created' : 'Updated'} staff user ${saved.fullName}.',
        );
    return saved;
  }

  Future<User> setActive(User user, bool active) async {
    final updated = await ref
        .read(userRepositoryProvider)
        .setActive(user.id, active);
    state = AsyncData([
      for (final item in state.value ?? const <User>[])
        if (item.id == updated.id) updated else item,
    ]);
    await ref
        .read(auditControllerProvider.notifier)
        .record(
          action: AuditAction.userUpdated,
          entityType: AuditEntityType.user,
          entityId: updated.id,
          description:
              '${active ? 'Activated' : 'Deactivated'} staff user ${updated.fullName}.',
        );
    return updated;
  }
}
