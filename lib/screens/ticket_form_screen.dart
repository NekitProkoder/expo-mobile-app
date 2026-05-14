import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../config/app_links.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import '../widgets/app_primary_button.dart';

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

  Future<void> openPrivacy() async {
    await launchUrl(
      Uri.parse(AppLinks.privacyPolicy),
      mode: LaunchMode.externalApplication,
    );
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
        SnackBar(content: Text('Ошибка отправки: $e')),
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

  Widget consentBlock() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: consentAccepted
              ? const Color(0xFFFACA2C)
              : Colors.grey.shade300,
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Получить билет'),
        backgroundColor: AppTheme.primary,
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
              validator: Validators.fullName,
              icon: Icons.person,
            ),
            field(
              label: 'Телефон *',
              controller: phoneController,
              validator: Validators.phone,
              keyboardType: TextInputType.phone,
              icon: Icons.phone,
            ),
            field(
              label: 'Email *',
              controller: emailController,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              icon: Icons.email,
            ),
            field(
              label: 'Компания *',
              controller: companyController,
              validator: (value) =>
                  Validators.requiredField(value, 'Компания'),
              icon: Icons.business,
            ),
            field(
              label: 'Должность *',
              controller: positionController,
              validator: (value) =>
                  Validators.requiredField(value, 'Должность'),
              icon: Icons.badge,
            ),
            consentBlock(),
            AppPrimaryButton(
              text: 'Получить пригласительный',
              onPressed: sendTicketRequest,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}