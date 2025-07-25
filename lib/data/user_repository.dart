import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/user.dart';

class UserRepository {
  final String baseUrl;

  UserRepository({required this.baseUrl});

  Future<User> fetchUserProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/user/profile'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Profil alınamadı. Hata kodu: ${response.statusCode}');
    }
  }
}
