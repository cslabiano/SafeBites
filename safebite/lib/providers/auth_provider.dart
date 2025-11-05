import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/firebase_auth_api.dart';
import '../models/user_model.dart';

class UserAuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late Stream<User?> _uStream;
  User? userObj;
  UserModel? _userModel;

  UserAuthProvider() {
    authService = FirebaseAuthAPI();
    fetchAuthentication();
  }

  UserModel? get userModel => _userModel;
  String? get nickname => _userModel?.nickname;
  List<String>? get allergies => _userModel?.allergies;

  Stream<User?> get userStream => _uStream;
  User? get user => authService.getUser();

  void fetchAuthentication() {
    _uStream = authService.userSignedIn();
    _uStream.listen((user) {
      if (user != null) {
        _fetchUserModel(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  Future<void> _fetchUserModel(String uid) async {
    _userModel = await authService.getUserModel(uid);
    notifyListeners();
  }

  Future<String?> signUp(UserModel newUser, String password) async {
    final result = await authService.signUp(newUser, password);
    if (result == null) {
      final uid = authService.getUser()?.uid;
      if (uid != null) {
        await _fetchUserModel(uid);
      }
    }
    return result;
  }

  Future<String?> signIn(String email, String password) async {
    final result = await authService.signIn(email, password);
    if (result == null) {
      final uid = authService.getUser()?.uid;
      if (uid != null) {
        await _fetchUserModel(uid);
      }
    }
    return result;
  }

  Future<void> signOut() async {
    await authService.signOut();
    _userModel = null;
    notifyListeners();
  }
}
