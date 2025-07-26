/* providers/auth_provider.dart */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';
class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  User? get user => _user;
  String? get token => _token;
  Future<void> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _user = User.fromJson(data['user']);
      _token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _user = User.fromJson(data['user']);
      _token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Login failed');
    }
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    _token = null;
    notifyListeners();
  }
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return;
    _token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/user'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    if (response.statusCode == 200) {
      _user = User.fromJson(jsonDecode(response.body));
      notifyListeners();
    } else {
      await prefs.remove('token');
      _token = null;
      _user = null;
    }
  }
}
