import 'package:flutter/widgets.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  String _profilePicURL = "";
  final AuthMethods _authMethods = AuthMethods();

  User get getUser => _user!;
  String get getProfilePicURL => _profilePicURL;

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    _profilePicURL = user.photoUrl;
    notifyListeners();
  }
}