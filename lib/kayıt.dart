import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

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

  bool _termsAccepted = false;

  void _kayitOl(BuildContext context) {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen kullanıcı sözleşmesini kabul ediniz.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      context.read<UserBloc>().add(RegisterUser(name: name, email: email, password: password));
    }
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
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is UserLoggedIn) {
            final name = state.user['name'] ?? 'Kullanıcı';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Kayıt başarılı! Hoş geldin, $name")),
            );

            Navigator.pushReplacementNamed(context, "/");
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
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
                    const SizedBox(height: 16),

                    // Kullanıcı Sözleşmesi
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          checkColor: Colors.black,
                          activeColor: Colors.white,
                        ),
                        Expanded(
                          child: Wrap(
                            children: [
                              const Text("Kayıt olarak ", style: TextStyle(color: Colors.white70)),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Kullanıcı Sözleşmesi"),
                                      content: const SingleChildScrollView(
                                        child: Text(
                                          "Buraya kullanıcı sözleşmesinin içeriği yazılacak. Bu metni dilediğin kadar uzatabilir, detaylı açıklamalar yapabilirsin. Kullanıcı bu sözleşmeyi okuyarak kabul etmiş olur.",
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("Kapat"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Kullanıcı Sözleşmesi’ni",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(" okudum ve kabul ediyorum.", style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Kayıt butonu
                    BlocBuilder<UserBloc, UserState>(
                      builder: (context, state) {
                        final isLoading = state is UserLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () => _kayitOl(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Kayıt Ol"),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Sosyal Giriş Butonları
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _iconButton(Icons.email, () => print("E-posta ile kayıt")),
                        const SizedBox(width: 16),
                        _iconButton(Icons.apple, () => print("Apple ile kayıt")),
                        const SizedBox(width: 16),
                        _iconButton(Icons.facebook, () => print("Facebook ile kayıt")),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Giriş yap linki
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

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "E-posta giriniz";
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return "Geçerli bir e-posta giriniz";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Şifre giriniz";
    if (value.length < 6) return "Şifre en az 6 karakter olmalı";
    return null;
  }

  String? _validatePasswordAgain(String? value) {
    if (value != passwordController.text) return "Şifreler eşleşmiyor";
    return null;
  }
}
