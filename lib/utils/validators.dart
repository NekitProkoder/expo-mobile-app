class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Заполните поле "$fieldName"';
    }

    if (value.trim().length < 2) {
      return 'Поле "$fieldName" слишком короткое';
    }

    return null;
  }

  static String? fullName(String? value) {
    final error = requiredField(value, 'ФИО');
    if (error != null) return error;

    final parts = value!.trim().split(RegExp(r'\s+'));

    if (parts.length < 2) {
      return 'Введите имя и фамилию';
    }

    return null;
  }

  static String? email(String? value) {
    final error = requiredField(value, 'Email');
    if (error != null) return error;

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Введите корректный Email';
    }

    return null;
  }

  static String? phone(String? value) {
    final error = requiredField(value, 'Телефон');
    if (error != null) return error;

    final cleaned = value!.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleaned.length < 10) {
      return 'Введите корректный телефон';
    }

    return null;
  }

  static String? password(String? value) {
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
}