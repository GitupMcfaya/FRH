import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../models/visitor.dart';
import '../../../../repositories/repository_providers.dart';

final visitorsControllerProvider =
    AsyncNotifierProvider<VisitorsController, List<Visitor>>(
      VisitorsController.new,
    );

class VisitorsController extends AsyncNotifier<List<Visitor>> {
  @override
  Future<List<Visitor>> build() {
    return ref.read(visitorRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(visitorRepositoryProvider).getAll(),
    );
  }

  Future<Visitor> create(Visitor visitor) async {
    final created = await ref.read(visitorRepositoryProvider).create(visitor);
    state = AsyncData(_sorted([...?state.value, created]));
    return created;
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    final updated = await ref.read(visitorRepositoryProvider).update(visitor);
    state = AsyncData(
      _sorted([
        for (final item in state.value ?? const <Visitor>[])
          if (item.id == updated.id) updated else item,
      ]),
    );
    return updated;
  }

  Future<void> delete(String id) async {
    final visits = await ref.read(visitRepositoryProvider).getAll();
    if (visits.any((visit) => visit.visitorId == id)) {
      throw const ConflictException(
        'This visitor has visit history and cannot be deleted.',
      );
    }
    await ref.read(visitorRepositoryProvider).delete(id);
    state = AsyncData(
      List.unmodifiable(
        (state.value ?? const <Visitor>[]).where((visitor) => visitor.id != id),
      ),
    );
  }

  List<Visitor> _sorted(List<Visitor> visitors) {
    visitors.sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(visitors);
  }
}
