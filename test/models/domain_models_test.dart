import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_visitor_manager/models/models.dart';

void main() {
  group('domain models', () {
    final createdAt = DateTime.utc(2026, 6, 20, 8, 30);

    test('User round-trips through JSON and exposes role permissions', () {
      final user = User(
        id: 'user-1',
        fullName: 'Abena Owusu',
        email: 'abena@unihostel.edu.gh',
        role: UserRole.administrator,
        isActive: true,
        createdAt: createdAt,
      );

      final restored = User.fromJson(user.toJson());

      expect(restored, user);
      expect(restored.canManageUsers, isTrue);
      expect(restored.canProcessVisits, isTrue);
    });

    test('Resident copyWith preserves immutable value semantics', () {
      final resident = Resident(
        id: 'resident-1',
        studentId: 'UG1234567',
        fullName: 'Ama Mensah',
        phoneNumber: '0241234567',
        block: 'A',
        roomNumber: '204',
        gender: Gender.female,
        isActive: true,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final moved = resident.copyWith(block: 'B', roomNumber: '112');

      expect(resident.roomLabel, 'Block A · Room 204');
      expect(moved.roomLabel, 'Block B · Room 112');
      expect(moved.studentId, resident.studentId);
    });

    test('Visitor ID enum is serialized using stable snake-case values', () {
      final visitor = Visitor(
        id: 'visitor-1',
        fullName: 'Kojo Asare',
        phoneNumber: '+233241234567',
        idType: VisitorIdType.ghanaCard,
        idNumber: 'GHA-123456789-1',
        address: 'Legon, Accra',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(visitor.toJson()['idType'], 'ghana_card');
      expect(Visitor.fromJson(visitor.toJson()), visitor);
    });

    test('Visit derives active state and elapsed duration', () {
      final visit = Visit(
        id: 'visit-1',
        visitorId: 'visitor-1',
        residentId: 'resident-1',
        purpose: 'Academic group work',
        badgeId: 'badge-1',
        badgeNumber: 'V-001',
        checkedInByUserId: 'user-1',
        checkInAt: createdAt,
        status: VisitStatus.checkedIn,
      );

      expect(visit.isActive, isTrue);
      expect(
        visit.durationAt(createdAt.add(const Duration(hours: 2))),
        const Duration(hours: 2),
      );
      expect(Visit.fromJson(visit.toJson()), visit);
    });

    test('Badge availability requires an available unassigned badge', () {
      final badge = VisitorBadge(
        id: 'badge-1',
        badgeNumber: 'V-001',
        status: VisitorBadgeStatus.available,
        createdAt: createdAt,
      );

      expect(badge.isAvailable, isTrue);
      expect(
        badge
            .copyWith(
              status: VisitorBadgeStatus.assigned,
              assignedVisitId: 'visit-1',
            )
            .isAvailable,
        isFalse,
      );
    });

    test('Audit metadata is serialized without losing values', () {
      final log = AuditLog(
        id: 'log-1',
        userId: 'user-1',
        userName: 'Abena Owusu',
        action: AuditAction.checkIn,
        entityType: AuditEntityType.visit,
        entityId: 'visit-1',
        description: 'Visitor checked in',
        timestamp: createdAt,
        metadata: const {'badgeNumber': 'V-001'},
      );

      expect(AuditLog.fromJson(log.toJson()), log);
      expect(log.toJson()['action'], 'check_in');
    });
  });
}
