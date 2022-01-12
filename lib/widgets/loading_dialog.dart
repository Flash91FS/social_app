import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Container(
            height: 70.0,
            width: 40.0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CupertinoActivityIndicator(
                  radius: 14,
                ),
                SizedBox(
                  width:15,
                ),
                Text(
                  "Please wait...",
                  style: TextStyle(color: Colors.blue, fontSize: 18),
                )
              ],
            )));

  }
}
