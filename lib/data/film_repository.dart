import 'dart:convert';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:http/http.dart' as http;
import '../domain/film.dart';

class FilmRepository {
  final String baseUrl = 'caseapi.servicelabs.tech';

  String? token;

  /// Girişten sonra token buraya set edilir
  void updateToken(String newToken) {
    token = newToken;
    if (kDebugMode) {
      print('[FilmRepository] Token güncellendi: $token');
    }
  }

  /// Filmleri listeler (sayfa bazlı)
  Future<List<Film>> fetchFilms({int page = 1, required int pageSize}) async {
    final uri = Uri.https(
      baseUrl,
      '/movie/list',
      {
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      },
    );

    if (token == null || token!.isEmpty) {
      throw Exception('[FilmRepository] Token null veya boş. Lütfen önce giriş yapınız.');
    }

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print('[FilmRepository] GET ${uri.toString()}');
      print('[FilmRepository] Status Code: ${response.statusCode}');
      print('[FilmRepository] Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> movies = body['data']?['movies'] ?? body['movies'] ?? [];

      return movies.map((movieJson) => Film.fromJson(movieJson)).toList();
    } else if (response.statusCode == 400 && response.body.contains("jwt malformed")) {
      throw Exception('[FilmRepository] JWT hatalı veya bozuk: $token');
    } else if (response.statusCode == 401) {
      throw Exception('[FilmRepository] Yetkisiz erişim (401) - Token geçersiz veya süresi dolmuş.');
    } else if (response.statusCode == 404) {
      throw Exception('[FilmRepository] Film listesi bulunamadı (404).');
    } else {
      throw Exception('[FilmRepository] Hata: ${response.statusCode} - ${response.body}');
    }
  }

  /// Favori işlemi
  Future<void> toggleFavorite(String filmId) async {
  final uri = Uri.https(baseUrl, '/movie/favorite/$filmId');

  if (token == null || token!.isEmpty) {
    throw Exception('[FilmRepository] Favori işlemi için token eksik.');
  }

  final response = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (kDebugMode) {
    print('[FilmRepository] POST ${uri.toString()}');
    print('[FilmRepository] Status Code: ${response.statusCode}');
    print('[FilmRepository] Response Body: ${response.body}');
  }

  if (response.statusCode == 200) return;

  if (response.statusCode == 401) {
    throw Exception('[FilmRepository] Favori: Yetkisiz işlem (401).');
  } else if (response.statusCode == 404) {
    throw Exception('[FilmRepository] Film bulunamadı (404).');
  } else if (response.statusCode == 400) {
    throw Exception('[FilmRepository] Favori için geçersiz istek (400): ${response.body}');
  } else {
    throw Exception('[FilmRepository] Favori güncellenemedi: ${response.statusCode}');
  }
}

}
