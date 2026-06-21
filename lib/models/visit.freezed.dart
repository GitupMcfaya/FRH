// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Visit {

 String get id; String get visitorId; String get residentId; String get purpose; String get badgeId; String get badgeNumber; String get checkedInByUserId; DateTime get checkInAt; VisitStatus get status; DateTime? get checkOutAt; String? get checkedOutByUserId; String? get notes;
/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitCopyWith<Visit> get copyWith => _$VisitCopyWithImpl<Visit>(this as Visit, _$identity);

  /// Serializes this Visit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Visit&&(identical(other.id, id) || other.id == id)&&(identical(other.visitorId, visitorId) || other.visitorId == visitorId)&&(identical(other.residentId, residentId) || other.residentId == residentId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.badgeNumber, badgeNumber) || other.badgeNumber == badgeNumber)&&(identical(other.checkedInByUserId, checkedInByUserId) || other.checkedInByUserId == checkedInByUserId)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.checkOutAt, checkOutAt) || other.checkOutAt == checkOutAt)&&(identical(other.checkedOutByUserId, checkedOutByUserId) || other.checkedOutByUserId == checkedOutByUserId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,visitorId,residentId,purpose,badgeId,badgeNumber,checkedInByUserId,checkInAt,status,checkOutAt,checkedOutByUserId,notes);

