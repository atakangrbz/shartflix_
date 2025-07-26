import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/film_bloc.dart';
import '../bloc/film_event.dart';
import '../bloc/film_state.dart';
import '../data/film_repository.dart';
import '../domain/film.dart';

class Kesfet extends StatefulWidget {
  const Kesfet({super.key, required String token});

  @override
  State<Kesfet> createState() => _KesfetState();
}

class _KesfetState extends State<Kesfet> {
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

    if (storedToken == null || storedToken.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/giris');
      }
      return;
    }

    token = storedToken;
    filmRepository.updateToken(token!);

    setState(() {
      isLoading = false;
    });
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
      child: const Scaffold(
        backgroundColor: Colors.black,
        body: KesfetFilmList(),
      ),
    );
  }
}

class KesfetFilmList extends StatelessWidget {
  const KesfetFilmList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilmBloc, FilmState>(
      builder: (context, state) {
        if (state is FilmLoadInProgress) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        } else if (state is FilmLoadSuccess) {
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.films.length,
            itemBuilder: (context, index) {
              final film = state.films[index];
              return KesfetMovieCard(film: film);
            },
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

class KesfetMovieCard extends StatelessWidget {
  final Film film;

  const KesfetMovieCard({super.key, required this.film});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          film.posterUrl ?? '',
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white30, size: 100),
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          },
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 0.5],
            ),
          ),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: () {
              context.read<FilmBloc>().add(FilmToggleFavorite(film.id));
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              child: Icon(
                film.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: film.isFavorite ? Colors.red : Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                film.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                film.description,
                style: const TextStyle(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
