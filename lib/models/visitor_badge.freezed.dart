// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visitor_badge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VisitorBadge {

 String get id; String get badgeNumber; VisitorBadgeStatus get status; DateTime get createdAt; String? get assignedVisitId;
/// Create a copy of VisitorBadge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitorBadgeCopyWith<VisitorBadge> get copyWith => _$VisitorBadgeCopyWithImpl<VisitorBadge>(this as VisitorBadge, _$identity);

  /// Serializes this VisitorBadge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisitorBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.badgeNumber, badgeNumber) || other.badgeNumber == badgeNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.assignedVisitId, assignedVisitId) || other.assignedVisitId == assignedVisitId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,badgeNumber,status,createdAt,assignedVisitId);

@override
String toString() {
  return 'VisitorBadge(id: $id, badgeNumber: $badgeNumber, status: $status, createdAt: $createdAt, assignedVisitId: $assignedVisitId)';
}


}

/// @nodoc
abstract mixin class $VisitorBadgeCopyWith<$Res>  {
  factory $VisitorBadgeCopyWith(VisitorBadge value, $Res Function(VisitorBadge) _then) = _$VisitorBadgeCopyWithImpl;
@useResult
$Res call({
 String id, String badgeNumber, VisitorBadgeStatus status, DateTime createdAt, String? assignedVisitId
});




}
/// @nodoc
class _$VisitorBadgeCopyWithImpl<$Res>
    implements $VisitorBadgeCopyWith<$Res> {
  _$VisitorBadgeCopyWithImpl(this._self, this._then);

  final VisitorBadge _self;
  final $Res Function(VisitorBadge) _then;

/// Create a copy of VisitorBadge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? badgeNumber = null,Object? status = null,Object? createdAt = null,Object? assignedVisitId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,badgeNumber: null == badgeNumber ? _self.badgeNumber : badgeNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitorBadgeStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedVisitId: freezed == assignedVisitId ? _self.assignedVisitId : assignedVisitId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VisitorBadge].
extension VisitorBadgePatterns on VisitorBadge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VisitorBadge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VisitorBadge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VisitorBadge value)  $default,){
final _that = this;
switch (_that) {
case _VisitorBadge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VisitorBadge value)?  $default,){
final _that = this;
switch (_that) {
case _VisitorBadge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String badgeNumber,  VisitorBadgeStatus status,  DateTime createdAt,  String? assignedVisitId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VisitorBadge() when $default != null:
return $default(_that.id,_that.badgeNumber,_that.status,_that.createdAt,_that.assignedVisitId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String badgeNumber,  VisitorBadgeStatus status,  DateTime createdAt,  String? assignedVisitId)  $default,) {final _that = this;
switch (_that) {
case _VisitorBadge():
return $default(_that.id,_that.badgeNumber,_that.status,_that.createdAt,_that.assignedVisitId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String badgeNumber,  VisitorBadgeStatus status,  DateTime createdAt,  String? assignedVisitId)?  $default,) {final _that = this;
switch (_that) {
case _VisitorBadge() when $default != null:
return $default(_that.id,_that.badgeNumber,_that.status,_that.createdAt,_that.assignedVisitId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VisitorBadge implements VisitorBadge {
  const _VisitorBadge({required this.id, required this.badgeNumber, required this.status, required this.createdAt, this.assignedVisitId});
  factory _VisitorBadge.fromJson(Map<String, dynamic> json) => _$VisitorBadgeFromJson(json);

@override final  String id;
@override final  String badgeNumber;
@override final  VisitorBadgeStatus status;
@override final  DateTime createdAt;
@override final  String? assignedVisitId;

/// Create a copy of VisitorBadge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitorBadgeCopyWith<_VisitorBadge> get copyWith => __$VisitorBadgeCopyWithImpl<_VisitorBadge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitorBadgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VisitorBadge&&(identical(other.id, id) || other.id == id)&&(identical(other.badgeNumber, badgeNumber) || other.badgeNumber == badgeNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.assignedVisitId, assignedVisitId) || other.assignedVisitId == assignedVisitId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,badgeNumber,status,createdAt,assignedVisitId);

@override
String toString() {
  return 'VisitorBadge(id: $id, badgeNumber: $badgeNumber, status: $status, createdAt: $createdAt, assignedVisitId: $assignedVisitId)';
}


}

/// @nodoc
abstract mixin class _$VisitorBadgeCopyWith<$Res> implements $VisitorBadgeCopyWith<$Res> {
  factory _$VisitorBadgeCopyWith(_VisitorBadge value, $Res Function(_VisitorBadge) _then) = __$VisitorBadgeCopyWithImpl;
@override @useResult
$Res call({
 String id, String badgeNumber, VisitorBadgeStatus status, DateTime createdAt, String? assignedVisitId
});




}
/// @nodoc
class __$VisitorBadgeCopyWithImpl<$Res>
    implements _$VisitorBadgeCopyWith<$Res> {
  __$VisitorBadgeCopyWithImpl(this._self, this._then);

  final _VisitorBadge _self;
  final $Res Function(_VisitorBadge) _then;

/// Create a copy of VisitorBadge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? badgeNumber = null,Object? status = null,Object? createdAt = null,Object? assignedVisitId = freezed,}) {
  return _then(_VisitorBadge(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,badgeNumber: null == badgeNumber ? _self.badgeNumber : badgeNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VisitorBadgeStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignedVisitId: freezed == assignedVisitId ? _self.assignedVisitId : assignedVisitId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
