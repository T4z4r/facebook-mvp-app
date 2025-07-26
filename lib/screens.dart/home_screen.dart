import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/friend_provider.dart';
import '../providers/group_provider.dart';
import '../providers/message_provider.dart';
import '../providers/post_provider.dart';
import 'login_screen.dart';
import 'post_create_screen.dart';
import 'friends_screen.dart';
import 'messages_screen.dart';
import 'groups_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts(authProvider.token!);
      Provider.of<FriendProvider>(context, listen: false).fetchFriends(authProvider.token!);
      Provider.of<MessageProvider>(context, listen: false).fetchConversations(authProvider.token!);
      Provider.of<GroupProvider>(context, listen: false).fetchGroups(authProvider.token!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshPosts(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      await Provider.of<PostProvider>(context, listen: false).fetchPosts(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.token == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Session expired. Please log in again.'),
              ElevatedButton(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
                },
                child: Text('Log In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Facebook MVP'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await authProvider.logout();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(),
          FriendsScreen(),
          MessagesScreen(),
          GroupsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PostCreateScreen())),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.home), text: 'Home'),
          Tab(icon: Icon(Icons.people), text: 'Friends'),
          Tab(icon: Icon(Icons.message), text: 'Messages'),
          Tab(icon: Icon(Icons.group), text: 'Groups'),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        return RefreshIndicator(
          onRefresh: () => _refreshPosts(context),
          child: postProvider.posts.isEmpty
              ? Center(child: Text('No posts available'))
              : ListView.builder(
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: post.user.avatar != null ? NetworkImage(post.user.avatar!) : null,
                                  child: post.user.avatar == null ? Text(post.user.name[0]) : null,
                                  radius: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  post.user.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(post.content, style: Theme.of(context).textTheme.bodyMedium),
                            if (post.imageUrl != null)
                              CachedNetworkImage(
                                imageUrl: post.imageUrl!,
                                placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            SizedBox(height: 8),
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
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                                                if (commentController.text.isNotEmpty) {
                                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                                  await postProvider.addComment(authProvider.token!, post.id, commentController.text);
                                                  Navigator.pop(context);
                                                }
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
                ),
        );
      },
    );
  }
}