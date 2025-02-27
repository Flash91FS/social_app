import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - APIHelper - ";
const String BASE_URL = "https://ybcorporation.com/projects/socialapp/public/api/";

class APIHelper {
  // static Future<Map> getPostsFeed({String param1 = ""}) async {
  static Future<HTTPResponse<List<Feed>>> getPostsFeed({String param1 = ""}) async {
    String responseCodeStr = "400";
    log("$TAG -- getPostsFeed()");
    String url = BASE_URL + "all-feeds";
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/all-feeds";
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
  static Future<HTTPResponse<Map<String, dynamic>>> makeLoginRequest({String email = "",String username = "",String password = ""}) async {
    String responseCodeStr = "400";
    log("$TAG -- makeLoginRequest()");
    String url = BASE_URL + "signup";
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/signup";
    log("$TAG -- makeLoginRequest() url == $url");
    try {
      var response = await post(Uri.parse(url), headers: {"Accept": "application/json"}, body: {
        // "email": email,
        // "username": username,
        // "password": password
        "email": "aazam513@gmail.com",//"ali@gmail.com",
        // "username": "aazam513",
        "password": "12345678"
      });
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- makeLoginRequest() response.body = ${response.body}");
        Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Map<String, dynamic>>(
          true,
          mMap,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- makeLoginRequest() response.statusCode = ${response.statusCode}");
        log("$TAG -- makeLoginRequest() Invalid response from the server, please try again");

        return HTTPResponse<Map<String, dynamic>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- makeLoginRequest() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- makeLoginRequest() Error: ${e.toString()}");
      log("$TAG -- makeLoginRequest() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
  static Future<HTTPResponse<Map<String, dynamic>>> makeSignUpRequest({String name = "",String email = "",String username = "",String password = ""}) async {
    String responseCodeStr = "400";
    log("$TAG -- makeSignUpRequest()");
    String url = BASE_URL + "signup";
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/signup";
    log("$TAG -- makeSignUpRequest() url == $url");
    try {
      var response = await post(Uri.parse(url), headers: {"Accept": "application/json"}, body: {
        // "name": name,
        // "email": email,
        // "username": username,
        // "password": password
        "name": "Ali Azam",
        "email": "ali@gmail.com",
        "username": "aazam513",
        "password": "12345678"
      });
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- makeSignUpRequest() response.body = ${response.body}");
        Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Map<String, dynamic>>(
          true,
          mMap,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- makeSignUpRequest() response.statusCode = ${response.statusCode}");
        log("$TAG -- makeSignUpRequest() Invalid response from the server, please try again");

        return HTTPResponse<Map<String, dynamic>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- makeSignUpRequest() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- makeSignUpRequest() Error: ${e.toString()}");
      log("$TAG -- makeSignUpRequest() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
  static Future<HTTPResponse<Map<String, dynamic>>> getUserProfileDetails({String userID = ""}) async {
    String responseCodeStr = "400";
    log("$TAG -- getUserProfileDetails()");
    // String url = BASE_URL + "user-details?user_id="+userID;
    String url = "https://ybcorporation.com/projects/socialapp/public/api/user-details?user_id=8";
    log("$TAG -- getUserProfileDetails() url == $url");
    try {
      var response = await get(Uri.parse(url), headers: {"Accept": "application/json"});
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- getUserProfileDetails() response.body = ${response.body}");
        Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Map<String, dynamic>>(
          true,
          mMap,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- getUserProfileDetails() response.statusCode = ${response.statusCode}");
        log("$TAG -- getUserProfileDetails() Invalid response from the server, please try again");

        return HTTPResponse<Map<String, dynamic>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- getUserProfileDetails() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- getUserProfileDetails() Error: ${e.toString()}");
      log("$TAG -- getUserProfileDetails() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
  static Future<HTTPResponse<Feed>> getPostDetails({required String postID}) async {
    String responseCodeStr = "400";
    log("$TAG -- getPostDetails()");
    String url = BASE_URL + "feed-details?news_feed_id="+postID;
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/feed-details?news_feed_id=1";
    log("$TAG -- getPostDetails() url == $url");
    try {
      var response = await get(Uri.parse(url), headers: {"Accept": "application/json"});
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- getPostDetails() response.body = ${response.body}");
        // Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        List dataList = jsonDecode(response.body)["data"];
        Feed feed = Feed.fromJson(dataList[0]);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Feed>(
          true,
          feed,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- getPostDetails() response.statusCode = ${response.statusCode}");
        log("$TAG -- getPostDetails() Invalid response from the server, please try again");

        return HTTPResponse<Feed>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- getPostDetails() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<Feed>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<Feed>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- getPostDetails() Error: ${e.toString()}");
      log("$TAG -- getPostDetails() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Feed>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
  static Future<HTTPResponse<Map<String, dynamic>>> postComment({required String uid, required String postID, required String comment}) async {
    String responseCodeStr = "400";
    log("$TAG -- postComment()");
    String url = BASE_URL + "comment";
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/comment";
    log("$TAG -- postComment() url == $url");
    try {
      var response = await post(Uri.parse(url), headers: {"Accept": "application/json"}, body: {
        // "name": name,
        // "email": email,
        // "username": username,
        // "password": password
        "user_id": uid,
        // "user_id": "8",
        "news_feed_id": postID,
        "comment": comment,
      });
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- postComment() response.body = ${response.body}");
        Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Map<String, dynamic>>(
          true,
          mMap,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- postComment() response.statusCode = ${response.statusCode}");
        log("$TAG -- postComment() Invalid response from the server, please try again");

        return HTTPResponse<Map<String, dynamic>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- postComment() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- postComment() Error: ${e.toString()}");
      log("$TAG -- postComment() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
  static Future<HTTPResponse<Map<String, dynamic>>> postLikeDislike({required String uid, required String postID, required String status}) async {
    String responseCodeStr = "400";
    log("$TAG -- postLike()");
    String url = BASE_URL + "like";
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/like";
    log("$TAG -- postLike() url == $url");
    try {
      var response = await post(Uri.parse(url), headers: {"Accept": "application/json"}, body: {
        // "name": name,
        // "email": email,
        // "username": username,
        // "password": password
        "user_id": uid,
        // "user_id": "8",
        "news_feed_id": postID,
        "status": status,
      });
      responseCodeStr = response.statusCode.toString();
      if (response.statusCode == 200) {
        log("$TAG -- postLike() response.body = ${response.body}");
        Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Map<String, dynamic>>(
          true,
          mMap,
          message: 'Request Successful',
          statusCode: response.statusCode,
        );

      } else {
        log("$TAG -- postLike() response.statusCode = ${response.statusCode}");
        log("$TAG -- postLike() Invalid response from the server, please try again");

        return HTTPResponse<Map<String, dynamic>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      log("$TAG -- postLike() Unable to reach the server, please try again");
      log('SOCKET EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Unable to reach the server! Please check your internet and try again in a moment.',
      );
    } on FormatException {
      print('JSON FORMAT EXCEPTION OCCURRED');
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message:
        'Invalid data received from the server! Please try again in a moment.',
      );
    } catch (e) {
      log("$TAG -- postLike() Error: ${e.toString()}");
      log("$TAG -- postLike() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }

//   static Future<HTTPResponse<Map<String, dynamic>>> addPostMultiPart({
//     String user_id = "",
//     String category_id = "",String title = "",
//     String description = "", String location = "",
//     String latitude = "", String longitude = "",
//     required String path,
//     required String fileName,
//     required Uint8List? file,
//   }) async {
//     String responseCodeStr = "400";
//     log("$TAG -- addPostMultiPart()");
//     String url = BASE_URL + "store-feed";
//     // String url = "https://ybcorporation.com/projects/socialapp/public/api/store-feed";
//     log("$TAG -- addPostMultiPart() url == $url");
//     try {// string to uri
//       Uri uri = Uri.parse(url);
// // create multipart request
//       MultipartRequest request = MultipartRequest("POST", uri);
//
//       // ByteData byteData = await asset.getByteData();
//       // List<int> imageData = byteData.buffer.asUint8List();
//       // List<int> imageData = file!.readAsBytes() as List<int>;
//       List<int> imageData = file!;
//
//       // MultipartFile multipartFile = MultipartFile.fromBytes(
//       //   'image',  //key of the api
//       //   imageData,
//       //   filename: fileName,
//       //   // filename: "test.${image.path.split(".").last}",
//       //   contentType: MediaType("image", "${fileName.split(".").last}"),
//       //   // contentType: MediaType("image", "jpg"), //this is not nessessory variable. if this getting error, erase the line.
//       // );
//       //
//       // MultipartFile multipartFile = MultipartFile.fromPath(
//       //   'image',  //key of the api
//       //   imageData,
//       //   filename: 'some-file-name.jpg',
//       //   // contentType: MediaType("image", "jpg"), //this is not nessessory variable. if this getting error, erase the line.
//       // );
//       request.files.add(await MultipartFile.fromPath(
//           'image', path,
//           contentType: MediaType('image', '${fileName.split(".").last}')));
//       request.fields["user_id"] = "8";
//       request.fields["category_id"] = "1";
//       request.fields["title"] = "Post 3";
//       request.fields["description"] = "Third test post now from phone";
//       request.fields["location"] = "Islamabad Pakistan";
//       request.fields["latitude"] = "35.7373663";
//       request.fields["longitude"] = "75.8787878";
//
// // add file to multipart
// //       request.files.add(multipartFile);
// // send
//       var responseMultiPart = await request.send();
//
//
//
//       // var response = await post(Uri.parse(url), headers: {"Accept": "application/json"}, body: {
//       //   // "name": name,
//       //   // "email": email,
//       //   // "username": username,
//       //   // "password": password
//       //   "user_id": "8",
//       //   "category_id": "1",
//       //   "title": "New Test 2",
//       //   "description": "Some more Testing Description 8234 sdf hello test",
//       //   "location": "Islamabad Pakistan",
//       //   "latitude": "35.7373663",
//       //   "longitude": "75.8787878",
//       // });
//       responseCodeStr = responseMultiPart.statusCode.toString();
//       log("$TAG -- addPostMultiPart() responseCodeStr = ${responseCodeStr}");
//       if (responseMultiPart.statusCode == 200) {
//         // Map<String, dynamic> mMap = JsonDecoder().convert(responseMultiPart.body);
//         // List dataList = jsonDecode(response.body)["data"];
//         // List<Feed> feedList = [];
//         // dataList.forEach((element) {
//         //   Feed feed = Feed.fromJson(element);
//         //   feedList.add(feed);
//         // });
//
//         return HTTPResponse<Map<String, dynamic>>(
//           true,
//           null,
//           message: 'Request Successful',
//           statusCode: responseMultiPart.statusCode,
//         );
//
//       } else {
//         log("$TAG -- addPostMultiPart() responseMultiPart.statusCode = ${responseMultiPart.statusCode}");
//         log("$TAG -- addPostMultiPart() Invalid responseMultiPart from the server, please try again");
//
//         return HTTPResponse<Map<String, dynamic>>(
//           false,
//           null,
//           message:
//           'Invalid data received from the server! Please try again in a moment.',
//           statusCode: responseMultiPart.statusCode,
//         );
//       }
//     } on SocketException {
//       log("$TAG -- addPostMultiPart() Unable to reach the server, please try again");
//       log('SOCKET EXCEPTION OCCURRED');
//       return HTTPResponse<Map<String, dynamic>>(
//         false,
//         null,
//         message: 'Unable to reach the server! Please check your internet and try again in a moment.',
//       );
//     } on FormatException {
//       print('JSON FORMAT EXCEPTION OCCURRED');
//       return HTTPResponse<Map<String, dynamic>>(
//         false,
//         null,
//         message:
//         'Invalid data received from the server! Please try again in a moment.',
//       );
//     } catch (e) {
//       log("$TAG -- addPostMultiPart() Error: ${e.toString()}");
//       log("$TAG -- addPostMultiPart() Invalid responseMultiPart from the server, please try again");
//       log('UNEXPECTED ERROR');
//       log(e.toString());
//       return HTTPResponse<Map<String, dynamic>>(
//         false,
//         null,
//         message: 'Something went wrong! Please try again in a moment!',
//       );
//     }
//   }
}
