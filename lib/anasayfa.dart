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
        appBar: AppBar(title: const Text("Film Listesi")),
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilmBloc, FilmState>(
      builder: (context, state) {
        if (state is FilmLoadInProgress && state.props.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is FilmLoadSuccess) {
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 sütun
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: state.films.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < state.films.length) {
                final film = state.films[index];
                return Card(
                  elevation: 4,
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        IconButton(
                          icon: Icon(
                            film.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: film.isFavorite ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _favoriDegistir(context, film.id),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        } else if (state is FilmLoadFailure) {
          return Center(child: Text("Hata: ${state.error}"));
        } else {
          return const Center(child: Text("Bir şeyler ters gitti."));
        }
      },
    );
  }
}
