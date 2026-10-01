// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movies_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MoviesEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MoviesEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MoviesEvent()';
}


}

/// @nodoc
class $MoviesEventCopyWith<$Res>  {
$MoviesEventCopyWith(MoviesEvent _, $Res Function(MoviesEvent) __);
}


/// Adds pattern-matching-related methods to [MoviesEvent].
extension MoviesEventPatterns on MoviesEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoadMovies value)?  load,TResult Function( RefreshMovies value)?  refresh,TResult Function( SearchMoviesRequested value)?  search,TResult Function( AddMovie value)?  add,TResult Function( RemoveMovie value)?  remove,TResult Function( ShuffleMovies value)?  shuffle,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoadMovies() when load != null:
return load(_that);case RefreshMovies() when refresh != null:
return refresh(_that);case SearchMoviesRequested() when search != null:
return search(_that);case AddMovie() when add != null:
return add(_that);case RemoveMovie() when remove != null:
return remove(_that);case ShuffleMovies() when shuffle != null:
return shuffle(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoadMovies value)  load,required TResult Function( RefreshMovies value)  refresh,required TResult Function( SearchMoviesRequested value)  search,required TResult Function( AddMovie value)  add,required TResult Function( RemoveMovie value)  remove,required TResult Function( ShuffleMovies value)  shuffle,}){
final _that = this;
switch (_that) {
case LoadMovies():
return load(_that);case RefreshMovies():
return refresh(_that);case SearchMoviesRequested():
return search(_that);case AddMovie():
return add(_that);case RemoveMovie():
return remove(_that);case ShuffleMovies():
return shuffle(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoadMovies value)?  load,TResult? Function( RefreshMovies value)?  refresh,TResult? Function( SearchMoviesRequested value)?  search,TResult? Function( AddMovie value)?  add,TResult? Function( RemoveMovie value)?  remove,TResult? Function( ShuffleMovies value)?  shuffle,}){
final _that = this;
switch (_that) {
case LoadMovies() when load != null:
return load(_that);case RefreshMovies() when refresh != null:
return refresh(_that);case SearchMoviesRequested() when search != null:
return search(_that);case AddMovie() when add != null:
return add(_that);case RemoveMovie() when remove != null:
return remove(_that);case ShuffleMovies() when shuffle != null:
return shuffle(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  load,TResult Function( Completer<void>? completer)?  refresh,TResult Function( String query)?  search,TResult Function( Movie movie)?  add,TResult Function( int movieId)?  remove,TResult Function()?  shuffle,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoadMovies() when load != null:
return load();case RefreshMovies() when refresh != null:
return refresh(_that.completer);case SearchMoviesRequested() when search != null:
return search(_that.query);case AddMovie() when add != null:
return add(_that.movie);case RemoveMovie() when remove != null:
return remove(_that.movieId);case ShuffleMovies() when shuffle != null:
return shuffle();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  load,required TResult Function( Completer<void>? completer)  refresh,required TResult Function( String query)  search,required TResult Function( Movie movie)  add,required TResult Function( int movieId)  remove,required TResult Function()  shuffle,}) {final _that = this;
switch (_that) {
case LoadMovies():
return load();case RefreshMovies():
return refresh(_that.completer);case SearchMoviesRequested():
return search(_that.query);case AddMovie():
return add(_that.movie);case RemoveMovie():
return remove(_that.movieId);case ShuffleMovies():
return shuffle();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  load,TResult? Function( Completer<void>? completer)?  refresh,TResult? Function( String query)?  search,TResult? Function( Movie movie)?  add,TResult? Function( int movieId)?  remove,TResult? Function()?  shuffle,}) {final _that = this;
switch (_that) {
case LoadMovies() when load != null:
return load();case RefreshMovies() when refresh != null:
return refresh(_that.completer);case SearchMoviesRequested() when search != null:
return search(_that.query);case AddMovie() when add != null:
return add(_that.movie);case RemoveMovie() when remove != null:
return remove(_that.movieId);case ShuffleMovies() when shuffle != null:
return shuffle();case _:
  return null;

}
}

}

/// @nodoc


class LoadMovies implements MoviesEvent {
  const LoadMovies();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadMovies);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MoviesEvent.load()';
}


}




/// @nodoc


class RefreshMovies implements MoviesEvent {
  const RefreshMovies({this.completer});
  

 final  Completer<void>? completer;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RefreshMoviesCopyWith<RefreshMovies> get copyWith => _$RefreshMoviesCopyWithImpl<RefreshMovies>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RefreshMovies&&(identical(other.completer, completer) || other.completer == completer));
}


@override
int get hashCode {
    return Object.hash(runtimeType,completer);
}

