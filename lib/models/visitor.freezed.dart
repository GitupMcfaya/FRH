// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'visitor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Visitor {

 String get id; String get fullName; String get phoneNumber; VisitorIdType get idType; String get idNumber; String get address; DateTime get createdAt; DateTime get updatedAt; String? get notes; String? get photoPath;
/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisitorCopyWith<Visitor> get copyWith => _$VisitorCopyWithImpl<Visitor>(this as Visitor, _$identity);

  /// Serializes this Visitor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Visitor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,idType,idNumber,address,createdAt,updatedAt,notes,photoPath);

@override
String toString() {
  return 'Visitor(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, idType: $idType, idNumber: $idNumber, address: $address, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class $VisitorCopyWith<$Res>  {
  factory $VisitorCopyWith(Visitor value, $Res Function(Visitor) _then) = _$VisitorCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String phoneNumber, VisitorIdType idType, String idNumber, String address, DateTime createdAt, DateTime updatedAt, String? notes, String? photoPath
});




}
/// @nodoc
class _$VisitorCopyWithImpl<$Res>
    implements $VisitorCopyWith<$Res> {
  _$VisitorCopyWithImpl(this._self, this._then);

  final Visitor _self;
  final $Res Function(Visitor) _then;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phoneNumber = null,Object? idType = null,Object? idNumber = null,Object? address = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? photoPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,idType: null == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as VisitorIdType,idNumber: null == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Visitor].
extension VisitorPatterns on Visitor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Visitor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Visitor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Visitor value)  $default,){
final _that = this;
switch (_that) {
case _Visitor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Visitor value)?  $default,){
final _that = this;
switch (_that) {
case _Visitor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String phoneNumber,  VisitorIdType idType,  String idNumber,  String address,  DateTime createdAt,  DateTime updatedAt,  String? notes,  String? photoPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Visitor() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.idType,_that.idNumber,_that.address,_that.createdAt,_that.updatedAt,_that.notes,_that.photoPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String phoneNumber,  VisitorIdType idType,  String idNumber,  String address,  DateTime createdAt,  DateTime updatedAt,  String? notes,  String? photoPath)  $default,) {final _that = this;
switch (_that) {
case _Visitor():
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.idType,_that.idNumber,_that.address,_that.createdAt,_that.updatedAt,_that.notes,_that.photoPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String phoneNumber,  VisitorIdType idType,  String idNumber,  String address,  DateTime createdAt,  DateTime updatedAt,  String? notes,  String? photoPath)?  $default,) {final _that = this;
switch (_that) {
case _Visitor() when $default != null:
return $default(_that.id,_that.fullName,_that.phoneNumber,_that.idType,_that.idNumber,_that.address,_that.createdAt,_that.updatedAt,_that.notes,_that.photoPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Visitor implements Visitor {
  const _Visitor({required this.id, required this.fullName, required this.phoneNumber, required this.idType, required this.idNumber, required this.address, required this.createdAt, required this.updatedAt, this.notes, this.photoPath});
  factory _Visitor.fromJson(Map<String, dynamic> json) => _$VisitorFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String phoneNumber;
@override final  VisitorIdType idType;
@override final  String idNumber;
@override final  String address;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? notes;
@override final  String? photoPath;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VisitorCopyWith<_Visitor> get copyWith => __$VisitorCopyWithImpl<_Visitor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VisitorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Visitor&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.address, address) || other.address == address)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phoneNumber,idType,idNumber,address,createdAt,updatedAt,notes,photoPath);

@override
String toString() {
  return 'Visitor(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, idType: $idType, idNumber: $idNumber, address: $address, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, photoPath: $photoPath)';
}


}

/// @nodoc
abstract mixin class _$VisitorCopyWith<$Res> implements $VisitorCopyWith<$Res> {
  factory _$VisitorCopyWith(_Visitor value, $Res Function(_Visitor) _then) = __$VisitorCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String phoneNumber, VisitorIdType idType, String idNumber, String address, DateTime createdAt, DateTime updatedAt, String? notes, String? photoPath
});




}
/// @nodoc
class __$VisitorCopyWithImpl<$Res>
    implements _$VisitorCopyWith<$Res> {
  __$VisitorCopyWithImpl(this._self, this._then);

  final _Visitor _self;
  final $Res Function(_Visitor) _then;

/// Create a copy of Visitor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phoneNumber = null,Object? idType = null,Object? idNumber = null,Object? address = null,Object? createdAt = null,Object? updatedAt = null,Object? notes = freezed,Object? photoPath = freezed,}) {
  return _then(_Visitor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,idType: null == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as VisitorIdType,idNumber: null == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
