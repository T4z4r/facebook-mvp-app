/* providers/message_provider.dart */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants.dart';
import '../models/message.dart';

class MessageProvider with ChangeNotifier {
  Map<int, List<Message>> _conversations = {};
  IO.Socket? _socket;
  Map<int, List<Message>> get conversations => _conversations;
  void connectSocket(String token) {
    _socket = IO.io(
      Constants.apiBaseUrl,
      IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders(
          {'Authorization': 'Bearer $token'}).build(),
    );
    _socket?.on('connect', (_) {
      print('Connected to WebSocket');
    });
    _socket?.on('message', (data) {
      final message = Message.fromJson(data);
      _conversations[message.senderId] ??= [];
      _conversations[message.senderId]!.add(message);
      notifyListeners();
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }

  Future<void> fetchConversations(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _conversations = data.map((key, value) => MapEntry(int.parse(key),
          (value as List).map((m) => Message.fromJson(m)).toList()));
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load conversations');
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
      _socket?.emit('message', jsonDecode(response.body));
      await fetchConversations(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to send message');
    }
  }
}
