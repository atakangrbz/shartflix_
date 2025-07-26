import 'package:flutter/material.dart';
import 'package:shartflix_/screens/kesfet.dart';
import 'anasayfa.dart';
import 'profil.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Anasayfa(token: widget.token),
      Kesfet(token: widget.token),
      ProfilSayfasi(authToken: widget.token),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(3, (index) {
            bool isActive = _selectedIndex == index;

            if (index == 1) {
              // 🔍 Ortadaki Keşfet butonu
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(
                    Icons.explore,
                    color: isActive ? Colors.white : Colors.white70,
                    size: 26,
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(32),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        index == 0 ? Icons.home : Icons.person,
                        size: 24,
                        color: isActive ? Colors.white : Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        index == 0 ? "Anasayfa" : "Profil",
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}