import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool isLoading = false;
  bool showOldPassword = false;
  bool showNewPassword = false;
  bool showRepeatPassword = false;

  String? validateRepeatPassword(String? value) {
    final error = Validators.password(value);
    if (error != null) return error;

    if (value != newPasswordController.text) {
      return 'Пароли не совпадают';
    }

    return null;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await ApiService.changePassword(
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль успешно изменён')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка смены пароля: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Смена пароля'),
        backgroundColor: AppTheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            passwordField(
              label: 'Старый пароль',
              controller: oldPasswordController,
              obscureText: !showOldPassword,
              validator: Validators.password,
              onToggle: () {
                setState(() {
                  showOldPassword = !showOldPassword;
                });
              },
            ),
            passwordField(
              label: 'Новый пароль',
              controller: newPasswordController,
              obscureText: !showNewPassword,
              validator: Validators.password,
              onToggle: () {
                setState(() {
                  showNewPassword = !showNewPassword;
                });
              },
            ),
            passwordField(
              label: 'Повторите новый пароль',
              controller: repeatPasswordController,
              obscureText: !showRepeatPassword,
              validator: validateRepeatPassword,
              onToggle: () {
                setState(() {
                  showRepeatPassword = !showRepeatPassword;
                });
              },
            ),
            const SizedBox(height: 10),
            AppPrimaryButton(
              text: 'Изменить пароль',
              onPressed: save,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}