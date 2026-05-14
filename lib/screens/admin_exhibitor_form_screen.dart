import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminExhibitorFormScreen extends StatefulWidget {
  final Map? exhibitor;

  const AdminExhibitorFormScreen({
    super.key,
    this.exhibitor,
  });

  @override
  State<AdminExhibitorFormScreen> createState() =>
      _AdminExhibitorFormScreenState();
}

class _AdminExhibitorFormScreenState extends State<AdminExhibitorFormScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final standController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final websiteController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final logoController = TextEditingController();

  bool isSaving = false;

  bool get isEdit => widget.exhibitor != null;

  @override
  void initState() {
    super.initState();

    final item = widget.exhibitor;

    if (item != null) {
      nameController.text = item['name'] ?? '';
      descriptionController.text = item['description'] ?? '';
      categoryController.text = item['category'] ?? '';
      standController.text = item['stand_number'] ?? '';
      countryController.text = item['country'] ?? '';
      cityController.text = item['city'] ?? '';
      websiteController.text = item['website'] ?? '';
      phoneController.text = item['phone'] ?? '';
      emailController.text = item['email'] ?? '';
      logoController.text = item['logo_url'] ?? '';
    }
  }

  Widget field(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> save() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название компании')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final data = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'category': categoryController.text.trim(),
      'stand_number': standController.text.trim(),
      'country': countryController.text.trim(),
      'city': cityController.text.trim(),
      'website': websiteController.text.trim(),
      'phone': phoneController.text.trim(),
      'email': emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      'logo_url': logoController.text.trim(),
    };

    try {
      if (isEdit) {
        await ApiService.updateExhibitor(widget.exhibitor!['id'], data);
      } else {
        await ApiService.createExhibitor(data);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    standController.dispose();
    countryController.dispose();
    cityController.dispose();
    websiteController.dispose();
    phoneController.dispose();
    emailController.dispose();
    logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать участника' : 'Добавить участника'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          field('Название компании *', nameController),
          field('Описание', descriptionController),
          field('Категория', categoryController),
          field('Номер стенда', standController),
          field('Страна', countryController),
          field('Город', cityController),
          field('Сайт', websiteController),
          field('Телефон', phoneController),
          field('Email', emailController),
          field('Ссылка на логотип', logoController),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isSaving ? null : save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFACA2C),
              padding: const EdgeInsets.all(16),
            ),
            child: Text(
              isSaving
                  ? 'Сохранение...'
                  : isEdit
                      ? 'Сохранить изменения'
                      : 'Сохранить участника',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}