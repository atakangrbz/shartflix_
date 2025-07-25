import 'package:flutter_bloc/flutter_bloc.dart';
import 'film_event.dart';
import 'film_state.dart';
import '../data/film_repository.dart';
import '../domain/film.dart';

class FilmBloc extends Bloc<FilmEvent, FilmState> {
  final FilmRepository repository;
  int currentPage = 1;
  final int pageSize = 5;
  bool isFetching = false;
  List<Film> films = [];

  FilmBloc({required this.repository}) : super(FilmInitial()) {
    on<FilmFetchRequested>(_onFetchRequested);
    on<FilmToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onFetchRequested(FilmFetchRequested event, Emitter<FilmState> emit) async {
    if (isFetching) return;
    isFetching = true;

    if (event.page == 1) {
      films.clear();
    }

    try {
      emit(FilmLoadInProgress());
      final newFilms = await repository.fetchFilms(page: event.page, pageSize: pageSize);
      films.addAll(newFilms);

      films.sort((a, b) => a.id.compareTo(b.id));

      final hasMore = newFilms.length == pageSize;
      currentPage = event.page;
      emit(FilmLoadSuccess(films, hasMore: hasMore));
    } catch (e) {
      emit(FilmLoadFailure(e.toString()));
    }

    isFetching = false;
  }

  Future<void> _onToggleFavorite(FilmToggleFavorite event, Emitter<FilmState> emit) async {
    try {
      await repository.toggleFavorite(event.filmId as String);

      films = films.map((film) {
        if (film.id == event.filmId) {
          return film.copyWith(isFavorite: !film.isFavorite);
        }
        return film;
      }).toList();

      emit(FilmLoadSuccess(films, hasMore: true));
    } catch (e) {
      emit(FilmLoadFailure(e.toString()));
    }
  }
}



