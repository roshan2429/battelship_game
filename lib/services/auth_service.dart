import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String baseUrl = 'https://battleships-app.onrender.com';

  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storeToken(data['access_token'], username);
      return 'Logged in successfully!';
    } else {
      return "";
    }
  }

  Future<String> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storeToken(data['access_token'], username);
      return 'Registered successfully!';
    } else {
      return "";
    }
  }

  Future<void> storeToken(String token, String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user', user);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<String?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user');
  }
}
