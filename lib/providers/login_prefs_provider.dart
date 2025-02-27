import 'package:flutter/widgets.dart';
import 'package:social_app/utils/login_prefs.dart';
// import 'package:social_app/models/user.dart';
// import 'package:social_app/resources/auth_methods.dart';

class LoginPrefsProvider with ChangeNotifier {
  // User? _user;
  Map<String, dynamic> userDetailsMap = {
    "isLoggedIn": false,
    "id": "",
    "name": "",
    "email": "",
    "username": "",
  };
  // final AuthMethods _authMethods = AuthMethods();

  Map<String, dynamic> get getUserDetailsMap => userDetailsMap;
  // String get getProfilePicURL => _profilePicURL;

  // Future<void> refreshUser() async {
  //   User user = await _authMethods.getUserDetails();
  //   _user = user;
  //   _profilePicURL = user.photoUrl;
  //   notifyListeners();
  // }

  setUserDetails(Map<String, dynamic> userDetails, bool saveToPrefs){
    userDetailsMap = userDetails;
    if(saveToPrefs){
      LoginPrefs loginPrefs = LoginPrefs();
      loginPrefs.setUserLoginDetails(userDetails["isLoggedIn"], "${userDetails['id']}", userDetails["name"], userDetails["email"], userDetails["username"]);
    }
  }

  clearUserDetails(){
    userDetailsMap = {
      "isLoggedIn": false,
      "id": "",
      "name": "",
      "email": "",
      "username": "",
    };
    LoginPrefs loginPrefs = LoginPrefs();
    loginPrefs.removeUserLoginDetails();
  }
}