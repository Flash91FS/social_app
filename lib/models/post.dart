import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String title;
  final String description;
  final String category;
  final String categoryID;
  final String uid;
  final String username;
  final likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final imagesList;
  final String multiImages;
  final String profImage;
  final String lat;
  final String lng;
  final String videoURL;
  final String hasVideo;

  const Post(
      {
        required this.title,
        required this.description,
        required this.category,
        required this.categoryID,
        required this.uid,
        required this.username,
        required this.likes,
        required this.postId,
        required this.datePublished,
        required this.postUrl,
        required this.profImage,
        required this.lat,
        required this.lng,
        required this.videoURL,
        required this.hasVideo,
        required this.imagesList,
        required this.multiImages,
      });

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        title: snapshot["title"],
        description: snapshot["description"],
        category: snapshot["category"],
        categoryID: snapshot["categoryID"],
        uid: snapshot["uid"],
        likes: snapshot["likes"],
        postId: snapshot["postId"],
        datePublished: snapshot["datePublished"].toDate(),
        username: snapshot["username"],
        postUrl: snapshot['postUrl'],
        imagesList: snapshot["imagesList"],
        multiImages: snapshot["multiImages"],
        profImage: snapshot['profImage'],
        lat: snapshot['lat'],
        lng: snapshot['lng'],
        videoURL: snapshot['videoURL'],
        hasVideo: snapshot['hasVideo']
    );
  }

  static Post fromMap(Map<String, dynamic> snapshot) {
    // var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        title: snapshot["title"] ?? "",
        description: snapshot["description"] ?? "",
        category: snapshot["category"] ?? "",
        categoryID: snapshot["categoryID"] ?? "0",
        uid: snapshot["uid"] ?? "123",
        likes: snapshot["likes"],
        postId: snapshot["postId"] ?? "456",
        datePublished: snapshot["datePublished"].toDate(),
        username: snapshot["username"] ?? "",
        postUrl: snapshot['postUrl'] ?? "",
        imagesList: snapshot["imagesList"] ?? [],
        multiImages: snapshot["multiImages"] ?? "0000",
        profImage: snapshot['profImage'] ?? "",
        lat: snapshot['lat'] ?? "0.0",
        lng: snapshot['lng'] ?? "0.0",
        videoURL: snapshot['videoURL'] ?? "",
        hasVideo: snapshot['hasVideo'] ?? ""
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "category": category,
    "categoryID": categoryID,
    "uid": uid,
    "likes": likes,
    "username": username,
    "postId": postId,
    "datePublished": datePublished,
    'postUrl': postUrl,
    'imagesList': imagesList,
    'multiImages': multiImages,
    'profImage': profImage,
    'lat': lat,
    'lng': lng,
    'videoURL': videoURL,
    'hasVideo': hasVideo
  };
}