import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/friend.dart';

class FriendProvider with ChangeNotifier {
  List<Friend> _friends = [];
  List<Friend> _requests = [];

  List<Friend> get friends => _friends;
  List<Friend> get requests => _requests;

  Future<void> fetchFriends(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/friends'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      _friends = data.map((json) => Friend.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  Future<void> fetchRequests(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/friends/requests'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      _requests = data.map((json) => Friend.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load friend requests');
    }
  }

  Future<void> sendFriendRequest(String token, int friendId) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/friends'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'friend_id': friendId}),
    );

    if (response.statusCode == 201) {
      notifyListeners();
    } else {
      throw Exception('Failed to send friend request');
    }
  }

  Future<void> acceptFriendRequest(String token, int friendId) async {
    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/friends/$friendId/accept'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await fetchFriends(token);
      await fetchRequests(token);
    } else {
      throw Exception('Failed to accept friend request');
    }
  }
}
