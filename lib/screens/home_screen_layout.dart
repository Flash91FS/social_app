import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/login_screen_new1.dart';
import 'package:social_app/screens/profile_screen_new1.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/widgets/loading_dialog.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/widgets/text_field_widget.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

import 'default_not_allowed_screen.dart';
import 'firebase_side/add_post_screen_2.dart';
import 'mobile_screen_layout.dart';

const String TAG = "FS - HomeScreenLayout - ";

class HomeScreenLayout extends StatefulWidget {
  const HomeScreenLayout({Key? key, required this.title, required this.allowed, required this.userDetails}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String allowed;
  final Map<String, dynamic> userDetails;

  @override
  State<HomeScreenLayout> createState() => _HomeScreenLayoutState();
}

class _HomeScreenLayoutState extends State<HomeScreenLayout> with SingleTickerProviderStateMixin {


  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  late BuildContext dialogContext;


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // _emailController.dispose();
    // _passwordController.dispose();
  }


  void signOutUser() async {
    await AuthMethods().signOut();
    showSnackBar(msg: "Sign Out Success!", context: context, duration: 500);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreenNew1(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LoginProvider>(context);
    return widget.allowed != "5" ? getAllowedScreens() : getNotAllowedDefaultScreen();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Home Screen"),
      // ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          // color: Colors.grey,
          width: double.infinity,
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Column(
              // key: _widgetKey,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: Container(),
                  flex: 1,
                ),
                // SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 64,),
                const Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'Roboto-Regular',
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Test screen to implement n test UI ... and test Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Roboto-Regular',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Ink(
                  // color: Colors.red,
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.circular(25),
                    // borderRadius: BorderRadius.only(
                    //   topLeft: Radius.circular(25),
                    //   topRight: Radius.circular(25),
                    // ),
                    color: Colors.white,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        // padding: const EdgeInsets.symmetric(vertical: 50),
                        child: Container(
                          // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          width: double.infinity,
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(25),
                          //   color: Color(0xFFFFFFFF),
                          //
                          // ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            const SizedBox(
                              height: 24,
                            ),
                            Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                                ),
                                Text(
                                  'Hello',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    // fontFamily: 'Roboto-Regular',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            // TextFieldWidget(
                            //   hintText: 'Email',
                            //   textInputType: TextInputType.emailAddress,
                            //   textEditingController: _emailController,
                            //   prefixIconData: Icons.mail_outlined,
                            //   darkBackground: false,
                            // ),
                            // const SizedBox(
                            //   height: 24,
                            // ),
                            // TextFieldWidget(
                            //   hintText: 'Password',
                            //   textInputType: TextInputType.text,
                            //   textEditingController: _passwordController,
                            //   isPass: model.isVisible ? false : true,
                            //   prefixIconData: Icons.lock_outlined,
                            //   suffixIconData: model.isVisible ? Icons.visibility : Icons.visibility_off,
                            //   darkBackground: false,
                            // ),
                            const SizedBox(
                              height: 24,
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                            const SizedBox(
                              height: 27,
                            ),
                          ]),
                        ),
                      ),

                      // ----------- Login Button -----------
                      Positioned(
                        // bottom: -27,
                        bottom: 0,
                        right: 1,
                        left: 1,

                        child: Center(
                          child:
                          Container(
                            width: 200,
                            height: 54,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () {
                                // showSnackBar(
                                // msg: "Login... Will be implemented soon!", context: context, duration: 2000);
                                signOutUser();
                              },
                              child: Ink(
                                height: 45,
                                // color: Colors.blue,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.blue,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Logout",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      // fontFamily: 'Roboto-Regular',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Flexible(
                  child: Container(),
                  flex: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getAllowedScreens() {
    log("$TAG getAllowedScreens():");
    if (attachedToFirebase) {
      return
        StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              log("$TAG snapshot.connectionState == ConnectionState.active");
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                log("$TAG snapshot.hasData");
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                // return AllPostsScreen(key: const PageStorageKey<String>('AllPostsScreen'), darkMode: false);

                return const MobileScreenLayout(
                  title: 'Home Page',
                );
                //todo testing screens below
                // return ProfileScreenNew1(
                //   key: const PageStorageKey<String>('ProfileScreen'),
                //   darkMode: true,
                //   uid: FirebaseAuth.instance.currentUser!.uid,
                // );
                // return TestHomePage();
                // return const ChewieDemo();
                // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
                // return const AddPostScreen2(loc: null);

                // bool darkMode = updateThemeWithSystem();
                // return FeedScreen(darkMode: darkMode);
              } else if (snapshot.hasError) {
                log("$TAG snapshot.hasError");
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              log("$TAG snapshot.connectionState == ConnectionState.waiting");
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            log("$TAG snapshot.connectionState == ${snapshot.connectionState}");
            // return const TestScreen(title: "Test");
            // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
            return const LoginScreenNew1();
          },
        );
    } else {
      return getLoginOrHomeScreenForUser();
    }
  }

  getLoginOrHomeScreenForUser() {
    log("$TAG getLoginOrHomeScreenForUser(): userDetails = ${widget.userDetails}");
    log("$TAG getLoginOrHomeScreenForUser(): userDetails.isEmpty = ${widget.userDetails.isEmpty}");
    if(widget.userDetails.isEmpty){
      log("$TAG getLoginOrHomeScreenForUser(): show CircularProgressIndicator");
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if(widget.userDetails.isNotEmpty && widget.userDetails.containsKey("isLoggedIn") && widget.userDetails["isLoggedIn"] == true){
      log("$TAG getLoginOrHomeScreenForUser(): show MobileScreenLayout");
      // return AllPostsScreen(key: const PageStorageKey<String>('AllPostsScreen'), darkMode: false);
      return const MobileScreenLayout(
        title: 'Home Page',
      );
    } else {
      log("$TAG getLoginOrHomeScreenForUser(): show LoginScreen");
      return const LoginScreenNew1();
    }
  }

  getNotAllowedDefaultScreen() {
    log("$TAG getNotAllowedDefaultScreen == DefaultNotAllowedScreen");
    return DefaultNotAllowedScreen();
  }
}
