import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class Fotograf extends StatefulWidget {
  const Fotograf({super.key});

  @override
  State<Fotograf> createState() => _FotografState();
}

class _FotografState extends State<Fotograf> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
  try {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      print("Seçilen resim yolu: ${pickedFile.path}");
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      print("Hiçbir resim seçilmedi");
    }
  } catch (e) {
    print("Resim seçme hatası: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Görsel seçilirken hata oluştu: $e')),
    );
  }
}


  Future<void> _uploadPhoto() async {
  if (_selectedImage == null) return;

  setState(() {
    _isUploading = true;
  });

  try {
    // Token'ı SharedPreferences üzerinden al
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oturum süresi doldu. Lütfen tekrar giriş yapın.")),
      );
      setState(() => _isUploading = false);
      return;
    }

    final uri = Uri.parse("https://caseapi.servicelabs.tech/user/upload_photo");
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    final fileName = path.basename(_selectedImage!.path);
    request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path, filename: fileName));

    final response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final respJson = jsonDecode(respStr);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fotoğraf başarıyla yüklendi')),
      );
      setState(() {
        _isUploading = false;
        _selectedImage = null;
      });
      Navigator.pop(context); // Profil sayfasına dön
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yükleme başarısız: ${response.statusCode}')),
      );
      setState(() => _isUploading = false);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Yükleme sırasında hata oluştu: $e')),
    );
    setState(() => _isUploading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButton(color: Colors.white),
        centerTitle: true,
        title: const Text("Profil Detayı", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Fotoğraflarınızı Yükleyin",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              "Resources out incentivize relaxation floor loss cc.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade700, width: 2),
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Icon(Icons.add, size: 40, color: Colors.white54),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedImage != null && !_isUploading) ? _uploadPhoto : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  disabledBackgroundColor: Colors.red.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Devam Et",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
