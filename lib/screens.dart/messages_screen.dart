import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import 'post_create_screen.dart';
import 'friends_screen.dart';
import 'messages_screen.dart';
import 'groups_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook MVP'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: postProvider.fetchPosts(authProvider.token!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(post.content),
                      if (post.imageUrl != null) Image.network(post.imageUrl!),
                      Row(
                        children: [
                          Text('${post.likes.length} Likes'),
                          SizedBox(width: 16),
                          Text('${post.comments.length} Comments'),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () async {
                              await postProvider.likePost(authProvider.token!, post.id);
                            },
                            child: Text('Like'),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final commentController = TextEditingController();
                                  return AlertDialog(
                                    title: Text('Add Comment'),
                                    content: TextField(controller: commentController),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await postProvider.addComment(authProvider.token!, post.id, commentController.text);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Submit'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Comment'),
                          ),
                        ],
                      ),
                      ...post.comments.map((comment) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Text('${comment.user.name}: ${comment.content}'),
                          )),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostCreateScreen())),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => FriendsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => GroupsScreen()));
          }
        },
      ),
    );
  }
}
```

### screens/post_create_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';

class PostCreateScreen extends StatefulWidget {
  @override
  _PostCreateScreenState createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "What's on your mind?"),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL (optional)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await postProvider.createPost(
                    authProvider.token!,
                    _contentController.text,
                    imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create post')));
                }
              },
              child: Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### screens/friends_screen.dart
```dart
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
```

### screens/messages_screen.dart
```dart
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
```

### screens/groups_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Groups')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Group Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description (optional)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await groupProvider.createGroup(
                        authProvider.token!,
                        nameController.text,
                        descriptionController.text.isNotEmpty ? descriptionController.text : null,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create group')));
                    }
                  },
                  child: Text('Create Group'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: groupProvider.fetchGroups(authProvider.token!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  itemCount: groupProvider.groups.length,
                  itemBuilder: (context, index) {
                    final group = groupProvider.groups[index];
                    return Card(
                      child: ListTile(
                        title: Text(group.name),
                        subtitle: Text(group.description ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.exit_to_app),
                          onPressed: () async {
                            await groupProvider.leaveGroup(authProvider.token!, group.id);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Left group')));
                          },
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
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
```

### screens/group_detail_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';

class GroupDetailScreen extends StatelessWidget {
  final int groupId;

  GroupDetailScreen({required this.groupId});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final contentController = TextEditingController();
    final imageUrlController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Group Posts')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: "What's on your mind?"),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL (optional)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await groupProvider.createGroupPost(
                        authProvider.token!,
                        groupId,
                        contentController.text,
                        imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created')));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create post')));
                    }
                  },
                  child: Text('Post'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<GroupPost>>(
              future: groupProvider.fetchGroupPosts(authProvider.token!, groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) return Center(child: Text('No posts'));
                final posts = snapshot.data!;
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.user.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(post.content),
                            if (post.imageUrl != null) Image.network(post.imageUrl!),
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
```
