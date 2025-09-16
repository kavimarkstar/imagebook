import 'package:firebase_auth/firebase_auth.dart';
import 'package:imagebook/core/auth/exceptions/auth_exceptions.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in anonymously

  Future<void> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        print('Signed in anonymously: ${user.uid}');
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  }

  //sign in anonymously with auth exceptions
  Future<void> signInAnonymouslywithExceptions() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user != null) {
        print('Signed in anonymously: ${user.uid}');
      }
    } on FirebaseAuthException catch (e) {
      print(
        'Error signing in anonymously: ${mapFirebaseAuthExceptionCode(e.code)}',
      );
      throw Exception(mapFirebaseAuthExceptionCode(e.code));
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  }

  // Sign out

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Signed out');
    } on FirebaseAuthException catch (e) {
      print('Error signing out: ${mapFirebaseAuthExceptionCode(e.code)}');
      throw Exception(mapFirebaseAuthExceptionCode(e.code));
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get the current user

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //create user with email and password

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Error creating user: ${mapFirebaseAuthExceptionCode(e.code)}');
      throw Exception(mapFirebaseAuthExceptionCode(e.code));
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  //sign in with email and password

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print('Error signing in: ${mapFirebaseAuthExceptionCode(e.code)}');

      throw Exception(mapFirebaseAuthExceptionCode(e.code));
    } catch (e) {
      print('Error signing in: $e');
    }
  }

  // Send password reset email

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print(
        'Error sending password reset email: ${mapFirebaseAuthExceptionCode(e.code)}',
      );
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }
}
