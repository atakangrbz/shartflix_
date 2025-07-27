import 'package:equatable/equatable.dart';

abstract class FilmEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FilmFetchRequested extends FilmEvent {
  final int page;

  FilmFetchRequested({required this.page, required bool fetchAll});

  @override
  List<Object?> get props => [page];
}

class FilmToggleFavorite extends FilmEvent {
  final String filmId;

  FilmToggleFavorite(this.filmId);

  @override
  List<Object?> get props => [filmId];
}
