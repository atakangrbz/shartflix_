import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilSayfasi extends StatefulWidget {
  const ProfilSayfasi({super.key, required String authToken});

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  Future<void> _getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        error = "Token bulunamadı.";
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse("https://caseapi.servicelabs.tech/user/profile"),
      headers: {"Authorization": "Bearer $token"},
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200 && body['data'] != null) {
      setState(() {
        profile = body['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        error = body['response']?['message'] ?? 'Profil verisi alınamadı';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profil")),
        body: Center(child: Text(error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kullanıcı Adı: ${profile!['name'] ?? 'Yok'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("E-posta: ${profile!['email'] ?? 'Yok'}",
                style: const TextStyle(fontSize: 18)),
            // Diğer alanlar eklenebilir
          ],
        ),
      ),
    );
  }
}
