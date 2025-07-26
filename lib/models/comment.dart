import '/models/user.dart';

class Comment {
  final int id;
  final int userId;
  final int postId;
  final String content;
  final User user;

  Comment({required this.id, required this.userId, required this.postId, required this.content, required this.user});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['user_id'],
      postId: json['post_id'],
      content: json['content'],
      user: User.fromJson(json['user']),
    );
  }
}