import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/app_info_tile.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_menu_card.dart';
import 'login_screen.dart';
import 'my_ticket_screen.dart';
import 'settings_screen.dart';
import 'ticket_form_screen.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await ApiService.getProfile();

      if (!mounted) return;

      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки профиля: $e')),
      );
    }
  }

  Future<void> logout() async {
    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget headerBlock(UserModel currentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFACA2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Icon(
              currentUser.isAdmin
                  ? Icons.admin_panel_settings
                  : Icons.person,
              size: 36,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser.fullName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  currentUser.isAdmin ? 'Администратор' : 'Посетитель',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: AppLoading(text: 'Загрузка профиля...'),
      );
    }

    final currentUser = user;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Профиль'),
          backgroundColor: const Color(0xFFFACA2C),
        ),
        body: const Center(
          child: Text('Профиль не найден'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Личный кабинет'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          headerBlock(currentUser),

          AppInfoTile(
            icon: Icons.person,
            title: 'ФИО',
            value: currentUser.fullName,
          ),
          AppInfoTile(
            icon: Icons.email,
            title: 'Email',
            value: currentUser.email,
          ),
          AppInfoTile(
            icon: Icons.phone,
            title: 'Телефон',
            value: currentUser.phone,
          ),
          AppInfoTile(
            icon: Icons.business,
            title: 'Компания',
            value: currentUser.company,
          ),
          AppInfoTile(
            icon: Icons.badge,
            title: 'Должность',
            value: currentUser.position,
          ),

          const SizedBox(height: 10),
          if (currentUser.isAdmin)
  AppMenuCard(
    icon: Icons.admin_panel_settings,
    title: 'Админ-панель',
    subtitle: 'Управление участниками и пользователями',
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminScreen(),
        ),
      );
    },
  ),

          AppMenuCard(
            icon: Icons.settings,
            title: 'Настройки и информация',
            subtitle: 'Политика, сайт и сведения о приложении',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),

          AppMenuCard(
            icon: Icons.confirmation_number,
            title: 'Получить пригласительный билет',
            subtitle: 'Оформить заявку на посещение выставки',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TicketFormScreen(),
                ),
              );
            },
          ),

          AppMenuCard(
            icon: Icons.qr_code,
            title: 'Мои билеты',
            subtitle: 'Посмотреть статус и PDF билет',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyTicketScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}