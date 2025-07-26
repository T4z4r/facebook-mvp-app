import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friend_provider.dart';

class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    final friendIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Friends')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: friendIdController,
                    decoration: InputDecoration(labelText: 'Enter Friend ID'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await friendProvider.sendFriendRequest(authProvider.token!, int.parse(friendIdController.text));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend request sent')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send friend request')));
                    }
                  },
                  child: Text('Add Friend'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                friendProvider.fetchFriends(authProvider.token!),
                friendProvider.fetchRequests(authProvider.token!),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Friend Requests', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...friendProvider.requests.map((request) => ListTile(
                          title: Text(request.friend.name),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await friendProvider.acceptFriendRequest(authProvider.token!, request.id);
                            },
                            child: Text('Accept'),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Friends', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...friendProvider.friends.map((friend) => ListTile(title: Text(friend.friend.name))),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
