import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group_post.dart';
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