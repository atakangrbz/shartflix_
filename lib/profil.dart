import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Film {
  final int id;
  final String title;
  bool isFavorite;

  Film({required this.id, required this.title, this.isFavorite = false});
}

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  String kullaniciAdi = "";
  String email = "";
  String? photoUrl;

  File? _profilResmi;
  final ImagePicker _picker = ImagePicker();

  // Buraya gerçek token'ı koymalısın
  final String authToken = "YOUR_JWT_TOKEN_HERE";

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
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      },
    );

    print("Status code: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      print("Decoded JSON: $decoded");
      final Map<String, dynamic>? userData = decoded["data"];
      print("User data: $userData");

      if (userData != null) {
        setState(() {
          kullaniciAdi = userData["name"] ?? "";
          email = userData["email"] ?? "";
          photoUrl = userData["photoUrl"];
        });
      } else {
        print("Kullanıcı verisi bulunamadı.");
      }
    } else if (response.statusCode == 401) {
      print("Yetkisiz erişim - Lütfen giriş yapınız.");
    } else {
      print("Bir hata oluştu: ${response.statusCode}");
    }
  } catch (e) {
    print("Hata: $e");
  }
}



  Future<void> _resimSec() async {
    final XFile? resim = await _picker.pickImage(source: ImageSource.gallery);
    if (resim != null) {
      setState(() {
        _profilResmi = File(resim.path);
        photoUrl = null; // Yeni resim seçilince eski link sıfırlanır
      });
      // Burada seçilen resmi API'ye yüklemek için ek metod yazabilirsin
    }
  }

  void _handleMenuSelection(String value) {
    if (value == 'teklif') {
      print("Sınırlı Teklif seçildi");
      // Burada sınırlı teklif bottom sheet açılabilir
    } else if (value == 'detay') {
      print("Profil Detayı seçildi");
      // Profil detay sayfasına geçiş vs.
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
                        : const AssetImage("assets/default_profile.png") as ImageProvider),
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
            Text(
              kullaniciAdi.isNotEmpty ? kullaniciAdi : "Yükleniyor...",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              email.isNotEmpty ? email : "",
              style: const TextStyle(color: Colors.grey),
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
