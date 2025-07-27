import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Sifre extends StatefulWidget {
  const Sifre({super.key});

  @override
  State<Sifre> createState() => _SifreState();
}

class _SifreState extends State<Sifre> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> sifreSifirla() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    final url = Uri.parse("https://caseapi.servicelabs.tech/user/forgot-password");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailController.text.trim()}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Şifre sıfırlama bağlantısı e-postanıza gönderildi.")),
        );
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Bir hata oluştu.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $error")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("İnternet hatası: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Şifre Sıfırla"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "E-posta adresinizi girin, size bir sıfırlama bağlantısı gönderelim.",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "E-posta",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "E-posta giriniz";
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) return "Geçerli bir e-posta giriniz";
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : sifreSifirla,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Gönder"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
