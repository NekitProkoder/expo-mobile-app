import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import 'profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final companyController = TextEditingController();
  final positionController = TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        company: companyController.text.trim(),
        position: positionController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка регистрации: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    companyController.dispose();
    positionController.dispose();
    super.dispose();
  }

  Widget field(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: AppTheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(
            children: [
              const Text(
                'Создание аккаунта',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              field(
                'ФИО',
                fullNameController,
                validator: Validators.fullName,
              ),

              field(
                'Email',
                emailController,
                validator: Validators.email,
              ),

              field(
                'Телефон',
                phoneController,
                validator: Validators.phone,
              ),

              field(
                'Пароль',
                passwordController,
                isPassword: true,
                validator: Validators.password,
              ),

              field(
                'Компания',
                companyController,
                validator: (v) =>
                    Validators.requiredField(v, 'Компания'),
              ),

              field(
                'Должность',
                positionController,
                validator: (v) =>
                    Validators.requiredField(v, 'Должность'),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACA2C),
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(
                  isLoading
                      ? 'Регистрация...'
                      : 'Зарегистрироваться',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}