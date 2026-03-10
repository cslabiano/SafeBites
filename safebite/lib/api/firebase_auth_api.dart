import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static const String userCollection = 'users';

  User? getUser() {
    return auth.currentUser;
  }

  Stream<User?> userSignedIn() {
    // status ng authentication, may nakasign in ba or wala
    return auth.authStateChanges();
  }

  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await db.collection(userCollection).doc(uid).get();
      if (doc.exists) {
        // assuming UserModel has a fromJson factory constructor
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print("error fetching user model: $e");
      return null;
    }
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

      final uid = userCredential.user?.uid;
      if (uid != null) {
        await db.collection(userCollection).doc(uid).set({
          'email': newUser.email,
          'nickname': newUser.nickname,
          'allergies': newUser.allergies ?? [],
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.code; // return the specific firebase error code
    } catch (e) {
      // ignore: avoid_print
      print(e);
      return "an unknown error occurred.";
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
  }
}
