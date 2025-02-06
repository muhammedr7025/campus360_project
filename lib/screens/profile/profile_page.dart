// lib/screens/profile/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database_service.dart' show DatabaseService;
import '../../services/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String? _profilePhotoUrl;
  final StorageService _storageService = StorageService();
  final DatabaseService _databaseService = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAndSaveProfilePhoto() async {
    if (_selectedImage != null) {
      try {
        String uid = _auth.currentUser!.uid;
        String downloadUrl =
            await _storageService.uploadProfilePhoto(uid, _selectedImage!);
        // Update the user profile with the new photo URL
        final userData = {
          'email': _auth.currentUser!.email,
          'role': 'Student', // or the user's actual role
          'batch': '2021',
          'department': 'IT',
          'profilePhotoUrl': downloadUrl,
        };
        await _databaseService.createOrUpdateUser(uid, userData);
        setState(() {
          _profilePhotoUrl = downloadUrl;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: _profilePhotoUrl != null
                  ? NetworkImage(_profilePhotoUrl!)
                  : (_selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider
                      : const AssetImage('assets/default_avatar.png')),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _uploadAndSaveProfilePhoto,
            child: const Text('Upload Profile Photo'),
          ),
        ],
      ),
    );
  }
}
