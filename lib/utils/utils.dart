import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  log("No image selected");
}

Future<String> loadMapStyles() async {
  String darkMapStyle = await rootBundle.loadString('assets/nightmode.json');
  return darkMapStyle;
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
      content: Text(msg),
      duration: _snackBarDisplayDuration,
    ),
  );
}

void log(String s) {
  print(s);
}
