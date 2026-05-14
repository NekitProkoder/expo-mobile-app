import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'ticket_form_screen.dart';
import 'my_ticket_screen.dart';
import 'news_screen.dart';
import 'participants_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> openUrl(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget quickCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget smallInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget heroBlock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Euro Shoes\nPremiere Collection',
            style: TextStyle(
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Мобильный помощник посетителя выставки',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),

          const Row(
            children: [
              Icon(Icons.calendar_month, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '4–7 марта 2026',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          const Row(
            children: [
              Icon(Icons.location_on, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ЦМТ, Москва',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TicketFormScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.confirmation_number,
                color: Colors.black,
              ),
              label: const Text(
                'Получить билет',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget contactButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              openUrl('https://t.me/euroshoes');
            },
            icon: const Icon(Icons.send, color: Colors.black),
            label: const Text(
              'Telegram',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              openUrl('https://www.euroshoes-moscow.ru');
            },
            icon: const Icon(Icons.language, color: Colors.black),
            label: const Text(
              'Сайт',
              style: TextStyle(color: Colors.black),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Бизнес Глобал Экспо'),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          heroBlock(context),

          const SizedBox(height: 16),

          Row(
            children: [
              smallInfoCard(
                icon: Icons.store,
                title: 'участников',
                value: '100+',
              ),
              const SizedBox(width: 12),
              smallInfoCard(
                icon: Icons.people,
                title: 'посетителей',
                value: '5000+',
              ),
              const SizedBox(width: 12),
              smallInfoCard(
                icon: Icons.map,
                title: 'локация',
                value: 'ЦМТ',
              ),
            ],
          ),

          sectionTitle('Быстрые действия'),

          quickCard(
            context: context,
            icon: Icons.confirmation_number,
            title: 'Получить пригласительный билет',
            screen: const TicketFormScreen(),
          ),

          const SizedBox(height: 12),

          quickCard(
            context: context,
            icon: Icons.qr_code,
            title: 'Мой билет',
            screen: const MyTicketScreen(),
          ),

          const SizedBox(height: 12),

          quickCard(
            context: context,
            icon: Icons.article,
            title: 'Новости выставки',
            screen: const NewsScreen(),
          ),

          const SizedBox(height: 12),

          quickCard(
            context: context,
            icon: Icons.groups,
            title: 'Участники выставки',
            screen: const ParticipantsScreen(),
          ),

          const SizedBox(height: 12),

          quickCard(
            context: context,
            icon: Icons.person,
            title: 'Профиль',
            screen: const ProfileScreen(),
          ),

          sectionTitle('Связь с выставкой'),

          contactButtons(),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}