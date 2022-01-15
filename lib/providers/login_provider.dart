import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  bool _isVisible = false;
  get isVisible => _isVisible;
  set isVisible(value){
    _isVisible = value;
    notifyListeners();
  }
}