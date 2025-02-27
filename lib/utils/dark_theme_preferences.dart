import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - DarkThemePreference - ";
class DarkThemePreference {
  static const THEME_STATUS = "THEMESTATUS";

  // setDarkTheme(bool value) async {
  //   log("$TAG setDarkTheme(): $value");
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool(THEME_STATUS, value);
  // }
  //
  // Future<bool> getTheme() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   log("$TAG getTheme(): isDarkTheme = ${prefs.getBool(THEME_STATUS)}");
  //   return prefs.getBool(THEME_STATUS) ?? false;
  // }
}