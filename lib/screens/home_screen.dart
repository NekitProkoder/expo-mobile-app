import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../config/app_links.dart';
import 'ticket_form_screen.dart';
import 'my_ticket_screen.dart';
import 'news_screen.dart';
import 'participants_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Euro Shoes Expo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            Text(
              'Premiere Collection 2026',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5a4800),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HeroBlock(onTicketTap: () => _navigate(context, const TicketFormScreen())),
          const SizedBox(height: 12),
          _StatsRow(),
          const SizedBox(height: 20),
          _SectionLabel(title: 'Быстрые действия'),
          const SizedBox(height: 10),
          _QuickGrid(onNavigate: (screen) => _navigate(context, screen)),
          const SizedBox(height: 20),
          _SectionLabel(title: 'Связь с выставкой'),
          const SizedBox(height: 10),
          _ContactRow(onTelegram: () => _openUrl('https://t.me/euroshoes'),
              onWebsite: () => _openUrl(AppLinks.website)),
        ],
      ),
    );
  }
}

// ── Hero block ──────────────────────────────────────────────────────────────

class _HeroBlock extends StatelessWidget {
  final VoidCallback onTicketTap;
  const _HeroBlock({required this.onTicketTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '4–7 МАРТА · ЦМТ, МОСКВА',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3a2e00),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Euro Shoes\nPremiere Collection',
            style: TextStyle(
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Мобильный помощник посетителя выставки',
            style: TextStyle(fontSize: 13, color: Color(0xFF3a2e00)),
          ),
          const SizedBox(height: 16),
          _metaRow(Icons.calendar_month_outlined, '4–7 марта 2026'),
          const SizedBox(height: 6),
          _metaRow(Icons.location_on_outlined, 'ЦМТ, Москва'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTicketTap,
              icon: const Icon(Icons.confirmation_number_outlined,
                  color: AppTheme.primary, size: 20),
              label: const Text(
                'Получить билет',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF3a2e00)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ── Stats row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard('100+', 'участников'),
        const SizedBox(width: 8),
        _statCard('5 000+', 'посетителей'),
        const SizedBox(width: 8),
        _statCard('ЦМТ', 'локация'),
      ],
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
        letterSpacing: 0.2,
      ),
    );
  }
}

// ── Quick actions grid ───────────────────────────────────────────────────────

class _QuickGrid extends StatelessWidget {
  final void Function(Widget screen) onNavigate;
  const _QuickGrid({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickItem(Icons.qr_code_rounded, 'Мой билет', const MyTicketScreen()),
      _QuickItem(Icons.article_rounded, 'Новости', const NewsScreen()),
      _QuickItem(Icons.groups_rounded, 'Участники', const ParticipantsScreen()),
      _QuickItem(Icons.person_rounded, 'Профиль', const ProfileScreen()),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: items
          .map((item) => _QuickCard(item: item, onTap: () => onNavigate(item.screen)))
          .toList(),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String title;
  final Widget screen;
  const _QuickItem(this.icon, this.title, this.screen);
}

class _QuickCard extends StatelessWidget {
  final _QuickItem item;
  final VoidCallback onTap;
  const _QuickCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 20, color: const Color(0xFF5a4800)),
              ),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Contact row ──────────────────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final VoidCallback onTelegram;
  final VoidCallback onWebsite;
  const _ContactRow({required this.onTelegram, required this.onWebsite});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _contactBtn(Icons.send_rounded, 'Telegram', onTelegram)),
        const SizedBox(width: 10),
        Expanded(child: _contactBtn(Icons.language_rounded, 'Сайт', onWebsite)),
      ],
    );
  }

  Widget _contactBtn(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
