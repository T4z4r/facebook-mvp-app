
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