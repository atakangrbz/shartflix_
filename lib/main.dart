import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shartflix_/giriş.dart';
import 'package:shartflix_/kayıt.dart';
import 'package:shartflix_/home_page.dart';

import 'bloc/user_bloc.dart';
import 'data/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // SharedPreferences için şart ✅

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(userRepository: UserRepository()),
        ),
        // Başka BLoC'lar varsa buraya ekle
      ],
      child: const MyApp(),
    ),
  );
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
        '/kayit': (context) => const KayitSayfasi(),
        '/anasayfa': (context) => const HomePage(),
      },
    );
  }
}
