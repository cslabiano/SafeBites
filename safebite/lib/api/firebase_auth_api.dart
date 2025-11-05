import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  User? getUser() {
    return auth.currentUser;
  }

  Stream<User?> userSignedIn() {
    // status ng authentication, may nakasign in ba or wala
    return auth.authStateChanges();
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      // return the Firebase Auth error code
      return e.code;
    } catch (e) {
      // handle other exceptions
      return "Failed to sign in: $e";
    }
  }

  Future<String?> signUp(UserModel newUser, String password) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: newUser.email,
        password: password,
      );

      // set the nickname as the Firebase User's displayName (best-effort)
      try {
        await userCredential.user?.updateDisplayName(newUser.nickname);
      } catch (e) {
        // ignore display name update failures so sign up can succeed
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.code; // return the specific Firebase error code
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return "An unknown error occurred.";
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
