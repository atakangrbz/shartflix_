import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/film.dart';

class FilmRepository {
  final String baseUrl = 'https://caseapi.servicelabs.tech';

  Future<List<Film>> fetchFilms({int page = 1, int pageSize = 5}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/list?page=$page&size=$pageSize'),
      headers: {
        'Accept': 'application/json',
        // Eğer JWT token gerekiyorsa buraya ekle
        // 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List movies = data['movies'] ?? data['data'] ?? [];
      return movies.map((json) => Film.fromJson(json)).toList();
    } else {
      throw Exception('Film listesi alınamadı: ${response.statusCode}');
    }
  }

  Future<void> toggleFavorite(int filmId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/movie/favorite/$filmId'),
      headers: {
        'Accept': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Favori güncellenemedi: ${response.statusCode}');
    }
  }
}
