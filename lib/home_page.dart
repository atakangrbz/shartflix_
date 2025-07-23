import 'package:flutter/material.dart';
import 'anasayfa.dart';
import 'profil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Anasayfa(),
    const Profil(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          // BoxShadow kaldırıldı, böylece alt çizgi görünmez
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(2, (index) {
            bool isActive = _selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: isActive ? 24 : 16,
                ),
                decoration: BoxDecoration(
                  color: isActive ? Colors.blue.shade100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Icon(
                      index == 0 ? Icons.home : Icons.person,
                      size: isActive ? 30 : 24,
                      color: isActive ? Colors.blue : Colors.grey[600],
                    ),
                    if (isActive)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          index == 0 ? "Anasayfa" : "Profil",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
