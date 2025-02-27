import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/resources/storage_methods.dart';
import 'package:social_app/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String title,
    String description,
    String category,
    String categoryID,
    Uint8List? file,
    String uid,
    String username,
    String profImage,
    String lat,
    String lng,
  ) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl = "";
      if (file != null) {
        await StorageMethods().uploadImageToStorage('posts', file, true);
      }
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        title: title,
        description: description,
        category: category,
        categoryID: categoryID,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        imagesList: [],
        multiImages: "0",
        profImage: profImage,
        lat: lat,
        lng: lng,
        videoURL: "",
        hasVideo: "",
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadPostMultiImages(
      String title,
      String description,
      String category,
      String categoryID,
      List<Uint8List> imgList,
      String uid,
      String username,
      String profImage,
      String lat,
      String lng,
      ) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      List photoUrlsList = [];
      for (Uint8List img in imgList){
        String photoUrl = await StorageMethods().uploadImageToStorage('posts', img, true);
        photoUrlsList.add(photoUrl);
      }
      // String photoUrl = await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        title: title,
        description: description,
        category: category,
        categoryID: categoryID,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: "",
        imagesList: photoUrlsList,
        multiImages: "1",
        profImage: profImage,
        lat: lat,
        lng: lng,
        videoURL: "",
        hasVideo: "",
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likeComment(String postId,String commentId, String uid, List likes) async {
    log("FirebaseMethods -- likeComment() :");
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
      log("FirebaseMethods -- likeComment() : Exception : ${err.toString()}");
    }
    return res;
  }

  Future<String> likeReply(String postId,String commentId,String replyId, String uid, List likes) async {
    log("FirebaseMethods -- likeReply() :");
    log("FirebaseMethods -- likeReply() : postId == $postId");
    log("FirebaseMethods -- likeReply() : commentId == $commentId");
    log("FirebaseMethods -- likeReply() : replyId == $replyId");
    log("FirebaseMethods -- likeReply() : uid == $uid");
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).collection('replies').doc(replyId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).collection('replies').doc(replyId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
      log("FirebaseMethods -- likeReply() : Exception : ${err.toString()}");
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid, String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
      log("FirebaseMethods -- postComment() : Exception : ${err.toString()}");
    }
    return res;
  }

  // Post comment
  Future<String> postReply(String postId, String commentId, String text, String uid, String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String replyId = const Uuid().v1();
        _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).collection('replies').doc(replyId).set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'replyId': replyId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
      log("FirebaseMethods -- postReply() : Exception : ${err.toString()}");
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postLastMessage({
    required String uid, required String uName, required String uPic,
    required String chatId, required String text, required String friendId,
    required String friendName, required String friendProfilePic, required DateTime dateTime
  }) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        if(chatId=="") {
          chatId = const Uuid().v1();
        }

        _firestore.collection('users').doc(uid).collection('chats').doc(chatId).set({
          'chatId': chatId,
          'friendId': friendId,
          'friendName': friendName,
          'friendPic': friendProfilePic,
          'uid': uid,
          'text': text,
          'datePublished': dateTime,
        });

        _firestore.collection('users').doc(friendId).collection('chats').doc(chatId).set({
          'chatId': chatId,
          'friendId': uid,
          'friendName': uName,
          'friendPic': uPic,
          'uid': friendId,
          'text': text,
          'datePublished': dateTime,
        });

        res = 'success: $chatId';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postChatMessage(String chatId, DateTime datePublished, String text,
      String uid, String name, String profilePic) async {
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String messageId = const Uuid().v1();
        _firestore.collection('chats').doc(chatId).collection('messages').doc(messageId).set({
          'chatId': chatId,
          'messageId': messageId,
          'datePublished': datePublished,
          'senderID': uid,
          'senderName': name,
          'senderPic': profilePic,
          'text': text,
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postAppAllowed(String allowed) async {
    String res = "Some error occurred";
    var mDate = DateTime.now();
    try {
        _firestore.collection('appAllowed').doc("some-random-id").set({
          'isAllowed': allowed,
          'datePublished': mDate,
        });
        res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
