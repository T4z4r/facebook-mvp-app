import 'user.dart';

class GroupPost {
  final int id;
  final int groupId;
  final int userId;
  final String content;
  final String? imageUrl;
  final User user;

  GroupPost({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.user,
  });

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      user: User.fromJson(json['user']),
    );
  }
}