import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/repository_exception.dart';
import '../../../../models/models.dart';
import '../../../../repositories/repositories.dart';

final visitsControllerProvider =
    AsyncNotifierProvider<VisitsController, List<Visit>>(VisitsController.new);

final availableBadgesProvider = FutureProvider<List<VisitorBadge>>(
  (ref) => ref.read(visitRepositoryProvider).getAvailableBadges(),
);

class VisitsController extends AsyncNotifier<List<Visit>> {
  @override
  Future<List<Visit>> build() => ref.read(visitRepositoryProvider).getAll();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(visitRepositoryProvider).getAll(),
    );
    ref.invalidate(availableBadgesProvider);
  }

  Future<Visit> checkIn(CheckInCommand command) async {
    final resident = await ref
        .read(residentRepositoryProvider)
        .getById(command.residentId);
    if (resident == null) {
      throw const RecordNotFoundException(
        'The selected resident was not found.',
      );
    }
    if (!resident.isActive) {
      throw const ValidationException('The selected resident is inactive.');
    }
    final visitor = await ref
        .read(visitorRepositoryProvider)
        .getById(command.visitorId);
    if (visitor == null) {
      throw const RecordNotFoundException(
        'The selected visitor was not found.',
      );
    }

    final visit = await ref.read(visitRepositoryProvider).checkIn(command);
    state = AsyncData(_sorted([...?state.value, visit]));
    ref.invalidate(availableBadgesProvider);
    return visit;
  }

  Future<Visit> checkOut({
    required String visitId,
    required String receptionistId,
    required DateTime checkOutAt,
  }) async {
    final completed = await ref
        .read(visitRepositoryProvider)
        .checkOut(
          visitId: visitId,
          receptionistId: receptionistId,
          checkOutAt: checkOutAt,
        );
    state = AsyncData(
      _sorted([
        for (final visit in state.value ?? const <Visit>[])
          if (visit.id == completed.id) completed else visit,
      ]),
    );
    ref.invalidate(availableBadgesProvider);
    return completed;
  }

  List<Visit> _sorted(List<Visit> visits) {
    visits.sort((a, b) => b.checkInAt.compareTo(a.checkInAt));
    return List.unmodifiable(visits);
  }
}
