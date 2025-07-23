import 'package:flutter/material.dart';
import 'package:shartflix_/giri%C5%9F.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Giriş Kayıt Uygulaması',
      initialRoute: '/',
      routes: {
        '/': (context) => const GirisSayfasi(),
        '/kayit': (context) => const GirisSayfasi(),
        '/anasayfa': (context) => const HomePage(), // Burada HomePage
      },
    );
  }
}
