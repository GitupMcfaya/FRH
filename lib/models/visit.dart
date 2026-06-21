import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_enums.dart';

part 'visit.freezed.dart';
part 'visit.g.dart';

@freezed
abstract class Visit with _$Visit {
  const factory Visit({
    required String id,
    required String visitorId,
    required String residentId,
    required String purpose,
    required String badgeId,
    required String badgeNumber,
    required String checkedInByUserId,
    required DateTime checkInAt,
    required VisitStatus status,
    DateTime? checkOutAt,
    String? checkedOutByUserId,
    String? notes,
  }) = _Visit;

  factory Visit.fromJson(Map<String, dynamic> json) => _$VisitFromJson(json);
}

extension VisitTiming on Visit {
  bool get isActive => status == VisitStatus.checkedIn && checkOutAt == null;

  Duration durationAt(DateTime now) =>
      (checkOutAt ?? now).difference(checkInAt);
}
