import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CORRECT for v6.1.6:
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get firebaseUser => _auth.currentUser;
  UserModel? userModel;

  bool isLoading = false;

  AuthService() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      userModel = UserModel.fromMap(doc.data()!);
    }
  }

  // ADDED: Public method to refresh user data
  Future<void> refreshUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
      notifyListeners();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn().timeout(
        const Duration(seconds: 15),
      );

      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return "Sign in cancelled";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      await _createUserIfNotExists(userCredential.user!, false);

      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Google sign in failed: $e";
    }
  }

  Future<String?> signInAsGuest() async {
    try {
      isLoading = true;
      notifyListeners();

      final userCredential = await _auth.signInAnonymously().timeout(
        const Duration(seconds: 15),
      );

      await _createUserIfNotExists(userCredential.user!, true);

      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Guest login failed: $e";
    }
  }

  Future<void> _createUserIfNotExists(User user, bool isGuest) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        "uid": user.uid,
        "name": isGuest ? "Guest User" : user.displayName ?? "User",
        "email": user.email,
        "role": "client",
        "isGuest": isGuest,
        "isBanned": false,
        "field": null,
        "idVerified": false,
        "rating": 0,
        "totalReviews": 0,
        "totalJobs": 0,
        "earnings": 0,
        "monthlyEarnings": 0,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    await _loadUserData(user.uid);
  }

  Future<void> updateRole(String role, {String? field}) async {
    await _firestore.collection('users').doc(firebaseUser!.uid).update({
      "role": role,
      "field": field,
    });

    await _loadUserData(firebaseUser!.uid);
    notifyListeners();
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}