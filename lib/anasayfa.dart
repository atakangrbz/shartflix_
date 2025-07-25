import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'bloc/film_bloc.dart';
import 'bloc/film_event.dart';
import 'bloc/film_state.dart';
import 'data/film_repository.dart';
import 'domain/film.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key, required String token});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  late final FilmRepository filmRepository;
  String? token;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    filmRepository = FilmRepository();
    _loadTokenAndInit();
  }

  Future<void> _loadTokenAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');

    if (storedToken == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/giris');
      }
      return;
    }

    token = storedToken;
    filmRepository.updateToken(token!);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return BlocProvider(
      create: (_) => FilmBloc(repository: filmRepository)..add(FilmFetchRequested(page: 1)),
      child: Scaffold(
        backgroundColor: Colors.black,
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

/// Bu fonksiyon, SVG ve diğer resim formatlarını destekler.
Widget getImageWidget(String? url) {
  if (url == null || url.isEmpty) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, color: Colors.white38, size: 60),
        SizedBox(height: 8),
        Text("Görsel yok", style: TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  final lowerUrl = url.toLowerCase();

  if (lowerUrl.endsWith('.svg')) {
    return SvgPicture.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
      height: double.infinity,
    );
  }

  if (lowerUrl.endsWith('.webp') ||
      lowerUrl.endsWith('.jpg') ||
      lowerUrl.endsWith('.jpeg') ||
      lowerUrl.endsWith('.png')) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.white38, size: 60),
          SizedBox(height: 8),
          Text("Görsel yüklenemedi", style: TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      },
    );
  }

  return const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.image_not_supported, color: Colors.white38, size: 60),
      SizedBox(height: 8),
      Text("Desteklenmeyen format", style: TextStyle(color: Colors.white60, fontSize: 12)),
    ],
  );
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
                      onTap: () => _filmSec(film.id as int),
                      child: Card(
                        color: Colors.grey[900],
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: film.id == _selectedFilmId ? Colors.blueAccent : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: getImageWidget(film.posterUrl),
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
                    onPressed: () => _favoriDegistir(context, selectedFilm.id as int),
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
