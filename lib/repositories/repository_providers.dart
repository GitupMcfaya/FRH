import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts/auth_repository.dart';
import 'contracts/resident_repository.dart';
import 'contracts/report_repository.dart';
import 'contracts/visit_repository.dart';
import 'contracts/visitor_repository.dart';
import 'contracts/settings_repository.dart';
import 'contracts/user_repository.dart';
import 'contracts/audit_repository.dart';
import '../core/services/local_json_store.dart';
import 'mock/mock_auth_repository.dart';
import 'mock/mock_resident_repository.dart';
import 'mock/mock_report_repository.dart';
import 'mock/mock_visit_repository.dart';
import 'mock/mock_visitor_repository.dart';
import 'local/local_settings_repository.dart';
import 'local/local_user_repository.dart';
import 'local/local_audit_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = MockAuthRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final residentRepositoryProvider = Provider<ResidentRepository>(
  (ref) => MockResidentRepository(),
);

final visitorRepositoryProvider = Provider<VisitorRepository>(
  (ref) => MockVisitorRepository(),
);

final visitRepositoryProvider = Provider<VisitRepository>(
  (ref) => MockVisitRepository(),
);

final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => MockReportRepository(ref.watch(visitRepositoryProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => const LocalSettingsRepository(LocalJsonStore()),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => LocalUserRepository(const LocalJsonStore()),
);

final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => LocalAuditRepository(const LocalJsonStore()),
);
