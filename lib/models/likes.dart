

import 'feed.dart';

class Likes {
  int? id;
  int? newsFeedId;
  int? userId;
  String? status;
  User? user;

  Likes({this.id, this.newsFeedId, this.userId, this.status, this.user});

  Likes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    newsFeedId = json['news_feed_id'];
    userId = json['user_id'];
    status = json['status'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['news_feed_id'] = this.newsFeedId;
    data['user_id'] = this.userId;
    data['status'] = this.status;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}