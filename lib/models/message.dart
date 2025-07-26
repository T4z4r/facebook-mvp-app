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
}
