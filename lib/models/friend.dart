import '/models/user.dart';

class Friend {
  final int id;
  final int userId;
  final int friendId;
  final String status;
  final User friend;

  Friend({required this.id, required this.userId, required this.friendId, required this.status, required this.friend});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      userId: json['user_id'],
      friendId: json['friend_id'],
      status: json['status'],
      friend: User.fromJson(json['friend']),
    );
  }
}