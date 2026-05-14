import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_links.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> openUrl(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget card({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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

  Widget aboutBlock() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFACA2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Euro Shoes App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Мобильное приложение для посетителей выставки Euro Shoes Premiere Collection.',
            style: TextStyle(color: Colors.black87),
          ),
          SizedBox(height: 12),
          Text(
            'Версия: 1.0.0',
            style: TextStyle(fontWeight: FontWeight.w700),
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
        title: const Text('Настройки'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          aboutBlock(),
          card(
            icon: Icons.language,
            title: 'Официальный сайт',
            subtitle: 'Перейти на сайт выставки',
            onTap: () => openUrl(AppLinks.website),
          ),
          card(
            icon: Icons.privacy_tip,
            title: 'Политика конфиденциальности',
            subtitle: 'Открыть документ',
            onTap: () => openUrl(AppLinks.privacyPolicy),
          ),
          card(
            icon: Icons.info,
            title: 'О приложении',
            subtitle: 'Flutter + FastAPI + PostgreSQL + Bitrix24',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}