import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:shartflix_/film_sayfasi.dart';
import 'package:shartflix_/fotograf.dart';
import 'package:shartflix_/sinirli_teklif.dart';

class ProfilSayfasi extends StatefulWidget {
  final String authToken;

  const ProfilSayfasi({Key? key, required this.authToken}) : super(key: key);

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  Map<String, dynamic>? profile;
  List<dynamic> favoriteFilms = [];
  bool isLoading = true;
  String? error;

  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileAndFavorites();
  }

  Future<void> _loadProfileAndFavorites() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? widget.authToken;

    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        error = "Giriş yapılmamış. Token bulunamadı.";
        isLoading = false;
      });
      return;
    }

    try {
      final profileResponse = await http.get(
        Uri.parse("https://caseapi.servicelabs.tech/user/profile"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (profileResponse.statusCode != 200) {
        throw Exception("Profil bilgisi alınamadı: ${profileResponse.statusCode}");
      }
      final profileBody = jsonDecode(profileResponse.body);
      final profileData = profileBody['data'];

      final favoritesResponse = await http.get(
        Uri.parse("https://caseapi.servicelabs.tech/movie/favorites"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (favoritesResponse.statusCode != 200) {
        throw Exception("Favori filmler alınamadı: ${favoritesResponse.statusCode}");
      }

      final favoritesBody = jsonDecode(favoritesResponse.body);
      final favFilms = favoritesBody['data'] ?? [];

      if (!mounted) return;
      setState(() {
        profile = profileData;
        favoriteFilms = favFilms;
        isLoading = false;
        _selectedImage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = "Hata oluştu: $e";
        isLoading = false;
      });
    }
  }

  Future<void> toggleFavorite(String filmId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? widget.authToken;

    if (token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token bulunamadı, işlem yapılamadı.")),
      );
      return;
    }

    final url = Uri.parse('https://caseapi.servicelabs.tech/movie/favorite/$filmId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Favori durumu güncellendi.")),
      );
      _loadProfileAndFavorites();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Favori güncelleme hatası: ${response.statusCode}")),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      if (!mounted) return;
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;

    if (!mounted) return;
    setState(() {
      _isUploading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? widget.authToken;

    if (token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token bulunamadı, işlem yapılamadı.")),
      );
      return;
    }

    final uri = Uri.parse("https://caseapi.servicelabs.tech/user/upload_photo");
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    final fileName = path.basename(_selectedImage!.path);

    request.files.add(
      await http.MultipartFile.fromPath('photo', _selectedImage!.path, filename: fileName),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final respJson = jsonDecode(respStr);

        String? newPhotoUrl;
        if (respJson['data'] != null && respJson['data']['photoUrl'] != null) {
          newPhotoUrl = respJson['data']['photoUrl'];
        }

        if (!mounted) return;
        setState(() {
          if (newPhotoUrl != null) {
            profile?['photoUrl'] = newPhotoUrl;
          } else {
            profile?['photoUrl'] = _selectedImage!.path;
          }
          _isUploading = false;
          _selectedImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fotoğraf başarıyla yüklendi')),
        );

        _loadProfileAndFavorites();
      } else {
        if (!mounted) return;
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yükleme başarısız: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yükleme sırasında hata oluştu: $e')),
      );
    }
  }

  Widget getImageWidget(String? url) {
    if (url == null || url.isEmpty) {
      return const Icon(Icons.broken_image, size: 60, color: Colors.grey);
    }
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.endsWith('.svg')) {
      return Image.network(url, width: 60, height: 90, fit: BoxFit.cover);
    }
    if (url.startsWith('http') || url.startsWith('https')) {
      return Image.network(
        url,
        width: 60,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 60, color: Colors.grey),
      );
    } else {
      return Image.file(
        File(url),
        width: 60,
        height: 90,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Profil"),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Profil"),
        ),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Profil Detayı",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SinirliTeklif()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Sınırlı Teklif",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade900,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover, width: 80, height: 80)
                        : getImageWidget(profile?['photoUrl']),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?['name'] ?? 'İsim yok',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: ${profile?['id'] ?? 'Bilinmiyor'}",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : () async {
                          if (_selectedImage == null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Fotograf()),
                            );
                          } else {
                            await _uploadPhoto();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _selectedImage == null ? "Fotoğraf Ekle" : "Yükle",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                )
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Beğendiğim Filmler",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            favoriteFilms.isEmpty
                ? const Text(
                    "Henüz favori film yok.",
                    style: TextStyle(color: Colors.white70),
                  )
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: favoriteFilms.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.50,
                    ),
                   itemBuilder: (context, index) {
  final film = favoriteFilms[index];
  final imageUrl = (film['Poster'] ?? '').toString().replaceFirst("http://", "https://");
  final filmTitle = film['Title'] ?? 'Başlık yok';
  final filmDescription = film['Plot'] ?? 'Açıklama yok';

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilmSayfasi(
            title: filmTitle,
            description: filmDescription,
            posterUrl: imageUrl,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: Colors.grey, size: 60),
                  )
                : const Icon(Icons.broken_image, color: Colors.grey, size: 60),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              filmTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              filmDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.favorite, color: Colors.red),
          )
        ],
      ),
    ),
  );
}


                  )
          ],
        ),
      ),
    );
  }
}