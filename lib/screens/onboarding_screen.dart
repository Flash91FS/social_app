import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:social_app/models/onboarding_content.dart';
import 'package:social_app/screens/mobile_screen_layout.dart';
import 'package:social_app/screens/profile_pic_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  double bottomPadding = 20;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToProfileEditScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          // builder: (context) => const MobileScreenLayout(title: "Home screen"),
          builder: (context) => const ProfilePicScreen(
            showBackButton: false,
            showSkipButton: true,
          ),
        ),
        (route) => false);
  }

  void skip() {
    log("skip() called");
    navigateToProfileEditScreen();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    bottomPadding = deviceHeight > 750 ? 35 : 20;

    // if (deviceHeight > 750) {
    //   bottomPadding = 30;
    // } else {
    //   bottomPadding = 20;
    // }
    log("build(): deviceHeight = $deviceHeight");
    log("build(): bottomPadding = $bottomPadding");
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          // title: Text(""),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton(
                onPressed: skip,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
            ),
          ],
        ),
        body: Container(
          // color: Colors.red,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return Container(
                      // padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          // --- Top Image with circular background ------------------
                          Container(
                            height: deviceHeight > 750
                                ? MediaQuery.of(context).size.height / 1.8
                                : MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width,
                            // color: Colors.blue[800],
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.elliptical(MediaQuery.of(context).size.width / 2, 50),
                                bottomRight: Radius.elliptical(MediaQuery.of(context).size.width / 2, 50),
                              ),
                              // color: Theme.of(context).primaryColor,
                              // color: Colors.blue[800],
                              color: Colors.grey[900],
                            ),
                            child: Container(
                              // height: 50,
                              // width: 50,
                              padding: const EdgeInsets.all(30.0), //increase padding to reduce SVG size
                              // child: SvgPicture.asset(
                              //   contents[i].image,
                              //   // height: 50,
                              //   // width: 50,
                              //   color: Colors.white,
                              // ),
                              child: Image.asset(
                                contents[i].image,
                                // height: 50,
                                // width: 50,
                                // color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            contents[i].title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              contents[i].discription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              // --- PAGE Indicator DOTS -----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  contents.length,
                  (index) => buildDot(index, context),
                ),
              ),
              // --- NEXT PAGE BUTTON -----
              Container(
                height: 50,
                margin: EdgeInsets.fromLTRB(50, bottomPadding, 50, bottomPadding),
                width: double.infinity,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    if (currentIndex == contents.length - 1) {
                      navigateToProfileEditScreen();
                    }
                    _controller.nextPage(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.bounceIn,
                    );
                  },
                  child: Ink(
                    child: Center(
                      child: Text(
                        currentIndex == contents.length - 1 ? "Continue" : "Next",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // textColor: Colors.white,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      // color: Theme.of(context).primaryColor,
                      color: appBlueColor,
                      // color: Colors.blue[800],
                    ),
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 20,
              // )
            ],
          ),
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // color: Theme.of(context).primaryColor,
        color: appBlueColor,
        // color: Colors.blue[800],
      ),
    );
  }
}
