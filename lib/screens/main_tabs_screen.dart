import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

import 'home_screen.dart';
import 'my_ticket_screen.dart';
import 'news_screen.dart';
import 'participants_screen.dart';
import 'profile_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int currentIndex = 0;

  final tabs = const [
    _TabItem(Icons.home_rounded, 'Главная'),
    _TabItem(Icons.confirmation_number_rounded, 'Билет'),
    _TabItem(Icons.article_rounded, 'Новости'),
    _TabItem(Icons.groups_rounded, 'Участники'),
    _TabItem(Icons.person_rounded, 'Профиль'),
  ];

  Widget getCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const MyTicketScreen();
      case 2:
        return const NewsScreen();
      case 3:
        return const ParticipantsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getCurrentScreen(),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 8, 14, 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final selected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary.withValues(alpha: 0.22)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 24,
                          color: selected ? Colors.black : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                            color: selected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;

  const _TabItem(this.icon, this.label);
}