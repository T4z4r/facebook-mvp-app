import '/models/user.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final bool isRead;
  final User sender;
  final User receiver;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.sender,
    required this.receiver,
  });
 factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      isRead: json['is_read'],
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
    );
  }
}