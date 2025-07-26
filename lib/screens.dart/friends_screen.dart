/* screens/friends_screen.dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friend_provider.dart';
class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}
class _FriendsScreenState extends State<FriendsScreen> {
  final friendIdController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    friendIdController.dispose();
    super.dispose();
  }
  Future<void> _refreshFriends() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      await Provider.of<FriendProvider>(context, listen: false).fetchFriends(authProvider.token!);
      await Provider.of<FriendProvider>(context, listen: false).fetchRequests(authProvider.token!);
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final friendProvider = Provider.of<FriendProvider>(context);
    if (authProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
      return SizedBox.shrink();
    }
    return RefreshIndicator(
      onRefresh: _refreshFriends,
      child: Column(
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
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          final friendId = friendIdController.text.trim();
                          if (friendId.isEmpty || !RegExp(r'^\d+$').hasMatch(friendId)) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter a valid Friend ID')));
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            await friendProvider.sendFriendRequest(authProvider.token!, int.parse(friendId));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend request sent')));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send friend request: ${e.toString()}')));
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: Text('Add Friend'),
                      ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<FriendProvider>(
              builder: (context, friendProvider, _) {
                return ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Friend Requests', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    ...friendProvider.requests.map((request) => ListTile(
                          title: Text(request.friend.name),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              try {
                                await friendProvider.acceptFriendRequest(authProvider.token!, request.id);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Friend request accepted')));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to accept friend request: ${e.toString()}')));
                              } finally {
                                setState(() => _isLoading = false);
                              }
                            },
                            child: Text('Accept'),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Friends', style: Theme.of(context).textTheme.titleLarge),
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
