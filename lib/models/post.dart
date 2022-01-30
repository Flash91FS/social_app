import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String description;
  final String category;
  final String uid;
  final String username;
  final likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;
  final String lat;
  final String lng;

  const Post(
      {
        required this.title,
        required this.description,
        required this.category,
        required this.uid,
        required this.username,
        required this.likes,
        required this.postId,
        required this.datePublished,
        required this.postUrl,
        required this.profImage,
        required this.lat,
        required this.lng,
      });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        title: snapshot["title"],
        description: snapshot["description"],
        category: snapshot["category"],
        uid: snapshot["uid"],
        likes: snapshot["likes"],
        postId: snapshot["postId"],
        datePublished: snapshot["datePublished"],
        username: snapshot["username"],
        postUrl: snapshot['postUrl'],
        profImage: snapshot['profImage'],
        lat: snapshot['lat'],
        lng: snapshot['lng']
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "category": category,
    "uid": uid,
    "likes": likes,
    "username": username,
    "postId": postId,
    "datePublished": datePublished,
    'postUrl': postUrl,
    'profImage': profImage,
    'lat': lat,
    'lng': lng
  };
}