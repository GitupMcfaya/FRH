import '../../models/visit.dart';
import '../../models/visitor_badge.dart';

class CheckInCommand {
  const CheckInCommand({
    required this.visitorId,
    required this.residentId,
    required this.purpose,
    required this.badgeId,
    required this.receptionistId,
    required this.checkInAt,
    this.notes,
  });

  final String visitorId;
  final String residentId;
  final String purpose;
  final String badgeId;
  final String receptionistId;
  final DateTime checkInAt;
  final String? notes;
}

abstract interface class VisitRepository {
  Future<List<Visit>> getAll();

  Future<Visit?> getById(String id);

  Future<List<Visit>> getActive();

  Future<List<Visit>> getHistory({DateTime? from, DateTime? to});

  Future<List<VisitorBadge>> getBadges();

  Future<List<VisitorBadge>> getAvailableBadges();

  Future<VisitorBadge> createBadge(String badgeNumber, DateTime createdAt);

  Future<VisitorBadge> setBadgeUnavailable(String badgeId, bool unavailable);

  Future<Visit> checkIn(CheckInCommand command);

  Future<Visit> checkOut({
    required String visitId,
    required String receptionistId,
    required DateTime checkOutAt,
  });
}
