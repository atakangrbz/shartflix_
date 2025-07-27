// Kodun geri kalani sabit, sadece favori butonuna tiklandiginda token al ve API'ye istegi gonder

// Kodun geri kalani sabit, sadece favori butonuna tiklandiginda token al ve API'ye istegi gonder

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shartflix_/film_sayfasi.dart';
import 'dart:convert';

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

  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return BlocProvider(
      create: (_) => FilmBloc(repository: filmRepository)..add(FilmFetchRequested(page: 1,fetchAll: true)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/SinFlixSplash.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.6)),
            Column(
              children: [
                AppBar(
                  title: const Text(
                    "Anasayfa",
                    style: TextStyle(color: Colors.red),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                ),
                const Expanded(child: FilmList()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> addToFavorites(String filmId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    print('Token bulunamadı.');
    return;
  }

  final url = Uri.parse('https://caseapi.servicelabs.tech/movie/favorite/$filmId');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print("Favorilere eklendi: $filmId");
  } else {
    print("Favori ekleme hatası: ${response.statusCode} - ${response.body}");
  }
}

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

  url = url.replaceFirst('http://', 'https://'); // URL düzeltildi

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

// FilmList sınıfında herhangi bir düzenleme yapılmasına gerek kalmadı çünkü getImageWidget() içindeki URL düzeltmesi tüm kullanımı etkiler.


class FilmList extends StatefulWidget {
  const FilmList({super.key});

  @override
  State<FilmList> createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilmId = 0;
  bool _showTopList = true;
  double _lastOffset = 0;

  void _setupScrollController(BuildContext context) {
    _scrollController.addListener(() {
      final bloc = context.read<FilmBloc>();
      final state = bloc.state;

      // Sonsuz scroll
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
          state is FilmLoadSuccess &&
          state.hasMore) {
        bloc.add(FilmFetchRequested(page: bloc.currentPage + 1, fetchAll: true));
      }

      // Yukarı/aşağı kaydırmayı algıla
      final currentOffset = _scrollController.offset;

      if (currentOffset > _lastOffset && _showTopList) {
        setState(() {
          _showTopList = false;
        });
      } else if (currentOffset < _lastOffset && !_showTopList) {
        setState(() {
          _showTopList = true;
        });
      }

      _lastOffset = currentOffset;
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
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showTopList ? 180 : 0,
                child: AnimatedOpacity(
                  opacity: _showTopList ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.films.length > 10 ? 10 : state.films.length,
                      itemBuilder: (context, index) {
                        final film = state.films[index];
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: getImageWidget(film.posterUrl),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<FilmBloc>().add(FilmToggleFavorite(film.id));
                                          addToFavorites(film.id);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            film.isFavorite ? Icons.favorite : Icons.favorite_border,
                                            color: film.isFavorite ? Colors.red : Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                film.title,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                film.description,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
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
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilmSayfasi(
          title: film.title,
          description: film.description,
          posterUrl: film.posterUrl,
        ),
      ),
    );
  },
  child: Container(
    width: 120,
    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: getImageWidget(film.posterUrl),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    context.read<FilmBloc>().add(FilmToggleFavorite(film.id));
                    addToFavorites(film.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      film.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: film.isFavorite ? Colors.red : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          film.title,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          film.description,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  ),
);

                    } else {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                  },
                ),
              ),
            ],
          );
        } else if (state is FilmLoadFailure) {
          return Center(
            child: Text("Hata: ${state.error}", style: const TextStyle(color: Colors.white)),
          );
        } else {
          return const Center(child: Text("Bir şeyler ters gitti.", style: TextStyle(color: Colors.white)));
        }
      },
    );
  }
}

