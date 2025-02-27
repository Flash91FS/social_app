import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/models/feed.dart' as model;
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/providers/comments_provider.dart';
import 'package:social_app/providers/home_page_provider.dart';

const String TAG = "FS - Utils - ";

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    log("$TAG file.mimeType == ${_file.mimeType}");
    log("$TAG file.path == ${_file.path}");
    return await _file.readAsBytes();
  }
  log("$TAG No image selected");
}

// pickMultiImages(ImageSource source) async {
//   final ImagePicker _imagePicker = ImagePicker();
//   XFile? _file = await _imagePicker.pickImage(source: source);
//   if (_file != null) {
//     log("$TAG file.mimeType == ${_file.mimeType}");
//     log("$TAG file.path == ${_file.path}");
//     return await _file.readAsBytes();
//   }
//   log("$TAG No image selected");
// }

pickImage2(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    log("$TAG file.mimeType == ${_file.mimeType}");
    log("$TAG file.path == ${_file.path}");
    return _file;
  }
  log("$TAG No image selected");
}

pickVideo2(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickVideo(source: source);
  if (_file != null) {
    log("$TAG file.mimeType == ${_file.mimeType}");
    log("$TAG file.path == ${_file.path}");
    return _file;
  }
  log("$TAG No image selected");
}

Future<String> loadMapStyles() async {
  String darkMapStyle = await rootBundle.loadString('assets/nightmode.json');
  return darkMapStyle;
}

Widget myAppIcon(String src) {
  return Image.asset(src, width: 50, height: 50,);
}

void showSnackBar({
  required BuildContext context,
  required String msg,
  double? duration
}) {
  int dd = 500;
  if (duration != null) {
    dd = duration.toInt();
  }
  Duration _snackBarDisplayDuration = Duration(milliseconds: dd);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.blue[50],
      content: Text(msg,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      duration: _snackBarDisplayDuration,
    ),
  );
}

void log(String s) {
  print(s);
}

bool updateThemeWithSystem() {
  var brightness = SchedulerBinding.instance!.window.platformBrightness;
  bool isDarkMode = brightness == Brightness.dark;
  log("$TAG updateThemeWithSystem(): isDarkMode == ${isDarkMode}");
  return isDarkMode;
}

void getFeedPosts(BuildContext context) async {
  log("$TAG getFeedPosts() called ");
  final HomePageProvider homeProvider = Provider.of<HomePageProvider>(context, listen: false);
  homeProvider.setIsHomePageProcessing(true, notify: false);
  HTTPResponse<List<model.Feed>> response = await APIHelper.getPostsFeed();
  if (response.isSuccessful) {
    homeProvider.setFeedsList(response.data!);
  } else {
    log("$TAG SHOW ERROR ");
  }
  homeProvider.setIsHomePageProcessing(false, notify: false);
  // String respCodeStr = await APIHelper.getPostsFeed();
  // log("getFeedPosts(): respCodeStr = $respCodeStr");
}

fetchCommentLen({required bool showLoader, required String id, required BuildContext context}) async {
  log("$TAG fetchCommentLen()");
  final CommentsProvider commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
  if (showLoader) {
    commentsProvider.setIsProcessing(true, notify: false);
  }
  HTTPResponse<model.Feed> response = await APIHelper.getPostDetails(postID:id);
  if (response.isSuccessful) {
    // commentsProvider.setFeedsList(response.data!);
    commentsProvider.setFeed(response.data!);
  } else {
    log("SHOW ERROR ");
  }
  commentsProvider.setIsProcessing(false, notify: false);
}
