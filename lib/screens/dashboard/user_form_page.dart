// lib/screens/dashboard/user_form_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import '../../services/auth_management_service.dart'; // Import auth management service

class UserFormPage extends StatefulWidget {
  // If userData is null, then we're creating a new user.
  final Map<String, dynamic>? userData;
  const UserFormPage({Key? key, this.userData}) : super(key: key);

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  // Form fields
  late String name;
  late String email;
  String? profilePhotoUrl;

  // Dropdown selected values
  String? role;
  String? batch;
  String? department;

  // Predefined lists for dropdowns
  final List<String> roleOptions = [
    'Admin',
    'Security',
    'HOD',
    'Staff Advisor',
    'Student Rep',
    'Student'
  ];
  final List<String> batchOptions = ['2021', '2022', '2023', '2024'];
  final List<String> departmentOptions = ['IT', 'CS', 'MECH', 'EC', 'EEE'];

  // Local file for a selected image
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    // Initialize values. If editing, pre-populate with existing data.
    name = widget.userData?['name'] ?? '';
    email = widget.userData?['email'] ?? '';
    role = widget.userData?['role'] ?? roleOptions.last; // default to Student
    batch = widget.userData?['batch'] ?? batchOptions.first;
    department = widget.userData?['department'] ?? departmentOptions.first;
    profilePhotoUrl = widget.userData?['profilePhotoUrl'];
  }

  /// Lets the admin pick an image from the gallery.
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// Uploads the selected image to Firebase Storage and updates [profilePhotoUrl].
  Future<void> _uploadProfilePhoto(String uid) async {
    if (_selectedImage != null) {
      try {
        String downloadUrl =
            await _storageService.uploadProfilePhoto(uid, _selectedImage!);
        setState(() {
          profilePhotoUrl = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload profile photo: $e")),
        );
      }
    }
  }

  /// Save the user data.
  /// For a new user, create the auth account first to get its UID, then use that UID for the RTDB.
  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String uid;
      bool isNewUser =
          widget.userData == null || widget.userData!['uid'] == null;
      if (isNewUser) {
        // Create auth account first and get the UID.
        try {
          uid = await createAuthUser(email);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create auth user: $e')),
          );
          return;
        }
      } else {
        uid = widget.userData!['uid'];
      }

      // If an image has been selected, upload it first.
      if (_selectedImage != null) {
        await _uploadProfilePhoto(uid);
      }

      // Construct user data including the name.
      Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'role': role,
        'batch': batch,
        'department': department,
        'profilePhotoUrl': profilePhotoUrl ?? '',
      };

      try {
        await _dbService.createOrUpdateUser(uid, userData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User saved successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userData == null ? 'Create User' : 'Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile photo section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (profilePhotoUrl != null &&
                                    profilePhotoUrl!.isNotEmpty
                                ? NetworkImage(profilePhotoUrl!)
                                : const AssetImage('assets/default_avatar.png'))
                            as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name field
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter a name' : null,
                onSaved: (value) => name = value!,
              ),
              const SizedBox(height: 16),
              // Email field
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Enter an email' : null,
                onSaved: (value) => email = value!,
              ),
              const SizedBox(height: 16),
              // Role Dropdown
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: roleOptions
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    role = value;
                  });
                },
                onSaved: (value) => role = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a role' : null,
              ),
              const SizedBox(height: 16),
              // Batch Dropdown
              DropdownButtonFormField<String>(
                value: batch,
                decoration: const InputDecoration(labelText: 'Batch'),
                items: batchOptions
                    .map((b) => DropdownMenuItem(
                          value: b,
                          child: Text(b),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    batch = value;
                  });
                },
                onSaved: (value) => batch = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select a batch' : null,
              ),
              const SizedBox(height: 16),
              // Department Dropdown
              DropdownButtonFormField<String>(
                value: department,
                decoration: const InputDecoration(labelText: 'Department'),
                items: departmentOptions
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text(d),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    department = value;
                  });
                },
                onSaved: (value) => department = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Select a department'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
