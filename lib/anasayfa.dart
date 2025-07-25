import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/film_bloc.dart';
import 'bloc/film_event.dart';
import 'bloc/film_state.dart';
import 'domain/film.dart';
import 'data/film_repository.dart';

class Anasayfa extends StatelessWidget {
  const Anasayfa({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FilmBloc(repository: FilmRepository())..add(FilmFetchRequested(page: 1)),
      child: Scaffold(
        backgroundColor: Colors.black, // Arka plan siyah
        appBar: AppBar(
          title: const Text("Film Listesi"),
          backgroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const FilmList(),
      ),
    );
  }
}

class FilmList extends StatefulWidget {
  const FilmList({super.key});

  @override
  State<FilmList> createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilmId = 0;

  void _setupScrollController(BuildContext context) {
    _scrollController.addListener(() {
      final bloc = context.read<FilmBloc>();
      final state = bloc.state;

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
          state is FilmLoadSuccess &&
          state.hasMore) {
        bloc.add(FilmFetchRequested(page: bloc.currentPage + 1));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupScrollController(context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _favoriDegistir(BuildContext context, int filmId) {
    context.read<FilmBloc>().add(FilmToggleFavorite(filmId));
  }

  void _filmSec(int filmId) {
    setState(() {
      _selectedFilmId = filmId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilmBloc, FilmState>(
      builder: (context, state) {
        if (state is FilmLoadInProgress && state.props.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (state is FilmLoadSuccess) {
          final Film? selectedFilm = state.films.isNotEmpty
              ? state.films.firstWhere(
                  (film) => film.id == _selectedFilmId,
                  orElse: () => state.films.first,
                )
              : null;

          return Stack(
            children: [
              GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.films.length + (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < state.films.length) {
                    final film = state.films[index];
                    return GestureDetector(
                      onTap: () => _filmSec(int.parse(film.id as String)),
                      child: Card(
                        color: Colors.grey[900],
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: film.id == _selectedFilmId.toString() ? Colors.blueAccent : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: Icon(
                                  Icons.movie,
                                  size: 60,
                                  color: Colors.blueGrey.shade300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                film.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                },
              ),

              if (selectedFilm != null)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () => _favoriDegistir(context, int.parse(selectedFilm.id as String)),
                    backgroundColor: selectedFilm.isFavorite ? Colors.red : Colors.grey,
                    child: Icon(
                      selectedFilm.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 30,
                    ),
                    tooltip: selectedFilm.isFavorite ? "Beğeniyi kaldır" : "Beğen",
                  ),
                ),
            ],
          );
        } else if (state is FilmLoadFailure) {
          return Center(
            child: Text(
              "Hata: ${state.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        } else {
          return const Center(
            child: Text(
              "Bir şeyler ters gitti.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
}
