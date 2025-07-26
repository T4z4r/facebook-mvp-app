/* screens/messages_screen.dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import 'login_screen.dart';
class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}
class _MessagesScreenState extends State<MessagesScreen> {
  final receiverIdController = TextEditingController();
  final messageController = TextEditingController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      Provider.of<MessageProvider>(context, listen: false).connectSocket(authProvider.token!);
    }
  }
  @override
  void dispose() {
    receiverIdController.dispose();
    messageController.dispose();
    Provider.of<MessageProvider>(context, listen: false).disconnectSocket();
    super.dispose();
  }
  Future<void> _refreshMessages() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      await Provider.of<MessageProvider>(context, listen: false).fetchConversations(authProvider.token!);
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messageProvider = Provider.of<MessageProvider>(context);
    if (authProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
      return SizedBox.shrink();
    }
    return RefreshIndicator(
      onRefresh: _refreshMessages,
      child: Column(
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
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          final receiverId = receiverIdController.text.trim();
                          if (receiverId.isEmpty || !RegExp(r'^\d+$').hasMatch(receiverId)) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid Receiver ID')));
                            return;
                          }
                          if (messageController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message cannot be empty')));
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            await messageProvider.sendMessage(
                              authProvider.token!,
                              int.parse(receiverId),
                              messageController.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message sent')));
                            messageController.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: ${e.toString()}')));
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: Text('Send'),
                      ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (context, messageProvider, _) {
                if (messageProvider.conversations.isEmpty) {
                  return Center(child: Text('No messages available'));
                }
                return ListView.builder(
                  itemCount: messageProvider.conversations.length,
                  itemBuilder: (context, index) {
                    final userId = messageProvider.conversations.keys.elementAt(index);
                    final messages = messageProvider.conversations[userId]!;
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Conversation with User ID: $userId', style: Theme.of(context).textTheme.titleLarge),
                            ...messages.map((msg) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text('${msg.sender.name}: ${msg.message} (${msg.isRead ? 'Read' : 'Unread'})'),
                                )),
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