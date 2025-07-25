import 'dart:convert';
import 'package:http/http.dart' as http;

class UserRepository {
  final String baseUrl = 'https://caseapi.servicelabs.tech';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final token = responseBody['data']['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Token alınamadı');
      }
      return {
        'token': token,
        'message': responseBody['message'], // opsiyonel
      };
    } else {
      throw Exception('Giriş başarısız');
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Kayıt başarısız');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    print("Token gönderiliyor: $token");
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Hata gövdesi: ${response.body}');
      throw Exception('Profil alınamadı');
    }
  }
}
