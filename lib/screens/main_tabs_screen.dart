import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';

import 'admin_screen.dart';
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
  bool isLoading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final UserModel user = await ApiService.getProfile();

      if (!mounted) return;

      setState(() {
        isAdmin = user.isAdmin;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isAdmin = false;
        isLoading = false;
      });
    }
  }

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
      case 5:
        return const AdminScreen();
      default:
        return const HomeScreen();
    }
  }

  List<BottomNavigationBarItem> getItems() {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Главная',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.confirmation_number),
        label: 'Билет',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.article),
        label: 'Новости',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.groups),
        label: 'Участники',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Профиль',
      ),
    ];

    if (isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Админка',
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFACA2C),
          ),
        ),
      );
    }

    final items = getItems();

    if (currentIndex >= items.length) {
      currentIndex = 0;
    }

    return Scaffold(
      body: getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFACA2C),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: items,
      ),
    );
  }
}