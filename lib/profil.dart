import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

// Film modeli
class Film {
  final int id;
  final String title;
  bool isFavorite;

  Film({required this.id, required this.title, this.isFavorite = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login + Profil Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

// -------------------- LOGIN SAYFASI --------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  Future<String> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('https://caseapi.servicelabs.tech/user/login'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json', // BUNU EKLEDİK
    },
    body: jsonEncode({
      'email': email.trim(),          // BUNU TRIMLEDİK
      'password': password.trim(),   // BUNU DA
    }),
  );

  print('Response code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final token = body['data']?['token'];
    if (token == null || token.isEmpty) {
      throw Exception('Token alınamadı');
    }
    return token;
  } else {
    final body = jsonDecode(response.body);
    final message = body['response']?['message'] ?? 'Giriş başarısız';
    throw Exception(message);
  }
}


  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final token = await login(emailController.text.trim(), passwordController.text);
      // Token başarıyla alındıysa Profil sayfasına geç
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Profil(authToken: token),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Giriş Yap")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'E-posta giriniz';
                      if (!value.contains('@')) return 'Geçerli e-posta giriniz';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Şifre giriniz';
                      if (value.length < 6) return 'Şifre en az 6 karakter olmalı';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage != null)
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Giriş Yap'),
                  ),
                ],
              )),
        ));
  }
}

// -------------------- PROFIL SAYFASI --------------------

class Profil extends StatefulWidget {
  final String authToken;

  const Profil({super.key, required this.authToken});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  String kullaniciAdi = "";
  String email = "";
  String? photoUrl;

  File? _profilResmi;
  final ImagePicker _picker = ImagePicker();

  String? hataMesaji;

  List<Film> favoriFilmler = [
    Film(id: 1, title: "Film 1", isFavorite: true),
    Film(id: 2, title: "Film 2", isFavorite: true),
    Film(id: 3, title: "Film 3", isFavorite: true),
    Film(id: 4, title: "Film 4", isFavorite: true),
  ];

  @override
  void initState() {
    super.initState();
    _kullaniciBilgisiGetir();
  }

  Future<void> _kullaniciBilgisiGetir() async {
  try {
    final response = await http.get(
      Uri.parse("https://caseapi.servicelabs.tech/user/profile"),
      headers: {
        'Authorization': 'Bearer ${widget.authToken}',
        'Accept': 'application/json',
      },
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final Map<String, dynamic>? userData = decoded["data"];

      if (userData != null) {
        final String emailFromApi = userData["email"] ?? "";
        final String nameFromApi = userData["name"] ?? "";

        String nameToUse = nameFromApi;
        if (nameToUse.isEmpty && emailFromApi.contains("@")) {
          final prefix = emailFromApi.split("@").first;
          nameToUse = prefix[0].toUpperCase() + prefix.substring(1);
        }

        setState(() {
          kullaniciAdi = nameToUse;
          email = emailFromApi;
          photoUrl = userData["photoUrl"];
          hataMesaji = null;
        });
      } else {
        setState(() {
          hataMesaji = "Kullanıcı verisi bulunamadı.";
        });
      }
    } else if (response.statusCode == 401) {
      setState(() {
        hataMesaji = "Yetkisiz erişim - Lütfen giriş yapınız.";
      });
    } else {
      setState(() {
        hataMesaji = "Bir hata oluştu: ${response.statusCode}";
      });
    }
  } catch (e) {
    setState(() {
      hataMesaji = "İstek sırasında hata: $e";
    });
  }
}


  Future<void> _resimSec() async {
    final XFile? resim = await _picker.pickImage(source: ImageSource.gallery);
    if (resim != null) {
      setState(() {
        _profilResmi = File(resim.path);
        photoUrl = null;
      });

      // TODO: Seçilen resmi API'ye yüklemek için fonksiyon yazılabilir
    }
  }

  void _handleMenuSelection(String value) {
    if (value == 'teklif') {
      print("Sınırlı Teklif seçildi");
      // Sınırlı teklif için bottom sheet veya başka UI açılabilir
    } else if (value == 'detay') {
      print("Profil Detayı seçildi");
      // Profil detay sayfasına yönlendirme yapılabilir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'teklif', child: Text('Sınırlı Teklif')),
              const PopupMenuItem(value: 'detay', child: Text('Profil Detayı')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _resimSec,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profilResmi != null
                    ? FileImage(_profilResmi!)
                    : (photoUrl != null && photoUrl!.isNotEmpty
                        ? NetworkImage(photoUrl!)
                        : const AssetImage("assets/default_profile.png")
                            as ImageProvider),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(Icons.camera_alt, color: Colors.grey.shade800),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            hataMesaji != null
                ? Text(
                    hataMesaji!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  )
                : Column(
                    children: [
                      Text(
                        kullaniciAdi.isNotEmpty ? kullaniciAdi : "Yükleniyor...",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email.isNotEmpty ? email : "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Favori Filmler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriFilmler.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemBuilder: (context, index) {
                final film = favoriFilmler[index];
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.movie, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          film.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
