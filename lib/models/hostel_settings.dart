class HostelSettings {
  const HostelSettings({
    required this.hostelName,
    required this.universityName,
    required this.contactPhone,
    required this.contactEmail,
    required this.visitStartHour,
    required this.visitEndHour,
    required this.maximumVisitMinutes,
    required this.requireVisitorBadge,
    required this.allowWeekendVisits,
  });

  factory HostelSettings.defaults() => const HostelSettings(
    hostelName: 'UniHostel',
    universityName: 'University of Ghana',
    contactPhone: '0302000000',
    contactEmail: 'hostel@university.edu.gh',
    visitStartHour: 8,
    visitEndHour: 21,
    maximumVisitMinutes: 240,
    requireVisitorBadge: true,
    allowWeekendVisits: true,
  );

  factory HostelSettings.fromJson(Map<String, dynamic> json) => HostelSettings(
    hostelName: json['hostelName'] as String,
    universityName: json['universityName'] as String,
    contactPhone: json['contactPhone'] as String,
    contactEmail: json['contactEmail'] as String,
    visitStartHour: json['visitStartHour'] as int,
    visitEndHour: json['visitEndHour'] as int,
    maximumVisitMinutes: json['maximumVisitMinutes'] as int,
    requireVisitorBadge: json['requireVisitorBadge'] as bool,
    allowWeekendVisits: json['allowWeekendVisits'] as bool,
  );

  final String hostelName;
  final String universityName;
  final String contactPhone;
  final String contactEmail;
  final int visitStartHour;
  final int visitEndHour;
  final int maximumVisitMinutes;
  final bool requireVisitorBadge;
  final bool allowWeekendVisits;

  Map<String, dynamic> toJson() => {
    'hostelName': hostelName,
    'universityName': universityName,
    'contactPhone': contactPhone,
    'contactEmail': contactEmail,
    'visitStartHour': visitStartHour,
    'visitEndHour': visitEndHour,
    'maximumVisitMinutes': maximumVisitMinutes,
    'requireVisitorBadge': requireVisitorBadge,
    'allowWeekendVisits': allowWeekendVisits,
  };
}
