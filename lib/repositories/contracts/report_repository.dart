import '../../models/visit.dart';

abstract interface class ReportRepository {
  Future<List<Visit>> getDailyVisits(DateTime date);

  Future<List<Visit>> getMonthlyVisits({required int year, required int month});

  Future<List<Visit>> getResidentVisits(String residentId);

  Future<Map<String, int>> getVisitorFrequency({DateTime? from, DateTime? to});
}
