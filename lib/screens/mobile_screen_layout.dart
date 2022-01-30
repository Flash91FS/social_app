import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/map_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/widgets/loading_dialog.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/widgets/text_field_widget.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

import 'add_post_screen.dart';
import 'feed_screen.dart';

const String TAG = "FS - MobileScreenLayout - ";

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late BuildContext dialogContext;

  late PageController pageController; // for tabs animation
  int _page = 0;

  @override
  void initState() {
    super.initState();
    getData();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void onPageChanged(int page) {
    log("$TAG onPageChanged: $page");
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    //Animating Page
    pageController.jumpToPage(page);
  }

  void getData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  void signOutUser() async {
    await AuthMethods().signOut();
    showSnackBar(msg: "Sign Out Success!", context: context, duration: 500);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LoginProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Home Screen"),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(
      //         Icons.camera_alt_outlined,
      //         color: primaryColor,
      //       ),
      //       onPressed: () {
      //         navigationTapped(0);
      //         // openAddSpotScreen();
      //       },
      //     ),
      //     IconButton(
      //       icon: const Icon(
      //         Icons.favorite_border_outlined,
      //         color: primaryColor,
      //       ),
      //       onPressed: () {
      //         navigationTapped(1);
      //         // openAddSpotScreen();
      //       },
      //     ),
      //     IconButton(
      //       icon: const Icon(
      //         Icons.person,
      //         color: primaryColor,
      //       ),
      //       onPressed: () {
      //         navigationTapped(2);
      //         // openAddSpotScreen();
      //       },
      //     ),
      //   ],
      // ),
      bottomNavigationBar: SafeArea(
        child: Container(
          // color: Colors.black,
          color: darkMode ? bottomNavBarColor : bottomNavBarColorLight,//
          height: kToolbarHeight,
          child: Row(
            children: [
              Flexible(
                child: InkWell(
                  onTap: () {
                    navigationTapped(0);
                    },
                  child: Container(
                    child: Center(
                      child: Column(
                        // direction: Axis.vertical,
                        children: [
                          SizedBox(
                            width: 38,
                            height: 38,
                            // color: Colors.deepPurple,
                            child: Center(
                              child: ImageIcon(
                                const AssetImage('assets/images/feed_icon.png'),
                                size: 32,
                                color: (_page == 0) ? appBlueColorLight : (darkMode ? iconColorLight : iconColorDark),//Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            child: Text(
                              'Feed',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (_page == 0) ? appBlueColor : (darkMode ? iconColorLight : iconColorDark),//Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    navigationTapped(1);
                    },
                  child: Container(
                    // color: Colors.red,
                    child: Center(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // direction: Axis.vertical,//used for Wrap only, not for Column
                        children: [
                          SizedBox(
                              width: 38,
                              height: 38,
                              // color: Colors.deepPurple,
                              child: Image.asset(
                                "assets/images/round_map_icon.png",
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                              )),
                          // ImageIcon(
                          //   AssetImage('assets/images/round_map_icon.png'),
                          //   size: 28,
                          //   // color: Colors.yellow,
                          // ),
                          SizedBox(
                            // color: Colors.deepPurple,
                            width: MediaQuery.of(context).size.width / 3,
                            child: Text(
                              'Map',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (_page == 1) ? appBlueColor : (darkMode ? iconColorLight : iconColorDark),//Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
                child: InkWell(
                  onTap: () {
                    navigationTapped(2);
                    },
                  child: Container(
                    child: Center(
                      child: Column(
                        // direction: Axis.vertical,
                        children: [
                          SizedBox(
                            width: 38,
                            height: 38,
                            // color: Colors.blue,
                            child: Center(
                              // color: Colors.deepPurple,
                              // width: 32,
                              // height: 32,
                              child: ImageIcon(
                                const AssetImage('assets/images/profile_icon.png'),
                                size: 32,
                                color: (_page == 2) ? appBlueColorLight : (darkMode ? iconColorLight : iconColorDark),//Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            // color: Colors.deepPurple,
                            width: MediaQuery.of(context).size.width / 3,
                            child: Text(
                              'Profile',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (_page == 2) ? appBlueColor : (darkMode ? iconColorLight : iconColorDark),//Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Flexible(
              //   child: Container(
              //     color: Colors.green,
              //   ),
              // ),
              // Flexible(
              //   child: Container(
              //     color: Colors.red,
              //   ),
              // ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: CupertinoTabBar(
      //   onTap: navigationTapped,
      //   currentIndex: _page,
      //   items: const [
      //     BottomNavigationBarItem(
      //       // icon: Icon(
      //       //   Icons.home,
      //       //   // color: (_page == 0) ? primaryColor : secondaryColor,
      //       // ),
      //       // icon: ImageIcon(
      //       //   AssetImage("images/feed_icon.png"),
      //       //   // color: Color(0xFF3A5A98),
      //       // ),
      //       activeIcon: ImageIcon(
      //         AssetImage('assets/images/feed_icon.png'),
      //         size: 150,
      //         // color: Colors.yellow,
      //       ),
      //       icon: ImageIcon(
      //         AssetImage('assets/images/feed_icon.png'),
      //         size: 150,
      //         // color: Colors.yellow,
      //       ),
      //       label: 'Feed',
      //       // backgroundColor: primaryColor,
      //     ),
      //     BottomNavigationBarItem(
      //       // icon: Icon(
      //       //   Icons.add_circle,
      //       //   // color: (_page == 2) ? primaryColor : secondaryColor,
      //       // ),
      //       icon: ImageIcon(
      //         // AssetImage('assets/images/add_location_icon_400.png'),
      //         AssetImage('assets/images/map_icon.png'),
      //         size: 48,
      //         // color: Colors.yellow,
      //       ),
      //       label: 'Map',
      //       // backgroundColor: primaryColor,
      //     ),
      //     // BottomNavigationBarItem(
      //     //   icon: Icon(
      //     //     Icons.favorite,
      //     //     // color: (_page == 3) ? primaryColor : secondaryColor,
      //     //   ),
      //     //   label: 'home',
      //     //   // backgroundColor: primaryColor,
      //     // ),
      //     BottomNavigationBarItem(
      //       // icon: Icon(
      //       //   Icons.person,
      //       //   // color: (_page == 4) ? primaryColor : secondaryColor,
      //       // ),
      //       icon: ImageIcon(
      //         AssetImage('assets/images/profile_icon.png'),
      //         // size: 150,
      //         // color: Colors.yellow,
      //       ),
      //       label: 'Profile',
      //       // backgroundColor: primaryColor,
      //     ),
      //   ],
      // ),
      body: PageView(
        // children: homeScreenItems,
        children: [
          const FeedScreen(),
          // const AddPostScreen(),
          const MapScreen(),
          // const HomeScreenLayout(title: "Home screen"),
          ProfileScreen(
            uid: FirebaseAuth.instance.currentUser!.uid,
          ),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}
