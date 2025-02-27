import 'package:social_app/utils/utils.dart';

import 'likes.dart';

class Feed {
  int? id;
  int? userId;
  int? categoryId;
  String? title;
  String? description;
  String? location;
  String? latitude;
  String? longitude;
  String? createdAt;
  int? likesCount;
  int? commentsCount;
  User? user;
  Category? category;
  FeedImage? image;
  Video? video;
  List<Likes>? likes;
  List<Comments>? comments;

  Feed(
      {this.id,
        this.userId,
        this.categoryId,
        this.title,
        this.description,
        this.location,
        this.latitude,
        this.longitude,
        this.createdAt,
        this.likesCount,
        this.commentsCount,
        this.user,
        this.category,
        this.image,
        this.video});

  Feed.fromJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      userId = json['user_id'];
      categoryId = json['category_id'];
      title = json['title'];
      description = json['description'];
      location = json['location'];
      latitude = json['latitude'];
      longitude = json['longitude'];
      createdAt = json['created_at'];
      likesCount = json['likes_count'];
      commentsCount = json['comments_count'];
      user = json['user'] != null ? new User.fromJson(json['user']) : null;
      category = json['category'] != null
              ? new Category.fromJson(json['category'])
              : null;
      image = json['image'] != null ? new FeedImage.fromJson(json['image']) : null;
      // video = json['video'];
      video = json['video'] != null ? new Video.fromJson(json['video']) : null;
      if (json['likes'] != null) {
        likes = <Likes>[];
        json['likes'].forEach((v) {
          likes!.add(new Likes.fromJson(v));
        });
      }
      if (json['comments'] != null) {
        comments = <Comments>[];
        json['comments'].forEach((v) {
          comments!.add(new Comments.fromJson(v));
        });
      }
    } catch (e) {
      log("Feed.fromJson:  Error == "+e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['location'] = this.location;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['created_at'] = this.createdAt;
    data['likes_count'] = this.likesCount;
    data['comments_count'] = this.commentsCount;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.image != null) {
      data['image'] = this.image!.toJson();
    }
    // data['video'] = this.video;
    if (this.video != null) {
      data['video'] = this.video!.toJson();
    }
    if (this.likes != null) {
      data['likes'] = this.likes!.map((v) => v.toJson()).toList();
    }
    if (this.comments != null) {
      data['comments'] = this.comments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? username;
  String? password;
  String? apiToken;
  String? usertype;
  String? profileType;
  Profile? profile;

  User(
      {this.id,
        this.name,
        this.email,
        this.username,
        this.password,
        this.apiToken,
        this.usertype,
        this.profileType,
        this.profile});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    username = json['username'];
    password = json['password'];
    apiToken = json['api_token'];
    usertype = json['usertype'];
    profileType = json['profile_type'];
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['username'] = this.username;
    data['password'] = this.password;
    data['api_token'] = this.apiToken;
    data['usertype'] = this.usertype;
    data['profile_type'] = this.profileType;
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    return data;
  }
}

class Profile {
  int? id;
  int? userId;
  String? profile;
  Null? cover;

  Profile({this.id, this.userId, this.profile, this.cover});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    profile = json['profile'];
    cover = json['cover'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['profile'] = this.profile;
    data['cover'] = this.cover;
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? status;

  Category({this.id, this.name, this.status});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }
}

class Video {
  int? id;
  int? newsFeedId;
  String? video;

  Video({this.id, this.newsFeedId, this.video});

  Video.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    newsFeedId = json['news_feed_id'];
    video = json['video'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['news_feed_id'] = this.newsFeedId;
    data['video'] = this.video;
    return data;
  }
}

class FeedImage {
  int? id;
  int? newsFeedId;
  String? image;

  FeedImage({this.id, this.newsFeedId, this.image});

  FeedImage.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    newsFeedId = json['news_feed_id'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['news_feed_id'] = this.newsFeedId;
    data['image'] = this.image;
    return data;
  }
}

// class Likes {
//   int? id;
//   int? newsFeedId;
//   int? userId;
//   String? status;
//   User? user;
//
//   Likes({this.id, this.newsFeedId, this.userId, this.status, this.user});
//
//   Likes.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     newsFeedId = json['news_feed_id'];
//     userId = json['user_id'];
//     status = json['status'];
//     user = json['user'] != null ? new User.fromJson(json['user']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['news_feed_id'] = this.newsFeedId;
//     data['user_id'] = this.userId;
//     data['status'] = this.status;
//     if (this.user != null) {
//       data['user'] = this.user!.toJson();
//     }
//     return data;
//   }
// }

class Comments {
  int? id;
  int? newsFeedId;
  int? userId;
  String? comment;
  User? user;

  Comments({this.id, this.newsFeedId, this.userId, this.comment, this.user});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    newsFeedId = json['news_feed_id'];
    userId = json['user_id'];
    comment = json['comment'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['news_feed_id'] = this.newsFeedId;
    data['user_id'] = this.userId;
    data['comment'] = this.comment;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}
