import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import 'login_screen.dart';
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
