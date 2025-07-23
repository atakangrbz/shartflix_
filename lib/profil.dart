import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  // Örnek kullanıcı bilgileri
  String kullaniciAdi = "Atakan Gürbüz";
  String email = "atakan@example.com";

  // Favori filmler listesi (örnek)
  List<Film> favoriFilmler = [
    Film(id: 1, title: "Film 1", isFavorite: true),
    Film(id: 3, title: "Film 3", isFavorite: true),
  ];

  File? _profilResmi;

  final ImagePicker _picker = ImagePicker();

  Future<void> _resimSec() async {
    final XFile? resim = await _picker.pickImage(source: ImageSource.gallery);
    if (resim != null) {
      setState(() {
        _profilResmi = File(resim.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil fotoğrafı
            GestureDetector(
              onTap: _resimSec,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profilResmi != null
                    ? FileImage(_profilResmi!)
                    : const AssetImage("assets/default_profile.png")
                        as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kullanıcı bilgileri
            Text(
              kullaniciAdi,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            // Favori filmler başlığı
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Favori Filmler",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // Favori filmler listesi
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favoriFilmler.length,
              itemBuilder: (context, index) {
                final film = favoriFilmler[index];
                return ListTile(
                  leading: const Icon(Icons.movie),
                  title: Text(film.title),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
