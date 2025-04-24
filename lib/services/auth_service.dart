import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://ayamku.web.id/api'; 
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user_data';
  static const String IS_LOGIN_KEY = 'isLogin';
  static const String EMAIL_KEY = 'email';

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          await _saveUserData(data['user'], data['token']);
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Registrasi gagal',
          'errors': errorData['errors'],
        };
      }
    } catch (e) {
      print('Error during registration: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Coba lagi nanti.',
      };
    }
  }

  // Login function
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['token'] != null) {
          await _saveUserData(data['user'], data['token']);
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(IS_LOGIN_KEY, true);
          await prefs.setString(EMAIL_KEY, email);
        }
        
        return {
          'success': true,
          'data': data,
        };
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login gagal',
          'errors': errorData['errors'],
        };
      }
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Coba lagi nanti.',
      };
    }
  }

  static Future<void> _saveUserData(Map<String, dynamic> userData, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, jsonEncode(userData));
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setBool(IS_LOGIN_KEY, true);
    await prefs.setString(EMAIL_KEY, userData['email'] ?? '');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(USER_KEY);
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGIN_KEY) ?? false;
  }

  // Logout - clear SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_KEY);
    await prefs.remove(IS_LOGIN_KEY);
    await prefs.remove(EMAIL_KEY);
  }
}