import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
  State<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordAgainController = TextEditingController();

  bool _isLoading = false;

  Future<void> _kayitOl() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text;
    final email = emailController.text;
    final password = passwordController.text;

    final url = Uri.parse('https://caseapi.servicelabs.tech/user/register');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      print('Yanıt: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Token ve user var mı kontrol et
        final String? token = data['token'];
        final Map<String, dynamic>? user = data['user'];

        if (token != null && user != null) {
          final userName = user['name'] ?? "Kullanıcı";

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Kayıt başarılı! Hoş geldin, $userName")),
          );

          // TODO: token'ı güvenli şekilde saklayın (örneğin SharedPreferences)

          Navigator.pushReplacementNamed(context, "/");
        } else if (data.containsKey('message')) {
          // Sadece mesaj varsa
          final message = data['message'] ?? "Kayıt başarılı.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else {
          // Beklenmedik durum
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kayıt başarılı ama veri okunamadı.")),
          );
        }
      } else {
        // Başarısız kayıt
        String mesaj = "Kayıt başarısız. Kod: ${response.statusCode}";
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            mesaj = errorData['message'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mesaj)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bir hata oluştu: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // E-Posta doğrulama
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "E-posta giriniz";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return "Geçerli bir e-posta giriniz";
    return null;
  }

  // Şifre doğrulama
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Şifre giriniz";
    if (value.length < 6) return "Şifre en az 6 karakter olmalı";
    return null;
  }

  // Şifre tekrar kontrolü
  String? _validatePasswordAgain(String? value) {
    if (value != passwordController.text) return "Şifreler eşleşmiyor";
    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordAgainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hoşgeldiniz",
                    style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Kayıt olarak hemen keşfetmeye başlayın.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: nameController,
                    decoration: _inputDecoration("Ad Soyad"),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) => value == null || value.isEmpty ? "Ad Soyad boş olamaz" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emailController,
                    decoration: _inputDecoration("E-posta"),
                    style: const TextStyle(color: Colors.white),
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: _inputDecoration("Şifre"),
                    style: const TextStyle(color: Colors.white),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordAgainController,
                    obscureText: true,
                    decoration: _inputDecoration("Şifre Tekrar"),
                    style: const TextStyle(color: Colors.white),
                    validator: _validatePasswordAgain,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _kayitOl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Kayıt Ol"),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Zaten hesabın var mı? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, "/"),
                        child: const Text(
                          "Giriş yap",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
