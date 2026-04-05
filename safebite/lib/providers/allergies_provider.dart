import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllergiesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _allergies = [];

  List<String> get allergies => _allergies;

  /// fetch user allergies
  Future<void> fetchAllergies() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection("users").doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data();

      _allergies = List<String>.from(data?["allergies"] ?? []);
      notifyListeners();
    }
  }

  /// add allergy
  Future<void> addAllergy(String allergen) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("users").doc(user.uid).update({
      "allergies": FieldValue.arrayUnion([allergen])
    });

    _allergies.add(allergen);
    notifyListeners();
  }

  /// delete allergy
  Future<void> removeAllergy(String allergen) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("users").doc(user.uid).update({
      "allergies": FieldValue.arrayRemove([allergen])
    });

    _allergies.remove(allergen);
    notifyListeners();
  }

  // update allergy
  Future<void> setAllergies(List<String> allergens) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection("users")
        .doc(user.uid)
        .update({"allergies": allergens});

    _allergies = allergens;
    notifyListeners();
  }
}
