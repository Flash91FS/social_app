import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
// import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - DioApiHelper - ";
const String BASE_URL = "https://ybcorporation.com/projects/socialapp/public/api/";

class DioApiHelper {
  static Future<HTTPResponse<Map<String, dynamic>>> addPostMultiPart({
    String user_id = "",
    String category_id = "",String title = "",
    String description = "", String location = "",
    String latitude = "", String longitude = "",
    required String path,
    required String fileName,
    required Uint8List? file,
    bool isVideo = false,
  }) async {
    String responseCodeStr = "400";
    log("$TAG -- addPostMultiPart()");
    String url = BASE_URL + "store-feed";
    // String url = "https://ybcorporation.com/projects/socialapp/public/api/store-feed";
    log("$TAG -- addPostMultiPart() url == $url");
    log("$TAG -- addPostMultiPart() isVideo == $isVideo");
    log("$TAG -- addPostMultiPart() fileName == $fileName");
    log("$TAG -- addPostMultiPart() path == $path");
    try {// string to uri
      var dio = Dio();
      var formData =
      isVideo ?
      FormData.fromMap({
        // 'name': 'wendux',
        // 'age': 25,
        "user_id":"8",
        "category_id":"1",
        "title":title,
        "description":description,
        "location":"Islamabad Pakistan",
        "latitude":"35.7383673",
        "longitude":"75.8797898",
        'video': await MultipartFile.fromFile(path, filename: fileName),
        // 'files': [
        //   await MultipartFile.fromFile('./text1.txt', filename: 'text1.txt'),
        //   await MultipartFile.fromFile('./text2.txt', filename: 'text2.txt'),
        // ]
      }) :
      FormData.fromMap({
        // 'name': 'wendux',
        // 'age': 25,
        "user_id":"8",
        "category_id":"1",
        "title":title,
        "description":description,
        "location":"Islamabad Pakistan",
        "latitude":"35.7383673",
        "longitude":"75.8797898",
        'image': await MultipartFile.fromFile(path, filename: fileName),
        // 'files': [
        //   await MultipartFile.fromFile('./text1.txt', filename: 'text1.txt'),
        //   await MultipartFile.fromFile('./text2.txt', filename: 'text2.txt'),
        // ]
      });

      var response = await dio.post(url, data: formData);
      responseCodeStr = response.statusCode.toString();
      log("$TAG -- addPostMultiPart() responseCodeStr = ${responseCodeStr}");

      log("$TAG -- addPostMultiPart() response.data.toString() = ${response.data.toString()}");
      log("$TAG -- addPostMultiPart() response.toString() = ${response.toString()}");
      log("$TAG -- addPostMultiPart() response.statusCode.toString() = ${response.statusCode.toString()}");
      log("$TAG -- addPostMultiPart() response.statusMessage.toString() = ${response.statusMessage.toString()}");
      // response.data.toString() = {status_code: 422, status_message: {image: [The image must be a file of type: jpg, JPG, JPEG, jpeg, png.]}}

      Map map1 = response.data;
      log("$TAG -- addPostMultiPart() map1['status_code'] = ${map1['status_code']}");
      log("$TAG -- addPostMultiPart() map1['status_message'] = ${map1['status_message']}");

      if (response.statusCode == 200) {
        // Map<String, dynamic> mMap = JsonDecoder().convert(response.body);
        // List dataList = jsonDecode(response.body)["data"];
        // List<Feed> feedList = [];
        // dataList.forEach((element) {
        //   Feed feed = Feed.fromJson(element);
        //   feedList.add(feed);
        // });

        return HTTPResponse<Map<String, dynamic>>(
          true,
          null,
          message: 'Request Successful',
          statusCode: response.statusCode!,
        );

      } else {
        log("$TAG -- addPostMultiPart() response.statusCode = ${response.statusCode}");
        log("$TAG -- addPostMultiPart() Invalid response from the server, please try again");

        return HTTPResponse<Map<String, dynamic>>(
          false,
          null,
          message:
          'Invalid data received from the server! Please try again in a moment.',
          statusCode: response.statusCode!,
        );
      }
    } on SocketException {
      log("$TAG -- addPostMultiPart() Unable to reach the server, please try again");
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
      log("$TAG -- addPostMultiPart() Error: ${e.toString()}");
      log("$TAG -- addPostMultiPart() Invalid response from the server, please try again");
      log('UNEXPECTED ERROR');
      log(e.toString());
      return HTTPResponse<Map<String, dynamic>>(
        false,
        null,
        message: 'Something went wrong! Please try again in a moment!',
      );
    }
  }
}
