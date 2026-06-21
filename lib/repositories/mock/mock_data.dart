import '../../models/models.dart';

abstract final class MockData {
  static List<User> users(DateTime now) => [
    User(
      id: 'user-admin-001',
      fullName: 'Abena Owusu',
      email: 'admin@unihostel.edu.gh',
      role: UserRole.administrator,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 400)),
      lastLoginAt: now.subtract(const Duration(days: 1)),
    ),
    User(
      id: 'user-reception-001',
      fullName: 'Esi Addo',
      email: 'reception@unihostel.edu.gh',
      role: UserRole.receptionist,
      isActive: true,
      createdAt: now.subtract(const Duration(days: 250)),
      lastLoginAt: now.subtract(const Duration(hours: 8)),
    ),
  ];

  static List<Resident> residents(DateTime now) => [
    Resident(
      id: 'resident-001',
      studentId: 'UG1234567',
      fullName: 'Ama Mensah',
      phoneNumber: '0241234567',
      block: 'A',
      roomNumber: '204',
      gender: Gender.female,
      isActive: true,
      programme: 'BSc Computer Science',
      emergencyContact: '0201112233',
      createdAt: now.subtract(const Duration(days: 180)),
      updatedAt: now.subtract(const Duration(days: 20)),
    ),
    Resident(
      id: 'resident-002',
      studentId: 'UG7654321',
      fullName: 'Samuel Tetteh',
      phoneNumber: '0559876543',
      block: 'B',
      roomNumber: '112',
      gender: Gender.male,
      isActive: true,
      programme: 'BA Economics',
      createdAt: now.subtract(const Duration(days: 175)),
      updatedAt: now.subtract(const Duration(days: 12)),
    ),
    Resident(
      id: 'resident-003',
      studentId: 'KNUST2026123',
      fullName: 'Naa Dedei Lartey',
      phoneNumber: '0203456789',
      block: 'C',
      roomNumber: '308',
      gender: Gender.female,
      isActive: true,
      programme: 'BSc Architecture',
      createdAt: now.subtract(const Duration(days: 160)),
      updatedAt: now.subtract(const Duration(days: 8)),
    ),
    Resident(
      id: 'resident-004',
      studentId: 'UCC20250098',
      fullName: 'Yaw Ofori',
      phoneNumber: '0275550198',
      block: 'A',
      roomNumber: '105',
      gender: Gender.male,
      isActive: false,
      programme: 'BCom Accounting',
      createdAt: now.subtract(const Duration(days: 420)),
      updatedAt: now.subtract(const Duration(days: 35)),
    ),
  ];

  static List<Visitor> visitors(DateTime now) => [
    Visitor(
      id: 'visitor-001',
      fullName: 'Kwame Mensah',
      phoneNumber: '0244441111',
      idType: VisitorIdType.ghanaCard,
      idNumber: 'GHA-123456789-1',
      address: 'Madina, Accra',
      createdAt: now.subtract(const Duration(days: 60)),
      updatedAt: now.subtract(const Duration(days: 10)),
    ),
    Visitor(
      id: 'visitor-002',
      fullName: 'Nana Yaa Asante',
      phoneNumber: '0552228877',
      idType: VisitorIdType.studentReferenceNumber,
      idNumber: 'SRC20260012',
      address: 'Adenta, Accra',
      notes: 'Frequent family visitor',
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now.subtract(const Duration(days: 3)),
    ),
    Visitor(
      id: 'visitor-003',
      fullName: 'Kofi Boateng',
      phoneNumber: '0203334466',
      idType: VisitorIdType.studentReferenceNumber,
      idNumber: 'SRC20260037',
      address: 'East Legon, Accra',
      createdAt: now.subtract(const Duration(days: 40)),
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
  ];

  static List<VisitorBadge> badges(DateTime now) => [
    VisitorBadge(
      id: 'badge-001',
      badgeNumber: 'V-001',
      status: VisitorBadgeStatus.assigned,
      assignedVisitId: 'visit-001',
      createdAt: now.subtract(const Duration(days: 365)),
    ),
    for (var number = 2; number <= 10; number++)
      VisitorBadge(
        id: 'badge-${number.toString().padLeft(3, '0')}',
        badgeNumber: 'V-${number.toString().padLeft(3, '0')}',
        status: VisitorBadgeStatus.available,
        createdAt: now.subtract(const Duration(days: 365)),
      ),
  ];

  static List<Visit> visits(DateTime now) => [
    Visit(
      id: 'visit-001',
      visitorId: 'visitor-001',
      residentId: 'resident-001',
      purpose: 'Family visit',
      badgeId: 'badge-001',
      badgeNumber: 'V-001',
      checkedInByUserId: 'user-reception-001',
      checkInAt: now.subtract(const Duration(minutes: 48)),
      status: VisitStatus.checkedIn,
    ),
    Visit(
      id: 'visit-002',
      visitorId: 'visitor-002',
      residentId: 'resident-002',
      purpose: 'Deliver personal items',
      badgeId: 'badge-008',
      badgeNumber: 'V-008',
      checkedInByUserId: 'user-reception-001',
      checkedOutByUserId: 'user-reception-001',
      checkInAt: now.subtract(const Duration(hours: 3)),
      checkOutAt: now.subtract(const Duration(hours: 2)),
      status: VisitStatus.checkedOut,
    ),
    Visit(
      id: 'visit-003',
      visitorId: 'visitor-003',
      residentId: 'resident-002',
      purpose: 'Academic group work',
      badgeId: 'badge-004',
      badgeNumber: 'V-004',
      checkedInByUserId: 'user-reception-001',
      checkedOutByUserId: 'user-reception-001',
      checkInAt: now.subtract(const Duration(days: 1, hours: 2)),
      checkOutAt: now.subtract(const Duration(days: 1)),
      status: VisitStatus.checkedOut,
    ),
    for (var number = 4; number <= 15; number++)
      Visit(
        id: 'visit-${number.toString().padLeft(3, '0')}',
        visitorId:
            'visitor-${(((number - 1) % 3) + 1).toString().padLeft(3, '0')}',
        residentId:
            'resident-${(((number - 1) % 3) + 1).toString().padLeft(3, '0')}',
        purpose: switch (number % 4) {
          0 => 'Family visit',
          1 => 'Academic group work',
          2 => 'Deliver personal items',
          _ => 'Social visit',
        },
        badgeId: 'badge-${(((number - 2) % 9) + 2).toString().padLeft(3, '0')}',
        badgeNumber: 'V-${(((number - 2) % 9) + 2).toString().padLeft(3, '0')}',
        checkedInByUserId: 'user-reception-001',
        checkedOutByUserId: 'user-reception-001',
        checkInAt: now.subtract(Duration(days: number - 2, hours: 3)),
        checkOutAt: now.subtract(Duration(days: number - 2, hours: 1)),
        status: VisitStatus.checkedOut,
      ),
  ];
}
