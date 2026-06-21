import 'package:freezed_annotation/freezed_annotation.dart';

import 'model_enums.dart';

part 'visitor.freezed.dart';
part 'visitor.g.dart';

@freezed
abstract class Visitor with _$Visitor {
  const factory Visitor({
    required String id,
    required String fullName,
    required String phoneNumber,
    required VisitorIdType idType,
    required String idNumber,
    required String address,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? notes,
    String? photoPath,
  }) = _Visitor;

  factory Visitor.fromJson(Map<String, dynamic> json) =>
      _$VisitorFromJson(json);
}
