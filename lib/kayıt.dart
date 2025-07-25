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

  void _kayitOl(BuildContext context) {
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

            // TODO: Token saklama işlemini burada yapabilirsiniz

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
                    const SizedBox(height: 24),

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
