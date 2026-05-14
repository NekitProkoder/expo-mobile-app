import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class ApiService {
  static String baseUrl = ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String company,
    required String position,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'company': company,
        'position': position,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data['access_token']);
      return data;
    }

    throw Exception(data['detail'] ?? 'Ошибка регистрации');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data['access_token']);
      return data;
    }

    throw Exception(data['detail'] ?? 'Ошибка входа');
  }

  static Future<UserModel> getProfile() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/api/profile'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }

  return UserModel.fromJson(jsonDecode(response.body));
}

  static Future<List<dynamic>> getTickets() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/api/tickets'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception('Ошибка получения билетов');
  }

  static Future<Map<String, dynamic>> createTicket({
    required String fullName,
    required String phone,
    required String email,
    required String company,
    required String position,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/api/ticket'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_name': fullName,
        'phone': phone,
        'email': email,
        'company': company,
        'position': position,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['detail'] ?? 'Ошибка создания билета');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  static Future<List<dynamic>> getExhibitors() async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/exhibitors'),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }

  return jsonDecode(response.body);
}

static Future<void> createExhibitor(Map<String, dynamic> data) async {
  final token = await getToken();

  final response = await http.post(
    Uri.parse('$baseUrl/api/admin/exhibitors'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

static Future<void> deleteExhibitor(int id) async {
  final token = await getToken();

  final response = await http.delete(
    Uri.parse('$baseUrl/api/admin/exhibitors/$id'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

static Future<void> updateExhibitor(int id, Map<String, dynamic> data) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse('$baseUrl/api/admin/exhibitors/$id'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(data),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}
static Future<List<dynamic>> getAdminUsers() async {
  final token = await getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/api/admin/users'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }

  return jsonDecode(response.body);
}
static Future<void> setUserAdmin(int userId, bool isAdmin) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse('$baseUrl/api/admin/users/$userId/admin?is_admin=$isAdmin'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}
static Future<void> updateProfile({
  required String fullName,
  required String phone,
  String? company,
  String? position,
}) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse('$baseUrl/api/profile'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'full_name': fullName,
      'phone': phone,
      'company': company,
      'position': position,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}

static Future<void> changePassword({
  required String oldPassword,
  required String newPassword,
}) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse('$baseUrl/api/profile/change-password'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'old_password': oldPassword,
      'new_password': newPassword,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception(response.body);
  }
}
  static Future<Map<String, dynamic>> getEventSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/settings'),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateEventSettings(
      Map<String, dynamic> data) async {
    final token = await getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/api/admin/settings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    return jsonDecode(response.body);
  }

}