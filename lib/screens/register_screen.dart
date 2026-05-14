import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_links.dart';
import '../services/api_service.dart';
import 'main_tabs_screen.dart';

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
  bool showPassword = false;
  bool consentAccepted = false;

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните поле "$fieldName"';
    }

    if (value.trim().length < 2) {
      return 'Поле "$fieldName" слишком короткое';
    }

    return null;
  }

  String? validateFullName(String? value) {
    final error = validateRequired(value, 'ФИО');
    if (error != null) return error;

    final parts = value!.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return 'Введите имя и фамилию';
    }

    return null;
  }

  String? validateEmail(String? value) {
    final error = validateRequired(value, 'Email');
    if (error != null) return error;

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Введите корректный Email';
    }

    return null;
  }

  String? validatePhone(String? value) {
    final error = validateRequired(value, 'Телефон');
    if (error != null) return error;

    final cleaned = value!.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.length < 10) {
      return 'Введите корректный телефон';
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите пароль';
    }

    if (value.length < 6) {
      return 'Пароль должен быть не менее 6 символов';
    }

    if (value.length > 72) {
      return 'Пароль слишком длинный';
    }

    return null;
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!consentAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходимо согласие на обработку персональных данных'),
        ),
      );
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
        MaterialPageRoute(
          builder: (_) => const MainTabsScreen(),
        ),
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

  Widget field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFFACA2C),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget headerBlock() {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFACA2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Создание аккаунта',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Зарегистрируйтесь, чтобы получить пригласительный билет и пользоваться приложением выставки.',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget consentBlock() {
  Future<void> openPrivacy() async {
    await launchUrl(
      Uri.parse(AppLinks.privacyPolicy),
      mode: LaunchMode.externalApplication,
    );
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: consentAccepted ? const Color(0xFFFACA2C) : Colors.grey.shade300,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: consentAccepted,
          activeColor: const Color(0xFFFACA2C),
          checkColor: Colors.black,
          onChanged: (value) {
            setState(() {
              consentAccepted = value ?? false;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Wrap(
              children: [
                const Text(
                  'Я даю согласие на обработку персональных данных в соответствии с ',
                  style: TextStyle(fontSize: 13),
                ),
                GestureDetector(
                  onTap: openPrivacy,
                  child: const Text(
                    'политикой конфиденциальности',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Регистрация'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            headerBlock(),

            field(
              label: 'ФИО *',
              controller: fullNameController,
              validator: validateFullName,
              icon: Icons.person,
            ),

            field(
              label: 'Email *',
              controller: emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
            ),

            field(
              label: 'Телефон *',
              controller: phoneController,
              validator: validatePhone,
              keyboardType: TextInputType.phone,
              icon: Icons.phone,
            ),

            field(
              label: 'Пароль *',
              controller: passwordController,
              validator: validatePassword,
              obscureText: !showPassword,
              icon: Icons.lock,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    showPassword = !showPassword;
                  });
                },
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
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

            consentBlock(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACA2C),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  isLoading ? 'Регистрация...' : 'Зарегистрироваться',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}