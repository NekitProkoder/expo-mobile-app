import 'package:flutter/material.dart';

import 'admin_event_settings_screen.dart';
import 'admin_exhibitors_screen.dart';
import 'admin_users_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Widget adminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(icon, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget summaryCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFACA2C),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Администрирование',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Управление данными мобильного приложения выставки.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Админ-панель'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          summaryCard(),
          adminCard(
            icon: Icons.event_note,
            title: 'Настройки выставки',
            subtitle: 'Даты, место, ссылки — главный экран приложения',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminEventSettingsScreen(),
                ),
              );
            },
          ),
          adminCard(
            icon: Icons.groups,
            title: 'Управление участниками',
            subtitle: 'Добавление, редактирование и удаление участников',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminExhibitorsScreen(),
                ),
              );
            },
          ),
          adminCard(
            icon: Icons.people,
            title: 'Пользователи',
            subtitle: 'Просмотр пользователей и управление ролями',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminUsersScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}