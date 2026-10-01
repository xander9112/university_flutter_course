// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_list_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovieListResponse {

 List<MovieDto> get results; int get page;@JsonKey(name: 'total_pages') int get totalPages;
/// Create a copy of MovieListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieListResponseCopyWith<MovieListResponse> get copyWith => _$MovieListResponseCopyWithImpl<MovieListResponse>(this as MovieListResponse, _$identity);

  /// Serializes this MovieListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MovieListResponse;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieListResponse&&const DeepCollectionEquality().equals(other.results, _this.results)&&(identical(other.page, _this.page) || other.page == _this.page)&&(identical(other.totalPages, _this.totalPages) || other.totalPages == _this.totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MovieListResponse;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.results),_this.page,_this.totalPages);
}

@override
String toString() {
  final _this = this as MovieListResponse;
  return 'MovieListResponse(results: ${_this.results}, page: ${_this.page}, totalPages: ${_this.totalPages})';
}


}

/// @nodoc
abstract mixin class $MovieListResponseCopyWith<$Res>  {
  factory $MovieListResponseCopyWith(MovieListResponse value, $Res Function(MovieListResponse) _then) = _$MovieListResponseCopyWithImpl;
@useResult
$Res call({
 List<MovieDto> results, int page,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class _$MovieListResponseCopyWithImpl<$Res>
    implements $MovieListResponseCopyWith<$Res> {
  _$MovieListResponseCopyWithImpl(this._self, this._then);

  final MovieListResponse _self;
  final $Res Function(MovieListResponse) _then;

/// Create a copy of MovieListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? page = null,Object? totalPages = null,}) {
  return _then(MovieListResponse(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<MovieDto>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MovieListResponse].
extension MovieListResponsePatterns on MovieListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieListResponse value)  $default,){
final _that = this;
switch (_that) {
case _MovieListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _MovieListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MovieDto> results,  int page, @JsonKey(name: 'total_pages')  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieListResponse() when $default != null:
return $default(_that.results,_that.page,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MovieDto> results,  int page, @JsonKey(name: 'total_pages')  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _MovieListResponse():
return $default(_that.results,_that.page,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MovieDto> results,  int page, @JsonKey(name: 'total_pages')  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _MovieListResponse() when $default != null:
return $default(_that.results,_that.page,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MovieListResponse implements MovieListResponse {
  const _MovieListResponse({required  List<MovieDto> results, this.page = 1, @JsonKey(name: 'total_pages') this.totalPages = 1}): _results = results;
  factory _MovieListResponse.fromJson(Map<String, dynamic> json) => _$MovieListResponseFromJson(json);

 final  List<MovieDto> _results;
@override List<MovieDto> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int page;
@override@JsonKey(name: 'total_pages') final  int totalPages;

/// Create a copy of MovieListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieListResponseCopyWith<_MovieListResponse> get copyWith => __$MovieListResponseCopyWithImpl<_MovieListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieListResponse&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),page,totalPages);
}

@override
String toString() {
    return 'MovieListResponse(results: $results, page: $page, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$MovieListResponseCopyWith<$Res> implements $MovieListResponseCopyWith<$Res> {
  factory _$MovieListResponseCopyWith(_MovieListResponse value, $Res Function(_MovieListResponse) _then) = __$MovieListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<MovieDto> results, int page,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class __$MovieListResponseCopyWithImpl<$Res>
    implements _$MovieListResponseCopyWith<$Res> {
  __$MovieListResponseCopyWithImpl(this._self, this._then);

  final _MovieListResponse _self;
  final $Res Function(_MovieListResponse) _then;

/// Create a copy of MovieListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? page = null,Object? totalPages = null,}) {
  return _then(_MovieListResponse(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<MovieDto>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
