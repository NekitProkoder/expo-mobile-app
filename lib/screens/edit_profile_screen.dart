import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController companyController;
  late final TextEditingController positionController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fullNameController = TextEditingController(text: widget.user.fullName);
    phoneController = TextEditingController(text: widget.user.phone);
    companyController = TextEditingController(text: widget.user.company ?? '');
    positionController = TextEditingController(text: widget.user.position ?? '');
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ApiService.updateProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        company: companyController.text.trim(),
        position: positionController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль обновлён')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    companyController.dispose();
    positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: AppTheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            field(
              label: 'ФИО *',
              controller: fullNameController,
              validator: Validators.fullName,
              icon: Icons.person,
            ),
            field(
              label: 'Телефон *',
              controller: phoneController,
              validator: Validators.phone,
              icon: Icons.phone,
            ),
            field(
              label: 'Компания',
              controller: companyController,
              validator: (_) => null,
              icon: Icons.business,
            ),
            field(
              label: 'Должность',
              controller: positionController,
              validator: (_) => null,
              icon: Icons.badge,
            ),
            const SizedBox(height: 10),
            AppPrimaryButton(
              text: 'Сохранить изменения',
              onPressed: save,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}