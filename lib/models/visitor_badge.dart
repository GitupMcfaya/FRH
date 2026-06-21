import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_enums.dart';

part 'visitor_badge.freezed.dart';
part 'visitor_badge.g.dart';

@freezed
abstract class VisitorBadge with _$VisitorBadge {
  const factory VisitorBadge({
    required String id,
    required String badgeNumber,
    required VisitorBadgeStatus status,
    required DateTime createdAt,
    String? assignedVisitId,
  }) = _VisitorBadge;

  factory VisitorBadge.fromJson(Map<String, dynamic> json) =>
      _$VisitorBadgeFromJson(json);
}

extension VisitorBadgeAvailability on VisitorBadge {
  bool get isAvailable =>
      status == VisitorBadgeStatus.available && assignedVisitId == null;
}
