class Feed {
  int? id;
  String? userId;
  String? categoryId;
  String? title;
  String? description;
  String? location;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? likesCount;
  String? commentsCount;
  User? user;
  Category? category;
  Image? image;
  Null? video;

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
    image = json['image'] != null ? new Image.fromJson(json['image']) : null;
    video = json['video'];
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
    data['video'] = this.video;
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
  String? userId;
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

class Image {
  int? id;
  String? newsFeedId;
  String? image;

  Image({this.id, this.newsFeedId, this.image});

  Image.fromJson(Map<String, dynamic> json) {
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
