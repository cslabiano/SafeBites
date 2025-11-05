import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/firebase_auth_api.dart';
import '../models/user_model.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> _uStream;
  User? userObj;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    fetchAuthentication();
  }

  Stream<User?> get userStream => _uStream;
  User? get user => authService.getUser();

  void fetchAuthentication() {
    _uStream = authService.userSignedIn();
    notifyListeners();
  }

  Future<String?> signUp(UserModel newUser, String password) async {
    final result = await authService.signUp(newUser, password);
    if (result == null) {
      notifyListeners();
    }
    return result;
  }

  Future<String?> signIn(String email, String password) async {
    final result = await authService.signIn(email, password);
    if (result == null) {
      notifyListeners();
    }
    return result;
  }

  Future<void> signOut() async {
    await authService.signOut();
    notifyListeners();
  }
}
