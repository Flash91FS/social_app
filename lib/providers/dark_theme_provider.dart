import 'package:flutter/foundation.dart';
import 'package:social_app/utils/dark_theme_preferences.dart';

class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    // darkThemePreference.setDarkTheme(value);
    notifyListeners();
  }

  setSysDarkTheme(bool value, {bool notify = false,}) {
    _darkTheme = value;
    // darkThemePreference.setDarkTheme(value);
    if (notify) {
      notifyListeners();
    }
  }
}