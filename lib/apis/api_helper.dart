import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - APIHelper - ";

class APIHelper {
  // static Future<Map> getPostsFeed({String param1 = ""}) async {
  static Future<HTTPResponse<List<Feed>>> getPostsFeed({String param1 = ""}) async {
    String responseCodeStr = "400";
    log("$TAG -- getPostsFeed()");
    // String url = dataURL +
    //     "/v2/ticker/" +
    //     "?isin=" + isin;
    String url = "https://ybcorporation.com/projects/socialapp/public/api/all-feeds";
    log("$TAG -- getPostsFeed() url == $url");
    try {
      var response = await get(Uri.parse(url), headers: {"Accept": "application/json"});
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- getPostsFeed() response.body = ${response.body}");
        List dataList = jsonDecode(response.body)["data"];
        List<Feed> feedList = [];
        dataList.forEach((element) {
          Feed feed = Feed.fromJson(element);
          feedList.add(feed);
        });

        return HTTPResponse<List<Feed>>(
          true,
          feedList,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- getPostsFeed() response.statusCode = ${response.statusCode}");
        log("$TAG -- getPostsFeed() Invalid response from the server, please try again");

        return HTTPResponse<List<Feed>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- getPostsFeed() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<List<Feed>>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<List<Feed>>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- getPostsFeed() Error: ${e.toString()}");
      log("$TAG -- getPostsFeed() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<List<Feed>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
}
