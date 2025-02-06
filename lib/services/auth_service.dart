// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } catch (error) {
      throw Exception("Sign in failed: $error");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> createAuthUser(String email) async {
    // Try to get the secondary app instance; if it doesn't exist, initialize it.
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
      // Create a new user with the default password "12345678" on the secondary app.
      await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: "12345678");
      // Sign out from the secondary instance to clean up.
      await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
      print('Auth user for $email created successfully.');
    } catch (e) {
      print('Error creating auth user for $email: $e');
    }
  }

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
      // Sign in as the user to be deleted using the default password.
      UserCredential userCredential =
          await FirebaseAuth.instanceFor(app: secondaryApp)
              .signInWithEmailAndPassword(email: email, password: "12345678");
      // Delete the user account.
      await userCredential.user?.delete();
      // Sign out from the secondary instance.
      await FirebaseAuth.instanceFor(app: secondaryApp).signOut();
      print('Auth user for $email deleted successfully.');
    } catch (e) {
      print('Error deleting auth user for $email: $e');
    }
  }
}
