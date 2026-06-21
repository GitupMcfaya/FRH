// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resident.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Resident {

 String get id; String get studentId; String get fullName; String get phoneNumber; String get block; String get roomNumber; Gender get gender; bool get isActive; DateTime get createdAt; DateTime get updatedAt; String? get programme; String? get emergencyContact;
/// Create a copy of Resident
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResidentCopyWith<Resident> get copyWith => _$ResidentCopyWithImpl<Resident>(this as Resident, _$identity);

  /// Serializes this Resident to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Resident&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.block, block) || other.block == block)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.programme, programme) || other.programme == programme)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,fullName,phoneNumber,block,roomNumber,gender,isActive,createdAt,updatedAt,programme,emergencyContact);

@override
String toString() {
  return 'Resident(id: $id, studentId: $studentId, fullName: $fullName, phoneNumber: $phoneNumber, block: $block, roomNumber: $roomNumber, gender: $gender, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, programme: $programme, emergencyContact: $emergencyContact)';
}


}

/// @nodoc
abstract mixin class $ResidentCopyWith<$Res>  {
  factory $ResidentCopyWith(Resident value, $Res Function(Resident) _then) = _$ResidentCopyWithImpl;
@useResult
$Res call({
 String id, String studentId, String fullName, String phoneNumber, String block, String roomNumber, Gender gender, bool isActive, DateTime createdAt, DateTime updatedAt, String? programme, String? emergencyContact
});




}
/// @nodoc
class _$ResidentCopyWithImpl<$Res>
    implements $ResidentCopyWith<$Res> {
  _$ResidentCopyWithImpl(this._self, this._then);

  final Resident _self;
  final $Res Function(Resident) _then;

/// Create a copy of Resident
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? studentId = null,Object? fullName = null,Object? phoneNumber = null,Object? block = null,Object? roomNumber = null,Object? gender = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? programme = freezed,Object? emergencyContact = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,roomNumber: null == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,programme: freezed == programme ? _self.programme : programme // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Resident].
extension ResidentPatterns on Resident {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Resident value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Resident() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Resident value)  $default,){
final _that = this;
switch (_that) {
case _Resident():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Resident value)?  $default,){
final _that = this;
switch (_that) {
case _Resident() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String studentId,  String fullName,  String phoneNumber,  String block,  String roomNumber,  Gender gender,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? programme,  String? emergencyContact)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Resident() when $default != null:
return $default(_that.id,_that.studentId,_that.fullName,_that.phoneNumber,_that.block,_that.roomNumber,_that.gender,_that.isActive,_that.createdAt,_that.updatedAt,_that.programme,_that.emergencyContact);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String studentId,  String fullName,  String phoneNumber,  String block,  String roomNumber,  Gender gender,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? programme,  String? emergencyContact)  $default,) {final _that = this;
switch (_that) {
case _Resident():
return $default(_that.id,_that.studentId,_that.fullName,_that.phoneNumber,_that.block,_that.roomNumber,_that.gender,_that.isActive,_that.createdAt,_that.updatedAt,_that.programme,_that.emergencyContact);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String studentId,  String fullName,  String phoneNumber,  String block,  String roomNumber,  Gender gender,  bool isActive,  DateTime createdAt,  DateTime updatedAt,  String? programme,  String? emergencyContact)?  $default,) {final _that = this;
switch (_that) {
case _Resident() when $default != null:
return $default(_that.id,_that.studentId,_that.fullName,_that.phoneNumber,_that.block,_that.roomNumber,_that.gender,_that.isActive,_that.createdAt,_that.updatedAt,_that.programme,_that.emergencyContact);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Resident implements Resident {
  const _Resident({required this.id, required this.studentId, required this.fullName, required this.phoneNumber, required this.block, required this.roomNumber, required this.gender, required this.isActive, required this.createdAt, required this.updatedAt, this.programme, this.emergencyContact});
  factory _Resident.fromJson(Map<String, dynamic> json) => _$ResidentFromJson(json);

@override final  String id;
@override final  String studentId;
@override final  String fullName;
@override final  String phoneNumber;
@override final  String block;
@override final  String roomNumber;
@override final  Gender gender;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? programme;
@override final  String? emergencyContact;

/// Create a copy of Resident
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResidentCopyWith<_Resident> get copyWith => __$ResidentCopyWithImpl<_Resident>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResidentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Resident&&(identical(other.id, id) || other.id == id)&&(identical(other.studentId, studentId) || other.studentId == studentId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.block, block) || other.block == block)&&(identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.programme, programme) || other.programme == programme)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,studentId,fullName,phoneNumber,block,roomNumber,gender,isActive,createdAt,updatedAt,programme,emergencyContact);

@override
String toString() {
  return 'Resident(id: $id, studentId: $studentId, fullName: $fullName, phoneNumber: $phoneNumber, block: $block, roomNumber: $roomNumber, gender: $gender, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, programme: $programme, emergencyContact: $emergencyContact)';
}


}

/// @nodoc
abstract mixin class _$ResidentCopyWith<$Res> implements $ResidentCopyWith<$Res> {
  factory _$ResidentCopyWith(_Resident value, $Res Function(_Resident) _then) = __$ResidentCopyWithImpl;
@override @useResult
$Res call({
 String id, String studentId, String fullName, String phoneNumber, String block, String roomNumber, Gender gender, bool isActive, DateTime createdAt, DateTime updatedAt, String? programme, String? emergencyContact
});




}
/// @nodoc
class __$ResidentCopyWithImpl<$Res>
    implements _$ResidentCopyWith<$Res> {
  __$ResidentCopyWithImpl(this._self, this._then);

  final _Resident _self;
  final $Res Function(_Resident) _then;

/// Create a copy of Resident
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? studentId = null,Object? fullName = null,Object? phoneNumber = null,Object? block = null,Object? roomNumber = null,Object? gender = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? programme = freezed,Object? emergencyContact = freezed,}) {
  return _then(_Resident(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,studentId: null == studentId ? _self.studentId : studentId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,block: null == block ? _self.block : block // ignore: cast_nullable_to_non_nullable
as String,roomNumber: null == roomNumber ? _self.roomNumber : roomNumber // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,programme: freezed == programme ? _self.programme : programme // ignore: cast_nullable_to_non_nullable
as String?,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
