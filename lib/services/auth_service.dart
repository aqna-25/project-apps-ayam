import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://ayamku.web.id/api';
  static const String TOKEN_KEY = 'auth_token';
  static const String USER_KEY = 'user_data';
  static const String USER_ID_KEY = 'user_id';
  static const String IS_LOGIN_KEY = 'isLogin';
  static const String EMAIL_KEY = 'email';

  // Register function
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String noHp,
    String tglLahir,
    String provinsi,
    String kota,
    String alamat,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,

          'no_hp': noHp,
          'tgl_lahir': tglLahir,
          'provinsi': provinsi,
          'kota': kota,
          'alamat': alamat,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveUserData(data['user'], data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Registrasi gagal',
          'errors': errorData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Coba lagi nanti.',
      };
    }
  }

  // Login function
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['token'] != null && data['user'] != null) {
          await _saveUserData(data['user'], data['token']);
          // Set user_id secara terpisah untuk memastikan tersimpan
          final prefs = await SharedPreferences.getInstance();
          if (data['user']['id'] != null) {
            await prefs.setInt(USER_ID_KEY, data['user']['id']);
          }
        }
        return {'success': true, 'data': data};
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login gagal',
          'errors': errorData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi. Coba lagi nanti.',
      };
    }
  }

  static Future<void> _saveUserData(
    Map<String, dynamic> userData,
    String token,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_KEY, jsonEncode(userData));
    await prefs.setString(TOKEN_KEY, token);
    await prefs.setBool(IS_LOGIN_KEY, true);
    await prefs.setString(EMAIL_KEY, userData['email'] ?? '');
    // Simpan user_id secara eksplisit
    if (userData['id'] != null) {
      await prefs.setInt(USER_ID_KEY, userData['id']);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TOKEN_KEY);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(USER_ID_KEY);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(USER_KEY);
    if (userString != null) {
      return jsonDecode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(IS_LOGIN_KEY) ?? false;
  }

  // Validasi token dengan mengambil data user terbaru
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // Update user data di SharedPreferences
        if (userData != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(USER_KEY, jsonEncode(userData));
          if (userData['id'] != null) {
            await prefs.setInt(USER_ID_KEY, userData['id']);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Logout - clear SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TOKEN_KEY);
    await prefs.remove(USER_KEY);
    await prefs.remove(USER_ID_KEY); // Hapus juga user_id
    await prefs.remove(IS_LOGIN_KEY);
    await prefs.remove(EMAIL_KEY);
  }
}
