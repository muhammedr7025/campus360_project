import 'package:firebase_database/firebase_database.dart';

Future<String> getUserName(String uid) async {
  DatabaseReference userNameRef =
      FirebaseDatabase.instance.ref().child('users').child(uid).child('name');
  DataSnapshot snapshot = await userNameRef.get();
  if (snapshot.exists && snapshot.value != null) {
    return snapshot.value.toString();
  }
  return uid; // Fallback to UID if name not found.
}
