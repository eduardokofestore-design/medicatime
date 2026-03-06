import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'photoUrl': null,
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateProfile(String name, String? photoUrl) async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'photoUrl': photoUrl,
      });
      notifyListeners();
    }
  }

  Future<String?> uploadPhoto(String path) async {
    if (_user != null) {
      Reference ref = _storage.ref().child('profile_pics/${_user!.uid}');
      UploadTask uploadTask = ref.putFile(File(path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Stream<DocumentSnapshot> getUserData() {
    if (_user != null) {
      return _firestore.collection('users').doc(_user!.uid).snapshots();
    }
    return Stream.empty();
  }
}