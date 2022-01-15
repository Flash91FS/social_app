import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/models/user.dart' as model;
import 'package:social_app/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get user details from Firebase
  Future<model.User> getUserDetails() async {
    User currentUser = _firebaseAuth.currentUser!;

    DocumentSnapshot documentSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(documentSnapshot);
  }

  //signup method
  Future<String> signUpUser({
    required String email,
    required String pass,
    required String username,
    required String bio,
    required Uint8List imgFile,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || pass.isNotEmpty || username.isNotEmpty || bio.isNotEmpty || imgFile != null) {
        // registering user in auth with email and password
        UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );

        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', imgFile, false);
        //
        model.User _user = model.User(
          username: username,
          uid: cred.user!.uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
        );

        // adding user in our database
        await _firestore.collection("users").doc(cred.user!.uid).set(_user.toJson());
        // await _firestore.collection("users").doc(cred.user!.uid).set({
        //   "username": username,
        //   "uid": cred.user!.uid,
        //   "photoUrl": photoUrl,
        //   "email": email,
        //   "bio": bio,
        //   "followers": [],
        //   "following": [],
        // });

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      String ress = e.toString();
      print("catch error: $ress");
      if (ress.contains("email address is already in use") || ress.contains("email-already-in-use")) {
        res = "The email address is already in use by another account";
      } else if (ress.contains("Password should be at least 6 characters") || ress.contains("weak-password")) {
        res = "Password should be at least 6 characters";
      } else if (ress.contains("invalid-email")) {
        res = "Please enter a valid email address";
      }
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      String ress = err.toString();
      print("catch error: $ress");
      if (ress.contains("password is invalid") || ress.contains("wrong-password")) {
        res = "Incorrect Password";
      } else if (ress.contains("no user record corresponding to this identifier") || ress.contains("user-not-found")) {
        res = "User not found. Make sure to enter correct email and password.";
      } else if (ress.contains("invalid-email")) {
        res = "Please enter a valid email address";
      } else if (ress.contains("too-many-requests")) {
        res = "Too many requests from this device due to unusual activity. Try again later";
      }
    }
    return res;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
