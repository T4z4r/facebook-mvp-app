import '/models/comment.dart';

import '/models/user.dart';

class Post {
  final int id;
  final int userId;
  final String content;
  final String? imageUrl;
  final User user;
  final List<Comment> comments;
  final List<dynamic> likes;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.user,
    required this.comments,
    required this.likes,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      user: User.fromJson(json['user']),
      comments: (json['comments'] as List).map((c) => Comment.fromJson(c)).toList(),
      likes: json['likes'],
    );
  }
}