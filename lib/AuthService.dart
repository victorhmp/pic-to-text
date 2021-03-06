import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User> getUser() {
    return Future(() => _auth.currentUser);
  }

  Future logout() async {
    await googleSignIn.signOut();

    await FirebaseAuth.instance.signOut();

    notifyListeners();
  }

  Future<User> loginUser() async {
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      final User user = authResult.user;

      var userDocument =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDocument.exists) {
        _firestore.collection('users').doc(user.uid).set(
          {'history': []},
        );
      }

      notifyListeners();

      return user;
    } catch (e) {
      throw new FirebaseAuthException(
        code: e.code,
        message: e.message,
      );
    }
  }
}
