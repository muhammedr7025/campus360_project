// lib/services/auth_management_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Creates an auth user for the given [email] with the default password "12345678"
/// using a secondary Firebase app instance, and returns the newly created UID.
Future<String> createAuthUser(String email) async {
  FirebaseApp secondaryApp;
  try {
    secondaryApp = Firebase.app('Secondary');
  } catch (e) {
    secondaryApp = await Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );
  }
  try {
    UserCredential userCredential =
        await FirebaseAuth.instanceFor(app: secondaryApp)
            .createUserWithEmailAndPassword(email: email, password: "12345678");
    String newUid = userCredential.user!.uid;
    await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
    print('Auth user for $email created successfully. UID: $newUid');
    return newUid;
  } catch (e) {
    print('Error creating auth user for $email: $e');
    throw e;
  }
}

/// Deletes the auth user for the given [email] using a secondary Firebase app instance.
/// It signs in with the default password "12345678" and then deletes the account.
Future<void> deleteAuthUser(String email) async {
  FirebaseApp secondaryApp;
  try {
    secondaryApp = Firebase.app('Secondary');
  } catch (e) {
    secondaryApp = await Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );
  }
  try {
    UserCredential userCredential =
        await FirebaseAuth.instanceFor(app: secondaryApp)
            .signInWithEmailAndPassword(email: email, password: "12345678");
    await userCredential.user?.delete();
    await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
    print('Auth user for $email deleted successfully.');
  } catch (e) {
    print('Error deleting auth user for $email: $e');
    throw e;
  }
}
