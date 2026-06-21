import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/hostel_settings.dart';
import '../../../../repositories/repository_providers.dart';
import '../../../../models/model_enums.dart';
import '../../../audit/presentation/controllers/audit_controller.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, HostelSettings>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<HostelSettings> {
  @override
  Future<HostelSettings> build() => ref.read(settingsRepositoryProvider).load();

  Future<HostelSettings> save(HostelSettings settings) async {
    final saved = await ref.read(settingsRepositoryProvider).save(settings);
    state = AsyncData(saved);
    await ref
        .read(auditControllerProvider.notifier)
        .record(
          action: AuditAction.settingsUpdated,
          entityType: AuditEntityType.settings,
          description: 'Updated hostel operational settings.',
        );
    return saved;
  }
}
