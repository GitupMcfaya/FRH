import '../../models/visit.dart';
import '../contracts/report_repository.dart';
import '../contracts/visit_repository.dart';

class MockReportRepository implements ReportRepository {
  const MockReportRepository(this._visits);

  final VisitRepository _visits;

  @override
  Future<List<Visit>> getDailyVisits(DateTime date) async {
    final visits = await _visits.getAll();
    return List.unmodifiable(
      visits.where((visit) => _isSameDay(visit.checkInAt, date)),
    );
  }

  @override
  Future<List<Visit>> getMonthlyVisits({
    required int year,
    required int month,
  }) async {
    final visits = await _visits.getAll();
    return List.unmodifiable(
      visits.where(
        (visit) =>
            visit.checkInAt.year == year && visit.checkInAt.month == month,
      ),
    );
  }

  @override
  Future<List<Visit>> getResidentVisits(String residentId) async {
    final visits = await _visits.getAll();
    return List.unmodifiable(
      visits.where((visit) => visit.residentId == residentId),
    );
  }

  @override
  Future<Map<String, int>> getVisitorFrequency({
    DateTime? from,
    DateTime? to,
  }) async {
    final visits = await _visits.getAll();
    final counts = <String, int>{};
    for (final visit in visits) {
      if (from != null && visit.checkInAt.isBefore(from)) continue;
      if (to != null && visit.checkInAt.isAfter(to)) continue;
      counts.update(visit.visitorId, (count) => count + 1, ifAbsent: () => 1);
    }
    return Map.unmodifiable(counts);
  }

  bool _isSameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
