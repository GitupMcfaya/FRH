import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/resident.dart';
import '../../../../repositories/repository_providers.dart';

final residentsControllerProvider =
    AsyncNotifierProvider<ResidentsController, List<Resident>>(
      ResidentsController.new,
    );

class ResidentsController extends AsyncNotifier<List<Resident>> {
  @override
  Future<List<Resident>> build() {
    return ref.read(residentRepositoryProvider).getAll(includeInactive: true);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(residentRepositoryProvider).getAll(includeInactive: true),
    );
  }

  Future<Resident> create(Resident resident) async {
    final created = await ref.read(residentRepositoryProvider).create(resident);
    state = AsyncData(_sorted([...?state.value, created]));
    return created;
  }

  Future<Resident> updateResident(Resident resident) async {
    final updated = await ref.read(residentRepositoryProvider).update(resident);
    state = AsyncData(
      _sorted([
        for (final item in state.value ?? const <Resident>[])
          if (item.id == updated.id) updated else item,
      ]),
    );
    return updated;
  }

  Future<Resident> deactivate(String id) async {
    final updated = await ref
        .read(residentRepositoryProvider)
        .deactivate(id, updatedAt: DateTime.now());
    state = AsyncData(
      _sorted([
        for (final item in state.value ?? const <Resident>[])
          if (item.id == updated.id) updated else item,
      ]),
    );
    return updated;
  }

  List<Resident> _sorted(List<Resident> residents) {
    residents.sort((a, b) => a.fullName.compareTo(b.fullName));
    return List.unmodifiable(residents);
  }
}
