import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shartflix_/giri%C5%9F.dart';

import 'package:shartflix_/kay%C4%B1t.dart';
import 'package:shartflix_/home_page.dart';
import 'package:shartflix_/profil.dart';
import 'package:shartflix_/screens/user_profile_screen.dart';
import 'package:shartflix_/screens/kesfet.dart';

import 'bloc/user_bloc.dart';
import 'data/user_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(userRepository: UserRepository()),
        ),
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
      title: 'Shartflix',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const GirisSayfasi(),
        '/kayit': (context) => const KayitSayfasi(),
        '/anasayfa': (context) => const HomePage(token: ''),
        '/profil': (context) {
          return FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final prefs = snapshot.data as SharedPreferences;
                final token = prefs.getString('token') ?? '';
                return ProfilSayfasi(authToken: token);
              } else {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(child: CircularProgressIndicator(color: Colors.black)),
                );
              }
            },
          );
        },
        '/kesfet': (context) {
          return FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final prefs = snapshot.data as SharedPreferences;
                final token = prefs.getString('token') ?? '';
                return Kesfet(token: token);
              } else {
                return const Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }
            },
          );
        },
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/SinFlixLogo.png',
          width: 160,
          height: 160,
        ),
      ),
    );
  }
}
