/* screens/group_detail_screen.dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import '../models/group_post.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'login_screen.dart';
class GroupDetailScreen extends StatefulWidget {
  final int groupId;
  GroupDetailScreen({required this.groupId});
  @override
  _GroupDetailScreenState createState() => _GroupDetailScreenState();
}
class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final contentController = TextEditingController();
  final imageUrlController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    contentController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }
  Future<void> _refreshGroupPosts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      await Provider.of<GroupProvider>(context, listen: false).fetchGroupPosts(authProvider.token!, widget.groupId);
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    if (authProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
      return SizedBox.shrink();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Group Posts')),
      body: RefreshIndicator(
        onRefresh: _refreshGroupPosts,
        child: Column(
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
                  SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            if (contentController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Content cannot be empty')));
                              return;
                            }
                            setState(() => _isLoading = true);
                            try {
                              await groupProvider.createGroupPost(
                                authProvider.token!,
                                widget.groupId,
                                contentController.text,
                                imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : null,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post created')));
                              contentController.clear();
                              imageUrlController.clear();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create post: ${e.toString()}')));
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          child: Text('Post'),
                        ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<GroupPost>>(
                future: groupProvider.fetchGroupPosts(authProvider.token!, widget.groupId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No posts available'));
                  }
                  final posts = snapshot.data!;
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
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
                                  Text(post.user.name, style: Theme.of(context).textTheme.titleLarge),
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
      ),
    );
  }
}