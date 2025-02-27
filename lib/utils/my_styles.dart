import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - MyStyles - ";
abstract class MyStyles {
  //colors
  static const Color whiteColor = Color(0xffffffff);
  static const Color blackColor = Color(0xff0000000);
  static const Color orangeColor = Colors.orange;
  static const Color redColor = Colors.red;
  static const Color darkRedColor = Color(0xFFB71C1C);

  static const Color purpleColor = Color(0xff5E498A);

  static const Color darkThemeColor = Color(0xff33333E);

  static const Color grayColor = Color(0xff797979);

  static const Color greyColorLight = Color(0xffd7d7d7);

  static const Color settingsBackground = Color(0xffefeff4);

  static const Color settingsGroupSubtitle = Color(0xff777777);

  static const Color iconBlue = Color(0xff0000ff);
  static const Color transparent = Colors.transparent;
  static const Color iconGold = Color(0xffdba800);
  static const Color bottomBarSelectedColor = Color(0xff5e4989);

  //Strings
  static const TextStyle defaultTextStyle = TextStyle(
    color: purpleColor,
    fontSize: 20.0,
  );
  static const TextStyle defaultTextStyleBlack = TextStyle(
    color: blackColor,
    fontSize: 20.0,
  );
  static const TextStyle defaultTextStyleGRey = TextStyle(
    color: grayColor,
    fontSize: 20.0,
  );
  static const TextStyle smallTextStyleGRey = TextStyle(
    color: grayColor,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyle = TextStyle(
    color: purpleColor,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyleWhite = TextStyle(
    color: whiteColor,
    fontSize: 16.0,
  );
  static const TextStyle smallTextStyleBlack = TextStyle(
    color: blackColor,
    fontSize: 16.0,
  );
  static const TextStyle defaultButtonTextStyle =
  TextStyle(color: whiteColor, fontSize: 20);

  static const TextStyle profileTextStyleBlack = TextStyle(
    color: blackColor,
    fontSize: 20.0,
  );

  static const TextStyle defaultTextStyleWhite = TextStyle(
    color: whiteColor,
    fontSize: 20.0,
  );
  static const TextStyle messageRecipientTextStyle = TextStyle(
      color: blackColor, fontSize: 16.0, fontWeight: FontWeight.bold);

  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    log("$TAG themeData(): isDarkTheme = $isDarkTheme");
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(

        primary: appBlueColor,
        secondary: appBlueColor,
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
        background: isDarkTheme ? Colors.black : Color(0xffF1F5FB),
        // secondary: const Colors.yellow.shade700,

        // or from RGB
        //
        // primary: const Color(0xFF343A40),
        // secondary: const Color(0xFFFFC107),

      ),

    //* Custom Google Font
      //  fontFamily: Devfest.google_sans_family,
      // primarySwatch: Color.fromRGBO(32, 60, 255, 1),
      primaryColor: isDarkTheme ? Colors.black : Colors.white,

      backgroundColor: isDarkTheme ? Colors.black : Color(0xffF1F5FB),

      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),

      // hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xffEECED3),

      // highlightColor: isDarkTheme ? Color(0xff372901) : Color(0xff372901),
      // hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xffee183e),

      focusColor: isDarkTheme ? Color(0xff0B2512) : Colors.blue[100],
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      // appBarTheme: AppBarTheme(
      //   elevation: 0.0,
      //   systemOverlayStyle: isDarkTheme ?
      //   (SystemUiOverlayStyle.light.copyWith(
      // systemNavigationBarIconBrightness: Brightness.light,
      //     systemNavigationBarColor:
      //     Colors.blue))
      //       :
      //     (SystemUiOverlayStyle.dark.copyWith(
      //     systemNavigationBarIconBrightness: Brightness.dark,
      //     systemNavigationBarColor: Colors.blue)),
      // ), textSelectionTheme: TextSelectionThemeData(selectionColor: isDarkTheme ? Colors.white : Colors.black),
    );
  }
}
