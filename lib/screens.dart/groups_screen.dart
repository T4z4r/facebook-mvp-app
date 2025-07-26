/* screens/groups_screen.dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/group_provider.dart';
import 'group_detail_screen.dart';
import 'login_screen.dart';

class GroupsScreen extends StatefulWidget {
  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  bool _isLoading = false;
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _refreshGroups() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      await Provider.of<GroupProvider>(context, listen: false)
          .fetchGroups(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    if (authProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      });
      return SizedBox.shrink();
    }
    return RefreshIndicator(
      onRefresh: _refreshGroups,
      child: Column(
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
                  decoration:
                      InputDecoration(labelText: 'Description (optional)'),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Group name cannot be empty')));
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            await groupProvider.createGroup(
                              authProvider.token!,
                              nameController.text,
                              descriptionController.text.isNotEmpty
                                  ? descriptionController.text
                                  : null,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Group created')));
                            nameController.clear();
                            descriptionController.clear();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Failed to create group: ${e.toString()}')));
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: Text('Create Group'),
                      ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<GroupProvider>(
              builder: (context, groupProvider, _) {
                if (groupProvider.groups.isEmpty) {
                  return Center(child: Text('No groups available'));
                }
                return ListView.builder(
                  itemCount: groupProvider.groups.length,
                  itemBuilder: (context, index) {
                    final group = groupProvider.groups[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(group.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        subtitle: Text(group.description ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.exit_to_app),
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              await groupProvider.leaveGroup(
                                  authProvider.token!, group.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Left group')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Failed to leave group: ${e.toString()}')));
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  GroupDetailScreen(groupId: group.id)),
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
