import '../../core/errors/repository_exception.dart';
import '../../models/models.dart';
import '../contracts/visit_repository.dart';
import 'mock_data.dart';

class MockVisitRepository implements VisitRepository {
  MockVisitRepository({this.latency = const Duration(milliseconds: 180)})
    : _visits = MockData.visits(DateTime.now()),
      _badges = MockData.badges(DateTime.now());

  final Duration latency;
  final List<Visit> _visits;
  final List<VisitorBadge> _badges;
  var _nextId = 100;

  Future<void> _wait() => Future<void>.delayed(latency);

  @override
  Future<List<Visit>> getAll() async {
    await _wait();
    return _sorted(_visits);
  }

  @override
  Future<Visit?> getById(String id) async {
    await _wait();
    return _visits.where((visit) => visit.id == id).firstOrNull;
  }

  @override
  Future<List<Visit>> getActive() async {
    await _wait();
    return _sorted(_visits.where((visit) => visit.isActive));
  }

  @override
  Future<List<Visit>> getHistory({DateTime? from, DateTime? to}) async {
    await _wait();
    final result = _visits.where((visit) {
      if (visit.status == VisitStatus.checkedIn) return false;
      if (from != null && visit.checkInAt.isBefore(from)) return false;
      if (to != null && visit.checkInAt.isAfter(to)) return false;
      return true;
    });
    return _sorted(result);
  }

  @override
  Future<List<VisitorBadge>> getBadges() async {
    await _wait();
    final result = [..._badges]
      ..sort((a, b) => a.badgeNumber.compareTo(b.badgeNumber));
    return List.unmodifiable(result);
  }

  @override
  Future<List<VisitorBadge>> getAvailableBadges() async {
    await _wait();
    final result = _badges.where((badge) => badge.isAvailable).toList()
      ..sort((a, b) => a.badgeNumber.compareTo(b.badgeNumber));
    return List.unmodifiable(result);
  }

  @override
  Future<VisitorBadge> createBadge(
    String badgeNumber,
    DateTime createdAt,
  ) async {
    await _wait();
    final normalized = badgeNumber.trim().toUpperCase();
    if (_badges.any((badge) => badge.badgeNumber == normalized)) {
      throw ConflictException('Badge $normalized already exists.');
    }
    final badge = VisitorBadge(
      id: 'badge-${(_badges.length + 1).toString().padLeft(3, '0')}',
      badgeNumber: normalized,
      status: VisitorBadgeStatus.available,
      createdAt: createdAt,
    );
    _badges.add(badge);
    return badge;
  }

  @override
  Future<VisitorBadge> setBadgeUnavailable(
    String badgeId,
    bool unavailable,
  ) async {
    await _wait();
    final index = _badges.indexWhere((badge) => badge.id == badgeId);
    if (index == -1) {
      throw RecordNotFoundException('Badge $badgeId was not found.');
    }
    final badge = _badges[index];
    if (badge.status == VisitorBadgeStatus.assigned) {
      throw ConflictException(
        'Badge ${badge.badgeNumber} is assigned and cannot be disabled.',
      );
    }
    final updated = badge.copyWith(
      status: unavailable
          ? VisitorBadgeStatus.unavailable
          : VisitorBadgeStatus.available,
    );
    _badges[index] = updated;
    return updated;
  }

  @override
  Future<Visit> checkIn(CheckInCommand command) async {
    await _wait();
    if (command.purpose.trim().isEmpty) {
      throw const ValidationException('A visit purpose is required.');
    }
    if (_visits.any(
      (visit) => visit.visitorId == command.visitorId && visit.isActive,
    )) {
      throw const ConflictException('This visitor is already checked in.');
    }

    final badgeIndex = _badges.indexWhere(
      (badge) => badge.id == command.badgeId,
    );
    if (badgeIndex == -1) {
      throw RecordNotFoundException('Badge ${command.badgeId} was not found.');
    }
    final badge = _badges[badgeIndex];
    if (!badge.isAvailable) {
      throw ConflictException('Badge ${badge.badgeNumber} is not available.');
    }

    final visit = Visit(
      id: 'visit-${_nextId++}',
      visitorId: command.visitorId,
      residentId: command.residentId,
      purpose: command.purpose.trim(),
      badgeId: badge.id,
      badgeNumber: badge.badgeNumber,
      checkedInByUserId: command.receptionistId,
      checkInAt: command.checkInAt,
      status: VisitStatus.checkedIn,
      notes: command.notes,
    );

    _visits.add(visit);
    _badges[badgeIndex] = badge.copyWith(
      status: VisitorBadgeStatus.assigned,
      assignedVisitId: visit.id,
    );
    return visit;
  }

  @override
  Future<Visit> checkOut({
    required String visitId,
    required String receptionistId,
    required DateTime checkOutAt,
  }) async {
    await _wait();
    final visitIndex = _visits.indexWhere((visit) => visit.id == visitId);
    if (visitIndex == -1) {
      throw RecordNotFoundException('Visit $visitId was not found.');
    }
    final visit = _visits[visitIndex];
    if (!visit.isActive) {
      throw const ConflictException('This visit is no longer active.');
    }
    if (checkOutAt.isBefore(visit.checkInAt)) {
      throw const ValidationException('Checkout cannot precede check-in.');
    }

    final badgeIndex = _badges.indexWhere((badge) => badge.id == visit.badgeId);
    if (badgeIndex == -1) {
      throw RecordNotFoundException('Badge ${visit.badgeId} was not found.');
    }

    final completed = visit.copyWith(
      checkedOutByUserId: receptionistId,
      checkOutAt: checkOutAt,
      status: VisitStatus.checkedOut,
    );
    _visits[visitIndex] = completed;
    _badges[badgeIndex] = _badges[badgeIndex].copyWith(
      status: VisitorBadgeStatus.available,
      assignedVisitId: null,
    );
    return completed;
  }

  List<Visit> _sorted(Iterable<Visit> visits) {
    final result = visits.toList()
      ..sort((a, b) => b.checkInAt.compareTo(a.checkInAt));
    return List.unmodifiable(result);
  }
}