@override
String toString() {
    return 'MoviesEvent.refresh(completer: $completer)';
}


}

/// @nodoc
abstract mixin class $RefreshMoviesCopyWith<$Res> implements $MoviesEventCopyWith<$Res> {
  factory $RefreshMoviesCopyWith(RefreshMovies value, $Res Function(RefreshMovies) _then) = _$RefreshMoviesCopyWithImpl;
@useResult
$Res call({
 Completer<void>? completer
});




}
/// @nodoc
class _$RefreshMoviesCopyWithImpl<$Res>
    implements $RefreshMoviesCopyWith<$Res> {
  _$RefreshMoviesCopyWithImpl(this._self, this._then);

  final RefreshMovies _self;
  final $Res Function(RefreshMovies) _then;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? completer = freezed,}) {
  return _then(RefreshMovies(
completer: freezed == completer ? _self.completer : completer // ignore: cast_nullable_to_non_nullable
as Completer<void>?,
  ));
}


}

/// @nodoc


class SearchMoviesRequested implements MoviesEvent {
  const SearchMoviesRequested(this.query);
  

 final  String query;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchMoviesRequestedCopyWith<SearchMoviesRequested> get copyWith => _$SearchMoviesRequestedCopyWithImpl<SearchMoviesRequested>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchMoviesRequested&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode {
    return Object.hash(runtimeType,query);
}

@override
String toString() {
    return 'MoviesEvent.search(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchMoviesRequestedCopyWith<$Res> implements $MoviesEventCopyWith<$Res> {
  factory $SearchMoviesRequestedCopyWith(SearchMoviesRequested value, $Res Function(SearchMoviesRequested) _then) = _$SearchMoviesRequestedCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SearchMoviesRequestedCopyWithImpl<$Res>
    implements $SearchMoviesRequestedCopyWith<$Res> {
  _$SearchMoviesRequestedCopyWithImpl(this._self, this._then);

  final SearchMoviesRequested _self;
  final $Res Function(SearchMoviesRequested) _then;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(SearchMoviesRequested(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AddMovie implements MoviesEvent {
  const AddMovie(this.movie);
  

 final  Movie movie;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddMovieCopyWith<AddMovie> get copyWith => _$AddMovieCopyWithImpl<AddMovie>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is AddMovie&&(identical(other.movie, movie) || other.movie == movie));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movie);
}

@override
String toString() {
    return 'MoviesEvent.add(movie: $movie)';
}


}

/// @nodoc
abstract mixin class $AddMovieCopyWith<$Res> implements $MoviesEventCopyWith<$Res> {
  factory $AddMovieCopyWith(AddMovie value, $Res Function(AddMovie) _then) = _$AddMovieCopyWithImpl;
@useResult
$Res call({
 Movie movie
});


$MovieCopyWith<$Res> get movie;

}
/// @nodoc
class _$AddMovieCopyWithImpl<$Res>
    implements $AddMovieCopyWith<$Res> {
  _$AddMovieCopyWithImpl(this._self, this._then);

  final AddMovie _self;
  final $Res Function(AddMovie) _then;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movie = null,}) {
  return _then(AddMovie(
null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as Movie,
  ));
}

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieCopyWith<$Res> get movie {
  
  return $MovieCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}

/// @nodoc


class RemoveMovie implements MoviesEvent {
  const RemoveMovie(this.movieId);
  

 final  int movieId;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoveMovieCopyWith<RemoveMovie> get copyWith => _$RemoveMovieCopyWithImpl<RemoveMovie>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoveMovie&&(identical(other.movieId, movieId) || other.movieId == movieId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,movieId);
}

@override
String toString() {
    return 'MoviesEvent.remove(movieId: $movieId)';
}


}

/// @nodoc
abstract mixin class $RemoveMovieCopyWith<$Res> implements $MoviesEventCopyWith<$Res> {
  factory $RemoveMovieCopyWith(RemoveMovie value, $Res Function(RemoveMovie) _then) = _$RemoveMovieCopyWithImpl;
@useResult
$Res call({
 int movieId
});




}
/// @nodoc
class _$RemoveMovieCopyWithImpl<$Res>
    implements $RemoveMovieCopyWith<$Res> {
  _$RemoveMovieCopyWithImpl(this._self, this._then);

  final RemoveMovie _self;
  final $Res Function(RemoveMovie) _then;

/// Create a copy of MoviesEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? movieId = null,}) {
  return _then(RemoveMovie(
null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ShuffleMovies implements MoviesEvent {
  const ShuffleMovies();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ShuffleMovies);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MoviesEvent.shuffle()';
}


}




// dart format on
