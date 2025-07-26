import 'package:equatable/equatable.dart';
import '../domain/film.dart';

abstract class FilmState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FilmInitial extends FilmState {}

class FilmLoadInProgress extends FilmState {}

class FilmLoadSuccess extends FilmState {
  final List<Film> films;
  final bool hasMore;

  FilmLoadSuccess(this.films, {this.hasMore = true, required int currentPage});

  @override
  List<Object?> get props => [films, hasMore];
}

class FilmLoadFailure extends FilmState {
  final String error;

  FilmLoadFailure(this.error);

  @override
  List<Object?> get props => [error];
}
