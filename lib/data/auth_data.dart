import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRemote {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle login
  Future<bool> login(String email, String password) async {
    try {
      // Attempt to sign in with email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true; // Login successful
    } catch (e) {
      print('Login failed: $e');
      return false; // Login failed
    }
  }

  // Function to handle signup
  Future<bool> signUp(String email, String password) async {
    try {
      // Attempt to create a new user
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true; // Signup successful
    } catch (e) {
      print('Signup failed: $e');
      return false; // Signup failed
    }
  }

  // Function to sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if a user is logged in
  User? get currentUser {
    return _auth.currentUser;
  }
}
