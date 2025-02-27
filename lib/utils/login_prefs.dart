import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - LoginPrefs - ";

class LoginPrefs {
  static const USER_NAME = "USER_NAME";
  static const EMAIL = "EMAIL";
  static const FULL_NAME = "FULL_NAME";
  static const USER_ID = "USER_ID";
  static const IS_LOGGED_IN = "IS_LOGGED_IN";
  static const IS_ALLOWED = "IS_ALLOWED";

  setUserLoginDetails(
    bool isLoggedIn,
    String id,
    String name,
    String email,
    String username,
  ) async {
    log("$TAG setUserLoginDetails: $isLoggedIn");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(IS_LOGGED_IN, isLoggedIn);
    prefs.setString(USER_ID, id);
    prefs.setString(FULL_NAME, name);
    prefs.setString(EMAIL, email);
    prefs.setString(USER_NAME, username);
  }

  removeUserLoginDetails() async {
    log("$TAG removeUserLoginDetails: ");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(IS_LOGGED_IN, false);
    prefs.setString(USER_ID, "");
    prefs.setString(FULL_NAME, "");
    prefs.setString(EMAIL, "");
    prefs.setString(USER_NAME, "");
  }

  Future<Map<String, dynamic>> getUserLoginDetails() async {
    log("$TAG getUserLoginDetails(): ");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool(IS_LOGGED_IN) ?? false;
    String? id = prefs.getString(USER_ID) ?? ""; //empty string if null
    String? name = prefs.getString(FULL_NAME) ?? ""; //empty string if null
    String? email = prefs.getString(EMAIL) ?? ""; //empty string if null
    String? username = prefs.getString(USER_NAME) ?? ""; //empty string if null

    log("$TAG getUserLoginDetails(): isLoggedIn = $isLoggedIn");
    log("$TAG getUserLoginDetails(): id = $id");
    log("$TAG getUserLoginDetails(): name = $name");
    log("$TAG getUserLoginDetails(): email = $email");
    log("$TAG getUserLoginDetails(): username = $username");

    Map<String, dynamic> map = {
      "isLoggedIn": isLoggedIn,
      "id": id,
      "name": name,
      "email": email,
      "username": username,
    };
    return map;
  }

  setIsAllowed(
    String isAllowed,
  ) async {
    log("$TAG setIsAllowed: $isAllowed");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(IS_ALLOWED, isAllowed);
  }

  Future<String> getIsAllowed() async {
    log("$TAG getIsAllowed(): ");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? isAllowed = prefs.getString(IS_ALLOWED) ?? "1"; //"1" string if null

    log("$TAG getIsAllowed(): isAllowed = $isAllowed");

    return isAllowed;
  }
}
