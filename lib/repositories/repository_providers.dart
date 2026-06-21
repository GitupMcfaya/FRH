import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts/auth_repository.dart';
import 'contracts/resident_repository.dart';
import 'contracts/visit_repository.dart';
import 'contracts/visitor_repository.dart';
import 'mock/mock_auth_repository.dart';
import 'mock/mock_resident_repository.dart';
import 'mock/mock_visit_repository.dart';
import 'mock/mock_visitor_repository.dart';

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
