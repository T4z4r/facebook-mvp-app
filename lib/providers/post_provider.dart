/* providers/post_provider.dart */
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<Post> get posts => _posts;
  Future<void> fetchPosts(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/posts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      _posts = data.map((json) => Post.fromJson(json)).toList();
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to load posts');
    }
  }

  Future<void> createPost(String token, String content,
      {String? imageUrl}) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/posts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content, 'image_url': imageUrl}),
    );
    if (response.statusCode == 201) {
      final newPost = Post.fromJson(jsonDecode(response.body));
      _posts.insert(0, newPost);
      notifyListeners();
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to create post');
    }
  }

  Future<void> addComment(String token, int postId, String content) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/posts/$postId/comments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 201) {
      await fetchPosts(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add comment');
    }
  }

  Future<void> likePost(String token, int postId) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/posts/$postId/likes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 201) {
      await fetchPosts(token);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to like post');
    }
  }
}
