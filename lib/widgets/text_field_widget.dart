import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/login_provider.dart';

class TextFieldWidget extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final bool darkBackground;
  final String hintText;
  final TextInputType textInputType;
  final IconData? prefixIconData;
  final IconData? suffixIconData;

  const TextFieldWidget(
      {Key? key,
        required this.textEditingController,
        this.isPass = false,
        this.darkBackground = true,
        this.prefixIconData,
        this.suffixIconData,
        required this.hintText,
        required this.textInputType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    // final inputBorder = OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    final inputBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(10));
    return Theme(
      data: darkBackground ? ThemeData.dark() : ThemeData.light(),
      child: TextField(
        controller: textEditingController,
        style: TextStyle(
          color: darkBackground ? Colors.white : Colors.black,
        ),
          // hintColor: Colors.pink,
        decoration: InputDecoration(
          labelText: hintText,
          // labelStyle: TextStyle(
          //   color: Color(0xFF303030),
          // ),
          // border: inputBorder,
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: Colors.blue)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide:  BorderSide(color: Colors.grey)),
          filled: true,

          contentPadding: const EdgeInsets.all(8.0),
          prefixIcon: Icon(prefixIconData, size: 18),
          suffixIcon: GestureDetector(onTap: (){
            loginProvider.isVisible = !loginProvider.isVisible;
          },child: Icon(suffixIconData, size: 18)),
        ),
        keyboardType: textInputType,
        obscureText: isPass,
      ),
    );
  }
}
