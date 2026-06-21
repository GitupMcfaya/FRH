import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_visitor_manager/core/errors/repository_exception.dart';
import 'package:hostel_visitor_manager/models/models.dart';
import 'package:hostel_visitor_manager/repositories/repositories.dart';

void main() {
  const noLatency = Duration.zero;

  group('MockAuthRepository', () {
    late MockAuthRepository repository;

    setUp(() => repository = MockAuthRepository(latency: noLatency));
    tearDown(() => repository.dispose());

    test('authenticates known users and clears the session', () async {
      final user = await repository.signIn(
        email: 'RECEPTION@unihostel.edu.gh ',
        password: 'Reception123!',
      );

      expect(user.role, UserRole.receptionist);
      expect(repository.currentUser, user);

      await repository.signOut();
      expect(repository.currentUser, isNull);
    });

    test('rejects invalid credentials', () async {
      expect(
        () => repository.signIn(
          email: 'reception@unihostel.edu.gh',
          password: 'incorrect',
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('MockResidentRepository', () {
    late MockResidentRepository repository;

    setUp(() => repository = MockResidentRepository(latency: noLatency));

    test('searches by name, student ID, room, and block', () async {
      expect(await repository.search('Ama'), hasLength(1));
      expect(await repository.search('UG7654321'), hasLength(1));
      expect(await repository.search('308'), hasLength(1));
      expect(await repository.search('C'), hasLength(1));
    });

    test('deactivates residents without deleting their records', () async {
      final updatedAt = DateTime.utc(2026, 6, 21);
      final resident = await repository.deactivate(
        'resident-001',
        updatedAt: updatedAt,
      );

      expect(resident.isActive, isFalse);
      expect(await repository.getAll(), hasLength(2));
      expect(await repository.getAll(includeInactive: true), hasLength(4));
    });

    test('prevents duplicate student IDs', () async {
      final existing = await repository.getById('resident-001');

      expect(
        () => repository.create(existing!.copyWith(id: '')),
        throwsA(isA<ConflictException>()),
      );
    });
  });

  group('MockVisitorRepository', () {
    late MockVisitorRepository repository;

    setUp(() => repository = MockVisitorRepository(latency: noLatency));

    test('searches visitor identity fields', () async {
      expect(await repository.search('Kwame'), hasLength(1));
      expect(await repository.search('GHA-123456789-1'), hasLength(1));
      expect(await repository.search('0552228877'), hasLength(1));
    });

    test('prevents duplicate identity documents', () async {
      final existing = await repository.getById('visitor-001');

      expect(
        () => repository.create(existing!.copyWith(id: '')),
        throwsA(isA<ConflictException>()),
      );
    });

    test('creates, updates, and deletes visitor records', () async {
      final now = DateTime.utc(2026, 6, 21);
      final created = await repository.create(
        Visitor(
          id: '',
          fullName: 'Adwoa Serwaa',
          phoneNumber: '0249876543',
          idType: VisitorIdType.studentReferenceNumber,
          idNumber: 'SRC20260101',
          address: 'Osu, Accra',
          createdAt: now,
          updatedAt: now,
        ),
      );

      final updated = await repository.update(
        created.copyWith(address: 'Labone, Accra'),
      );
      expect(updated.address, 'Labone, Accra');

      await repository.delete(created.id);
      expect(await repository.getById(created.id), isNull);
    });
  });

  group('MockVisitRepository', () {
    late MockVisitRepository repository;

    setUp(() => repository = MockVisitRepository(latency: noLatency));

    test('check-in assigns a badge and checkout releases it', () async {
      final checkInAt = DateTime.utc(2026, 6, 21, 9);
      final visit = await repository.checkIn(
        CheckInCommand(
          visitorId: 'visitor-002',
          residentId: 'resident-001',
          purpose: 'Study group',
          badgeId: 'badge-002',
          receptionistId: 'user-reception-001',
          checkInAt: checkInAt,
        ),
      );

      expect(visit.status, VisitStatus.checkedIn);
      expect(
        (await repository.getAvailableBadges()).map((badge) => badge.id),
        isNot(contains('badge-002')),
      );

      final completed = await repository.checkOut(
        visitId: visit.id,
        receptionistId: 'user-reception-001',
        checkOutAt: checkInAt.add(const Duration(hours: 1)),
      );

      expect(completed.status, VisitStatus.checkedOut);
      expect(
        (await repository.getAvailableBadges()).map((badge) => badge.id),
        contains('badge-002'),
      );
    });

    test('prevents duplicate active visits and unavailable badges', () async {
      expect(
        () => repository.checkIn(
          CheckInCommand(
            visitorId: 'visitor-001',
            residentId: 'resident-002',
            purpose: 'Second visit',
            badgeId: 'badge-002',
            receptionistId: 'user-reception-001',
            checkInAt: DateTime.utc(2026, 6, 21),
          ),
        ),
        throwsA(isA<ConflictException>()),
      );

      expect(
        () => repository.checkIn(
          CheckInCommand(
            visitorId: 'visitor-002',
            residentId: 'resident-001',
            purpose: 'Family visit',
            badgeId: 'badge-001',
            receptionistId: 'user-reception-001',
            checkInAt: DateTime.utc(2026, 6, 21),
          ),
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('creates badges and prevents disabling assigned badges', () async {
      final created = await repository.createBadge(
        'V-011',
        DateTime.utc(2026, 6, 21),
      );
      expect(created.isAvailable, isTrue);

      final disabled = await repository.setBadgeUnavailable(created.id, true);
      expect(disabled.status, VisitorBadgeStatus.unavailable);

      expect(
        () => repository.setBadgeUnavailable('badge-001', true),
        throwsA(isA<ConflictException>()),
      );
    });
  });

  group('MockReportRepository', () {
    test('builds daily, monthly, resident, and frequency summaries', () async {
      final visits = MockVisitRepository(latency: noLatency);
      final reports = MockReportRepository(visits);
      final allVisits = await visits.getAll();
      final reference = allVisits.first.checkInAt;

      final daily = await reports.getDailyVisits(reference);
      final monthly = await reports.getMonthlyVisits(
        year: reference.year,
        month: reference.month,
      );
      final resident = await reports.getResidentVisits('resident-001');
      final frequency = await reports.getVisitorFrequency();

      expect(daily, isNotEmpty);
      expect(monthly, isNotEmpty);
      expect(resident, isNotEmpty);
      expect(frequency['visitor-001'], greaterThan(0));
    });
  });
}
