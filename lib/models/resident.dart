import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_enums.dart';

part 'resident.freezed.dart';
part 'resident.g.dart';

@freezed
abstract class Resident with _$Resident {
  const factory Resident({
    required String id,
    required String studentId,
    required String fullName,
    required String phoneNumber,
    required String block,
    required String roomNumber,
    required Gender gender,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? programme,
    String? emergencyContact,
  }) = _Resident;

  factory Resident.fromJson(Map<String, dynamic> json) =>
      _$ResidentFromJson(json);
}

extension ResidentDisplay on Resident {
  String get roomLabel => 'Block $block · Room $roomNumber';
}
