import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class AdminEventSettingsScreen extends StatefulWidget {
  const AdminEventSettingsScreen({super.key});

  @override
  State<AdminEventSettingsScreen> createState() =>
      _AdminEventSettingsScreenState();
}

class _AdminEventSettingsScreenState extends State<AdminEventSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final eventNameController = TextEditingController();
  final datesController = TextEditingController();
  final locationController = TextEditingController();
  final mapsUrlController = TextEditingController();
  final addressController = TextEditingController();
  final telegramUrlController = TextEditingController();
  final websiteUrlController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final data = await ApiService.getEventSettings();

      if (!mounted) return;

      setState(() {
        eventNameController.text = data['event_name'] ?? '';
        datesController.text = data['dates'] ?? '';
        locationController.text = data['location'] ?? '';
        mapsUrlController.text = data['maps_url'] ?? '';
        addressController.text = data['address'] ?? '';
        telegramUrlController.text = data['telegram_url'] ?? '';
        websiteUrlController.text = data['website_url'] ?? '';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки настроек: $e')),
      );
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      await ApiService.updateEventSettings({
        'event_name': eventNameController.text.trim(),
        'dates': datesController.text.trim(),
        'location': locationController.text.trim(),
        'maps_url': mapsUrlController.text.trim(),
        'address': addressController.text.trim(),
        'telegram_url': telegramUrlController.text.trim(),
        'website_url': websiteUrlController.text.trim(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки сохранены')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Заполните поле' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  @override
  void dispose() {
    eventNameController.dispose();
    datesController.dispose();
    locationController.dispose();
    mapsUrlController.dispose();
    addressController.dispose();
    telegramUrlController.dispose();
    websiteUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Настройки выставки'),
        backgroundColor: AppTheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'Эти данные отображаются на главном экране приложения у всех пользователей.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _sectionTitle('Основная информация'),
                  _field(
                    label: 'Название выставки',
                    controller: eventNameController,
                    icon: Icons.event,
                    hint: 'Euro Shoes Premiere Collection',
                    required: true,
                  ),
                  _field(
                    label: 'Даты проведения',
                    controller: datesController,
                    icon: Icons.calendar_month_outlined,
                    hint: '4–7 марта 2026',
                    required: true,
                  ),

                  _sectionTitle('Место проведения'),
                  _field(
                    label: 'Короткое название места',
                    controller: locationController,
                    icon: Icons.location_on_outlined,
                    hint: 'ЦМТ, Москва',
                    required: true,
                  ),
                  _field(
                    label: 'Полный адрес',
                    controller: addressController,
                    icon: Icons.signpost_outlined,
                    hint: 'Краснопресненская наб., 12, Москва',
                  ),
                  _field(
                    label: 'Ссылка на карты',
                    controller: mapsUrlController,
                    icon: Icons.map_outlined,
                    hint: 'https://maps.app.goo.gl/...',
                    required: true,
                  ),

                  _sectionTitle('Контакты'),
                  _field(
                    label: 'Telegram',
                    controller: telegramUrlController,
                    icon: Icons.send_outlined,
                    hint: 'https://t.me/euroshoes',
                  ),
                  _field(
                    label: 'Сайт выставки',
                    controller: websiteUrlController,
                    icon: Icons.language_outlined,
                    hint: 'https://www.euroshoes-moscow.ru',
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isSaving ? 'Сохранение...' : 'Сохранить настройки',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
