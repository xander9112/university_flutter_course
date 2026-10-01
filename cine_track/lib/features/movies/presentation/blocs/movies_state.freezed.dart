// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movies_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MoviesState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoviesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MoviesState()';
}


}

/// @nodoc
class $MoviesStateCopyWith<$Res>  {
$MoviesStateCopyWith(MoviesState _, $Res Function(MoviesState) __);
}


/// Adds pattern-matching-related methods to [MoviesState].
extension MoviesStatePatterns on MoviesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MoviesInitial value)?  initial,TResult Function( MoviesLoading value)?  loading,TResult Function( MoviesLoaded value)?  loaded,TResult Function( MoviesError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MoviesInitial() when initial != null:
return initial(_that);case MoviesLoading() when loading != null:
return loading(_that);case MoviesLoaded() when loaded != null:
return loaded(_that);case MoviesError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MoviesInitial value)  initial,required TResult Function( MoviesLoading value)  loading,required TResult Function( MoviesLoaded value)  loaded,required TResult Function( MoviesError value)  error,}){
final _that = this;
switch (_that) {
case MoviesInitial():
return initial(_that);case MoviesLoading():
return loading(_that);case MoviesLoaded():
return loaded(_that);case MoviesError():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MoviesInitial value)?  initial,TResult? Function( MoviesLoading value)?  loading,TResult? Function( MoviesLoaded value)?  loaded,TResult? Function( MoviesError value)?  error,}){
final _that = this;
switch (_that) {
case MoviesInitial() when initial != null:
return initial(_that);case MoviesLoading() when loading != null:
return loading(_that);case MoviesLoaded() when loaded != null:
return loaded(_that);case MoviesError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Movie> movies)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MoviesInitial() when initial != null:
return initial();case MoviesLoading() when loading != null:
return loading();case MoviesLoaded() when loaded != null:
return loaded(_that.movies);case MoviesError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Movie> movies)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case MoviesInitial():
return initial();case MoviesLoading():
return loading();case MoviesLoaded():
return loaded(_that.movies);case MoviesError():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Movie> movies)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case MoviesInitial() when initial != null:
return initial();case MoviesLoading() when loading != null:
return loading();case MoviesLoaded() when loaded != null:
return loaded(_that.movies);case MoviesError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class MoviesInitial implements MoviesState {
  const MoviesInitial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoviesInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MoviesState.initial()';
}


}




/// @nodoc


class MoviesLoading implements MoviesState {
  const MoviesLoading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoviesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MoviesState.loading()';
}


}




/// @nodoc


class MoviesLoaded implements MoviesState {
  const MoviesLoaded( List<Movie> movies): _movies = movies;
  

 final  List<Movie> _movies;
 List<Movie> get movies {
  if (_movies is EqualUnmodifiableListView) return _movies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movies);
}


/// Create a copy of MoviesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoviesLoadedCopyWith<MoviesLoaded> get copyWith => _$MoviesLoadedCopyWithImpl<MoviesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoviesLoaded&&const DeepCollectionEquality().equals(other.movies, _movies));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_movies));
}

@override
String toString() {
    return 'MoviesState.loaded(movies: $movies)';
}


}

/// @nodoc
abstract mixin class $MoviesLoadedCopyWith<$Res> implements $MoviesStateCopyWith<$Res> {
  factory $MoviesLoadedCopyWith(MoviesLoaded value, $Res Function(MoviesLoaded) _then) = _$MoviesLoadedCopyWithImpl;
@useResult
$Res call({
 List<Movie> movies
});




}
/// @nodoc
class _$MoviesLoadedCopyWithImpl<$Res>
    implements $MoviesLoadedCopyWith<$Res> {
  _$MoviesLoadedCopyWithImpl(this._self, this._then);

  final MoviesLoaded _self;
  final $Res Function(MoviesLoaded) _then;

/// Create a copy of MoviesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movies = null,}) {
  return _then(MoviesLoaded(
null == movies ? _self._movies : movies // ignore: cast_nullable_to_non_nullable
as List<Movie>,
  ));
}


}

/// @nodoc


class MoviesError implements MoviesState {
  const MoviesError(this.message);
  

 final  String message;

/// Create a copy of MoviesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoviesErrorCopyWith<MoviesError> get copyWith => _$MoviesErrorCopyWithImpl<MoviesError>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoviesError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'MoviesState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $MoviesErrorCopyWith<$Res> implements $MoviesStateCopyWith<$Res> {
  factory $MoviesErrorCopyWith(MoviesError value, $Res Function(MoviesError) _then) = _$MoviesErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$MoviesErrorCopyWithImpl<$Res>
    implements $MoviesErrorCopyWith<$Res> {
  _$MoviesErrorCopyWithImpl(this._self, this._then);

  final MoviesError _self;
  final $Res Function(MoviesError) _then;

/// Create a copy of MoviesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MoviesError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