@override
String toString() {
  return 'Visit(id: $id, visitorId: $visitorId, residentId: $residentId, purpose: $purpose, badgeId: $badgeId, badgeNumber: $badgeNumber, checkedInByUserId: $checkedInByUserId, checkInAt: $checkInAt, status: $status, checkOutAt: $checkOutAt, checkedOutByUserId: $checkedOutByUserId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $VisitCopyWith<$Res>  {
  factory $VisitCopyWith(Visit value, $Res Function(Visit) _then) = _$VisitCopyWithImpl;
@useResult
$Res call({
 String id, String visitorId, String residentId, String purpose, String badgeId, String badgeNumber, String checkedInByUserId, DateTime checkInAt, VisitStatus status, DateTime? checkOutAt, String? checkedOutByUserId, String? notes
});




}
/// @nodoc
class _$VisitCopyWithImpl<$Res>
    implements $VisitCopyWith<$Res> {
  _$VisitCopyWithImpl(this._self, this._then);

  final Visit _self;
  final $Res Function(Visit) _then;

/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? visitorId = null,Object? residentId = null,Object? purpose = null,Object? badgeId = null,Object? badgeNumber = null,Object? checkedInByUserId = null,Object? checkInAt = null,Object? status = null,Object? checkOutAt = freezed,Object? checkedOutByUserId = freezed,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visitorId: null == visitorId ? _self.visitorId : visitorId // ignore: cast_nullable_to_non_nullable
as String,residentId: null == residentId ? _self.residentId : residentId // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,badgeId: null == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String,badgeNumber: null == badgeNumber ? _self.badgeNumber : badgeNumber // ignore: cast_nullable_to_non_nullable
as String,checkedInByUserId: null == checkedInByUserId ? _self.checkedInByUserId : checkedInByUserId // ignore: cast_nullable_to_non_nullable
as String,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitStatus,checkOutAt: freezed == checkOutAt ? _self.checkOutAt : checkOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedOutByUserId: freezed == checkedOutByUserId ? _self.checkedOutByUserId : checkedOutByUserId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Visit].
extension VisitPatterns on Visit {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Visit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Visit() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Visit value)  $default,){
final _that = this;
switch (_that) {
case _Visit():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Visit value)?  $default,){
final _that = this;
switch (_that) {
case _Visit() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String visitorId,  String residentId,  String purpose,  String badgeId,  String badgeNumber,  String checkedInByUserId,  DateTime checkInAt,  VisitStatus status,  DateTime? checkOutAt,  String? checkedOutByUserId,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Visit() when $default != null:
return $default(_that.id,_that.visitorId,_that.residentId,_that.purpose,_that.badgeId,_that.badgeNumber,_that.checkedInByUserId,_that.checkInAt,_that.status,_that.checkOutAt,_that.checkedOutByUserId,_that.notes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String visitorId,  String residentId,  String purpose,  String badgeId,  String badgeNumber,  String checkedInByUserId,  DateTime checkInAt,  VisitStatus status,  DateTime? checkOutAt,  String? checkedOutByUserId,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Visit():
return $default(_that.id,_that.visitorId,_that.residentId,_that.purpose,_that.badgeId,_that.badgeNumber,_that.checkedInByUserId,_that.checkInAt,_that.status,_that.checkOutAt,_that.checkedOutByUserId,_that.notes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String visitorId,  String residentId,  String purpose,  String badgeId,  String badgeNumber,  String checkedInByUserId,  DateTime checkInAt,  VisitStatus status,  DateTime? checkOutAt,  String? checkedOutByUserId,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Visit() when $default != null:
return $default(_that.id,_that.visitorId,_that.residentId,_that.purpose,_that.badgeId,_that.badgeNumber,_that.checkedInByUserId,_that.checkInAt,_that.status,_that.checkOutAt,_that.checkedOutByUserId,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Visit implements Visit {
  const _Visit({required this.id, required this.visitorId, required this.residentId, required this.purpose, required this.badgeId, required this.badgeNumber, required this.checkedInByUserId, required this.checkInAt, required this.status, this.checkOutAt, this.checkedOutByUserId, this.notes});
  factory _Visit.fromJson(Map<String, dynamic> json) => _$VisitFromJson(json);

@override final  String id;
@override final  String visitorId;
@override final  String residentId;
@override final  String purpose;
@override final  String badgeId;
@override final  String badgeNumber;
@override final  String checkedInByUserId;
@override final  DateTime checkInAt;
@override final  VisitStatus status;
@override final  DateTime? checkOutAt;
@override final  String? checkedOutByUserId;
@override final  String? notes;

/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitCopyWith<_Visit> get copyWith => __$VisitCopyWithImpl<_Visit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Visit&&(identical(other.id, id) || other.id == id)&&(identical(other.visitorId, visitorId) || other.visitorId == visitorId)&&(identical(other.residentId, residentId) || other.residentId == residentId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.badgeId, badgeId) || other.badgeId == badgeId)&&(identical(other.badgeNumber, badgeNumber) || other.badgeNumber == badgeNumber)&&(identical(other.checkedInByUserId, checkedInByUserId) || other.checkedInByUserId == checkedInByUserId)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.checkOutAt, checkOutAt) || other.checkOutAt == checkOutAt)&&(identical(other.checkedOutByUserId, checkedOutByUserId) || other.checkedOutByUserId == checkedOutByUserId)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,visitorId,residentId,purpose,badgeId,badgeNumber,checkedInByUserId,checkInAt,status,checkOutAt,checkedOutByUserId,notes);

@override
String toString() {
  return 'Visit(id: $id, visitorId: $visitorId, residentId: $residentId, purpose: $purpose, badgeId: $badgeId, badgeNumber: $badgeNumber, checkedInByUserId: $checkedInByUserId, checkInAt: $checkInAt, status: $status, checkOutAt: $checkOutAt, checkedOutByUserId: $checkedOutByUserId, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$VisitCopyWith<$Res> implements $VisitCopyWith<$Res> {
  factory _$VisitCopyWith(_Visit value, $Res Function(_Visit) _then) = __$VisitCopyWithImpl;
@override @useResult
$Res call({
 String id, String visitorId, String residentId, String purpose, String badgeId, String badgeNumber, String checkedInByUserId, DateTime checkInAt, VisitStatus status, DateTime? checkOutAt, String? checkedOutByUserId, String? notes
});




}
/// @nodoc
class __$VisitCopyWithImpl<$Res>
    implements _$VisitCopyWith<$Res> {
  __$VisitCopyWithImpl(this._self, this._then);

  final _Visit _self;
  final $Res Function(_Visit) _then;

/// Create a copy of Visit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? visitorId = null,Object? residentId = null,Object? purpose = null,Object? badgeId = null,Object? badgeNumber = null,Object? checkedInByUserId = null,Object? checkInAt = null,Object? status = null,Object? checkOutAt = freezed,Object? checkedOutByUserId = freezed,Object? notes = freezed,}) {
  return _then(_Visit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,visitorId: null == visitorId ? _self.visitorId : visitorId // ignore: cast_nullable_to_non_nullable
as String,residentId: null == residentId ? _self.residentId : residentId // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String,badgeId: null == badgeId ? _self.badgeId : badgeId // ignore: cast_nullable_to_non_nullable
as String,badgeNumber: null == badgeNumber ? _self.badgeNumber : badgeNumber // ignore: cast_nullable_to_non_nullable
as String,checkedInByUserId: null == checkedInByUserId ? _self.checkedInByUserId : checkedInByUserId // ignore: cast_nullable_to_non_nullable
as String,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitStatus,checkOutAt: freezed == checkOutAt ? _self.checkOutAt : checkOutAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checkedOutByUserId: freezed == checkedOutByUserId ? _self.checkedOutByUserId : checkedOutByUserId // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
