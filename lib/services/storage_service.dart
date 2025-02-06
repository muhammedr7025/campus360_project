// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StorageService {
  final firebase_storage.FirebaseStorage _storage =
      firebase_storage.FirebaseStorage.instance;

  /// Uploads a profile photo for the given user UID and returns the download URL.
  Future<String> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      // Create a storage reference under "profile_photos/uid"
      firebase_storage.Reference ref =
          _storage.ref().child('profile_photos').child(uid);
      // Upload the file
      firebase_storage.UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      // Retrieve the download URL
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Error uploading profile photo: $e");
    }
  }
}
