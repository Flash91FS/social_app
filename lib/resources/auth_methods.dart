import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      if (email.isNotEmpty ||
          pass.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          imgFile != null) {
        // registering user in auth with email and password
        UserCredential cred = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: pass,
        );

        // String photoUrl =
        // await StorageMethods().uploadImageToStorage('profilePics', file, false);
        //
        // model.User _user = model.User(
        //   username: username,
        //   uid: cred.user!.uid,
        //   photoUrl: photoUrl,
        //   email: email,
        //   bio: bio,
        //   followers: [],
        //   following: [],
        // );

        // adding user in our database
        await _firestore.collection("users").doc(cred.user!.uid).set({
          "username": username,
          "uid": cred.user!.uid,
          // photoUrl: photoUrl,
          "email": email,
          "bio": bio,
          "followers": [],
          "following": [],
        });
        // .set(_user.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (e) {
      String res = e.toString();
      print(res);
    }
    return res;
  }
}