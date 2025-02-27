import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - TextFieldInput - ";
class TextFieldInput extends StatelessWidget {
  final TextEditingController? textEditingController;
  final bool isPass;
  final bool readOnly;
  final bool rounded;
  final bool darkBackground;
  final int? maxLines;
  final String hintText;
  final TextInputType textInputType;
  final IconData? suffixIconData;

  const TextFieldInput(
      {Key? key,
      required this.textEditingController,
        this.isPass = false,
        this.readOnly = false,
        this.rounded = false,
        this.darkBackground = true,
        this.suffixIconData,
        this.maxLines = 1,
      required this.hintText,
      required this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    log("$TAG build(): darkBackground == ${darkBackground}");
    final loginProvider = Provider.of<LoginProvider>(context);
    // final inputBorder = OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    final inputBorder = rounded ? OutlineInputBorder(borderSide: Divider.createBorderSide(context),borderRadius: BorderRadius.circular(20.0),)
    :OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return  Theme(
      data: darkBackground ? ThemeData.dark()
          .copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
          brightness: Brightness.dark,
          primary: appBlueColorLight,
          // secondary: Colors.red,
          // primaryVariant: Colors.red,
          // secondaryVariant: Colors.red,
          // surface: Colors.red,
          // background: Colors.red,
          // error: Colors.red,
          // onPrimary: Colors.red,
          // onSecondary: Colors.red,
          // onSurface: Colors.red,
          // onBackground: Colors.red,
          // onError: Colors.red,
        ),
      )
          : ThemeData.light()
          .copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
          brightness: Brightness.light,
          primary: appBlueColorLight,
          // secondary: appBlueColor,
        ),
      ),
      child: TextField(
        controller: textEditingController,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: darkBackground ? hintTextColorDark : hintTextColorLight,
          ),
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          filled: true,
          contentPadding: rounded ?  EdgeInsets.all(16.0) : EdgeInsets.all(8.0),
          suffixIcon: GestureDetector(onTap: (){
            loginProvider.isVisible = !loginProvider.isVisible;
          },child: Icon(suffixIconData, size: 18)),
        ),
        keyboardType: textInputType,
        obscureText: isPass,
        readOnly: readOnly,
        maxLines: maxLines,
        style: TextStyle(
          color: darkBackground ? textColorDark : textColorLight,
        ),
      ),
    );
  }
}
