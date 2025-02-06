// lib/screens/dashboard/admin_user_management_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/database_service.dart';
import '../../services/auth_management_service.dart'; // Import the auth management service
import 'user_form_page.dart'; // Import the user form page for editing/creating

class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({Key? key}) : super(key: key);

  @override
  _AdminUserManagementPageState createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final DatabaseService _dbService = DatabaseService();
  final DatabaseReference _userRef =
      FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    // Listen for real-time updates to the "users" node.
    _userRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      List<Map<String, dynamic>> users = [];
      if (data != null) {
        data.forEach((key, value) {
          Map<String, dynamic> userData = Map<String, dynamic>.from(value);
          userData['uid'] = key;
          users.add(userData);
        });
      }
      setState(() {
        userList = users;
      });
    });
  }

  // Delete user action
  void _deleteUser(String uid, String email) async {
    try {
      await _dbService.deleteUser(uid);
      // Delete the authentication account using the secondary app instance.
      await deleteAuthUser(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }

  // Navigate to the User Form page for editing
  void _editUser(Map<String, dynamic> userData) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserFormPage(userData: userData),
        ));
  }

  // Navigate to the User Form page for creating a new user
  void _createUser() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserFormPage(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createUser,
          )
        ],
      ),
      body: userList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return ListTile(
                  // Leading CircleAvatar displays the profile image
                  leading: CircleAvatar(
                    backgroundImage: (user['profilePhotoUrl'] != null &&
                            user['profilePhotoUrl'].toString().isNotEmpty)
                        ? NetworkImage(user['profilePhotoUrl'])
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  title: Text(user['name'] ?? user['email'] ?? 'No Name'),
                  subtitle: Text(user['role'] ?? 'No Role'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editUser(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deleteUser(user['uid'], user['email']),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}
