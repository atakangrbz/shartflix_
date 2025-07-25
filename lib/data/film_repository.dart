import 'dart:convert';
import 'package:flutter/foundation.dart'; // kDebugMode için
import 'package:http/http.dart' as http;
import '../domain/film.dart';

class FilmRepository {
  final String baseUrl = 'caseapi.servicelabs.tech'; // domain

  String? token;

  void updateToken(String newToken) {
    token = newToken;
  }

  Future<List<Film>> fetchFilms({int page = 1, required int pageSize}) async {
    final uri = Uri.https(
      baseUrl,
      '/movie/list',
      {
        'page': page.toString(),
        'pageSize': pageSize.toString(),   // pageSize parametresi eklendi
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print('GET ${uri.toString()}');
      print('Status Code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List movies = data['movies'] ?? [];
      return movies.map((json) => Film.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Yetkilendirme hatası (401): Lütfen giriş yapınız.');
    } else if (response.statusCode == 404) {
      throw Exception('Film listesi bulunamadı (404): URL veya endpoint yanlış.');
    } else if (response.statusCode == 400) {
      throw Exception('Geçersiz istek (400): ${response.body}');
    } else {
      throw Exception('Film listesi alınamadı: ${response.statusCode}');
    }
  }

  Future<void> toggleFavorite(int filmId) async {
    final uri = Uri.https(
      baseUrl,
      '/movie/favorite/$filmId',
    );

    final response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print('POST ${uri.toString()}');
      print('Status Code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Yetkilendirme hatası (401): Lütfen giriş yapınız.');
    } else if (response.statusCode == 404) {
      throw Exception('Film bulunamadı veya favori işlemi yapılamadı (404).');
    } else if (response.statusCode == 400) {
      throw Exception('Geçersiz istek (400): ${response.body}');
    } else {
      throw Exception('Favori güncellenemedi: ${response.statusCode}');
    }
  }
}
