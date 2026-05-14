import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_links.dart';
import '../services/api_service.dart';

class TicketFormScreen extends StatefulWidget {
  const TicketFormScreen({super.key});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final companyController = TextEditingController();
  final positionController = TextEditingController();

  bool isLoading = false;
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

  String? validatePhone(String? value) {
    final error = validateRequired(value, 'Телефон');
    if (error != null) return error;

    final cleaned = value!.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.length < 10) {
      return 'Введите корректный телефон';
    }

    return null;
  }

  String? validateEmail(String? value) {
    final error = validateRequired(value, 'Email');
    if (error != null) return error;

    final email = value!.trim();

    final emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Введите корректный Email';
    }

    return null;
  }

  Future<void> sendTicketRequest() async {
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

    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService.createTicket(
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        company: companyController.text.trim(),
        position: positionController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Заявка отправлена. ID лида: ${data['lead_id']}'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка отправки: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget field({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null ? null : Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
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

  Widget headerBlock() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFACA2C),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Получить пригласительный',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Заполните данные посетителя. После обработки заявки билет появится в разделе “Мой билет”.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    companyController.dispose();
    positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Получить билет'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            headerBlock(),

            field(
              label: 'ФИО *',
              controller: nameController,
              validator: validateFullName,
              icon: Icons.person,
            ),

            field(
              label: 'Телефон *',
              controller: phoneController,
              validator: validatePhone,
              keyboardType: TextInputType.phone,
              icon: Icons.phone,
            ),

            field(
              label: 'Email *',
              controller: emailController,
              validator: validateEmail,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
            ),

            field(
              label: 'Компания *',
              controller: companyController,
              validator: (value) => validateRequired(value, 'Компания'),
              icon: Icons.business,
            ),

            field(
              label: 'Должность *',
              controller: positionController,
              validator: (value) => validateRequired(value, 'Должность'),
              icon: Icons.badge,
            ),

            consentBlock(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendTicketRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACA2C),
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  isLoading ? 'Отправка...' : 'Получить пригласительный',
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