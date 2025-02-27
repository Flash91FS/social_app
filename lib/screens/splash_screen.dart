import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:social_app/main.dart';
import 'package:social_app/utils/colors.dart';

import '../utils/utils.dart';
import 'home_screen_layout.dart';

const String TAG = "FS - SplashScreen - ";

class SplashScreen extends StatefulWidget {
  // const SplashScreen({Key? key}) : super(key: key);
  const SplashScreen({Key? key, required this.title, required this.allowed, required this.userDetails}) : super(key: key);

  final String title;
  final String allowed;
  final Map<String, dynamic> userDetails;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // TODO: set time to load new page
    Future.delayed(const Duration(milliseconds: 8500), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreenLayout(title: "Home", allowed: widget.allowed, userDetails: widget.userDetails)));
    });
  }
  @override
  Widget build(BuildContext context) {
    fullScreenWidth = MediaQuery.of(context).size.width;
    postHeight = fullScreenWidth*0.766;
    videoHeight = fullScreenWidth*0.935;
    log("$TAG build(): fullScreenWidth = $fullScreenWidth");
    log("$TAG build(): postHeight = $postHeight");
    log("$TAG build(): videoHeight = $videoHeight");

    return Scaffold(
      body: Container(
        color: splashBackground,
        alignment: Alignment.center,
        child: SizedBox(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, child: Lottie.asset("assets/lottie/splash_2_lottie.json")),
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     // Lottie.asset("assets/lottie/splash_2_lottie.json"),
        //     SizedBox(height: 300, width: 300, child: Lottie.asset("assets/lottie/splash_2_lottie.json")),
        //     // Text("Dodo"),
        //   ],
        // ),
      ),
    );
  }
}
