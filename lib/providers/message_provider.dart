import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  Map<int, List<Message>> _conversations = {};

  Map<int, List<Message>> get conversations => _conversations;

  Future<void> fetchConversations(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _conversations = data.map((key, value) => MapEntry(int.parse(key), (value as List).map((m) => Message.fromJson(m)).toList()));
      notifyListeners();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<void> sendMessage(String token, int receiverId, String message) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'receiver_id': receiverId, 'message': message}),
    );

    if (response.statusCode == 201) {
      await fetchConversations(token);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
