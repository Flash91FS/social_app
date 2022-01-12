import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_app/resources/storage_methods.dart';

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

        String photoUrl =
        await StorageMethods().uploadImageToStorage('profilePics', imgFile, false);
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
        // await _firestore.collection("users").doc(cred.user!.uid).set(_user.toJson());
        await _firestore.collection("users").doc(cred.user!.uid).set({
          "username": username,
          "uid": cred.user!.uid,
          "photoUrl": photoUrl,
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
      String ress = e.toString();
      print("catch error: $ress");
      if(ress.contains("email address is already in use") || ress.contains("email-already-in-use")){
        res = "The email address is already in use by another account";
      } else if(ress.contains("Password should be at least 6 characters") || ress.contains("weak-password")){
        res = "Password should be at least 6 characters";
      } else if(ress.contains("invalid-email")){
        res = "Please enter a valid email address";
      }
    }
    return res;
  }
}