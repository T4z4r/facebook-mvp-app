/* providers/group_provider.dart */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/group.dart';
import '../models/group_post.dart';

class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];
  List<Group> get groups => _groups;
  Future<void> fetchGroups(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/groups'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      _groups = data.map((json) => Group.fromJson(json)).toList();
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load groups');
    }
  }

  Future<void> createGroup(
      String token, String name, String? description) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/groups'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'description': description}),
    );
    if (response.statusCode == 201) {
      await fetchGroups(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create group');
    }
  }

  Future<void> joinGroup(String token, int groupId) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/groups/$groupId/join'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      await fetchGroups(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to join group');
    }
  }

  Future<void> leaveGroup(String token, int groupId) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/groups/$groupId/leave'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      await fetchGroups(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to leave group');
    }
  }

  Future<List<GroupPost>> fetchGroupPosts(String token, int groupId) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/groups/$groupId/posts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => GroupPost.fromJson(json)).toList();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load group posts');
    }
  }

  Future<void> createGroupPost(String token, int groupId, String content,
      {String? imageUrl}) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/groups/$groupId/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content, 'image_url': imageUrl}),
    );
    if (response.statusCode == 201) {
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create group post');
    }
  }
}
