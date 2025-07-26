import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messageProvider = Provider.of<MessageProvider>(context);
    final receiverIdController = TextEditingController();
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: receiverIdController,
                    decoration: InputDecoration(labelText: 'Receiver ID'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(labelText: 'Message'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await messageProvider.sendMessage(
                        authProvider.token!,
                        int.parse(receiverIdController.text),
                        messageController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message sent')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message')));
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: messageProvider.fetchConversations(authProvider.token!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: messageProvider.conversations.length,
                  itemBuilder: (context, index) {
                    final userId = messageProvider.conversations.keys.elementAt(index);
                    final messages = messageProvider.conversations[userId]!;
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Conversation with User ID: $userId', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...messages.map((msg) => Text('${msg.sender.name}: ${msg.message} (${msg.isRead ? 'Read' : 'Unread'})')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
