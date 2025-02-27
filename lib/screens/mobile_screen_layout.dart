import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/login_screen_new1.dart';
import 'package:social_app/screens/profile_screen_new1.dart';
import 'package:social_app/screens/server_side/all_feed_screen.dart';
import 'package:social_app/screens/firebase_side/all_posts_screen.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/firebase_side/map_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/screens/server_side/feed_map_screen.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/widgets/keep_alive_page.dart';
import 'package:social_app/widgets/loading_dialog.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/widgets/text_field_widget.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

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
    // var brightness = SchedulerBinding.instance!.window.platformBrightness;
    // bool isDarkMode = brightness == Brightness.dark;
    bool isDarkMode = updateThemeWithSystem();
    log("$TAG initState(): darkMode == ${isDarkMode}");
    getData();
    pageController = PageController();
  }

  @override
  bool get wantKeepAlive {
    return true;
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
          builder: (context) => const LoginScreenNew1(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build(): called ---");

    final model = Provider.of<LoginProvider>(context);
    // final themeChange = Provider.of<DarkThemeProvider>(context);
    // bool darkMode = themeChange.darkTheme;
    bool darkMode = updateThemeWithSystem();
    DarkThemeProvider _darkThemeProvider = Provider.of(context, listen: false);
    _darkThemeProvider.setSysDarkTheme(darkMode);
    log("$TAG build(): darkMode == ${darkMode}");

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
      backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight3, //
      bottomNavigationBar: SafeArea(
        child: Wrap(
          children: [
            Container(
              // color: Colors.blue,
              height: 2,

              decoration: BoxDecoration(
                // color: Colors.blue,
                gradient: LinearGradient(colors: [
                  darkMode ? bottomBarShadowDark1 : bottomBarShadowLight1, //Color(0x44606060),
                  darkMode ? bottomBarShadowDark2 : bottomBarShadowLight2, //Color(0x44606060),
                  // Color(0x00FFFFFF),
                ], stops: [
                  0.0,
                  100.0
                ], begin: FractionalOffset.bottomCenter, end: FractionalOffset.topCenter, tileMode: TileMode.repeated),
              ),
            ),
            Container(
              // color: Colors.black,
              color: darkMode ? bottomNavBarColor : bottomNavBarColorLight, //
              // margin: const EdgeInsets.only(top: 4.5), //Same as `blurRadius` i guess
              // decoration: BoxDecoration(
              //   // borderRadius: BorderRadius.circular(3.0),
              //   // color: Colors.blue[100],
              //   color: darkMode ? bottomNavBarColor : bottomNavBarColorLight,//
              //   boxShadow: [
              //     BoxShadow(
              //       color: darkMode ? Color(0x889E9E9E):Color(0x889E9E9E),
              //       offset: Offset(0.0, 1.0), //(x,y)
              //       blurRadius: 5.0,
              //     ),
              //   ],
              // ),
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
                              // SizedBox(
                              //   width: 38,
                              //   height: 38,
                              //   // color: Colors.deepPurple,
                              //   child: Center(
                              //     child: ImageIcon(
                              //       const AssetImage('assets/images/feed_icon.png'),
                              //       size: 32,
                              //       color: (_page == 0)
                              //           ? appBlueColorLight
                              //           : (darkMode ? iconColorLight : iconColorDark), //Colors.white,
                              //     ),
                              //   ),
                              // ),
                              Container(
                                width: 38,
                                height: 38,
                                padding: const EdgeInsets.all(6),
                                // color: Colors.deepPurple,
                                // child: Image.asset(
                                //   (_page == 0)
                                //       ? "assets/images/ic_1_selected.png"
                                //       : "assets/images/ic_1_unselected.png",
                                //   color: (_page != 0 && !darkMode) ? Colors.grey[600] : null,
                                //   width: 32,
                                //   height: 32,
                                //   fit: BoxFit.cover,
                                // ),
                                child: FaIcon(FontAwesomeIcons.solidNewspaper, color: (_page == 0)
                                    ? appBlueColorOld
                                    : (darkMode ? iconColorLight : iconColorDark),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  'Feed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (_page == 0)
                                        ? appBlueColorOld
                                        : (darkMode ? iconColorLight : iconColorDark), //Colors.white,
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
                              // SizedBox(
                              //     width: 38,
                              //     height: 38,
                              //     // color: Colors.deepPurple,
                              //   child: Image.asset(
                              //     "assets/images/round_map_icon.png",
                              //     width: 38,
                              //     height: 38,
                              //     fit: BoxFit.cover,
                              //   ),
                              //   // child: Icon(MdiIcons.fromString('image-marker-outline'),
                              //   //   color: (_page == 1)
                              //   //       ? appBlueColorOld
                              //   //       : (darkMode ? iconColorLight : iconColorDark),
                              //   // ),
                              // ),
                              Container(
                                width: 38,
                                height: 38,
                                // padding: const EdgeInsets.all(3),
                                // child: Image.asset(
                                //   (_page == 1)
                                //       ? "assets/images/ic_2_selected.png"
                                //       // : "assets/images/new_map_icon.png",
                                //       : "assets/images/ic_2_unselected.png",
                                //   color: (_page != 1 && !darkMode) ? Colors.grey[600] : null,
                                //   width: 32,
                                //   height: 32,
                                //   fit: BoxFit.cover,
                                // ),
                                padding: const EdgeInsets.all(6),
                                child: FaIcon(FontAwesomeIcons.mapLocation, color: (_page == 1)
                                    ? appBlueColorOld
                                    : (darkMode ? iconColorLight : iconColorDark),
                                ),
                              ),
                              // ImageIcon(
                              //   AssetImage('assets/images/round_map_icon.png'),
                              //   size: 28,
                              //   // color: Colors.yellow,
                              // ),
                              SizedBox(
                                // color: Colors.deepPurple,
                                // width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  'Map',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (_page == 1)
                                        ? appBlueColorOld
                                        : (darkMode ? iconColorLight : iconColorDark), //Colors.white,
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
                              // SizedBox(
                              //   width: 38,
                              //   height: 38,
                              //   // color: Colors.blue,
                              //   child: Center(
                              //     // color: Colors.deepPurple,
                              //     // width: 32,
                              //     // height: 32,
                              //     child: ImageIcon(
                              //       const AssetImage('assets/images/profile_icon.png'),
                              //       size: 32,
                              //       color: (_page == 2)
                              //           ? appBlueColorLight
                              //           : (darkMode ? iconColorLight : iconColorDark), //Colors.white,
                              //     ),
                              //   ),
                              // ),
                              Container(
                                width: 38,
                                height: 38,
                                // padding: const EdgeInsets.fromLTRB(8,4,8,4),
                                padding: const EdgeInsets.all(6),
                                // color: Colors.deepPurple,
                                // child: Image.asset(
                                //   (_page == 2)
                                //       ? "assets/images/ic_3_selected.png"
                                //       : "assets/images/ic_3_unselected.png",
                                //   color: (_page != 2 && !darkMode) ? Colors.grey[600] : null,
                                //   width: 32,
                                //   height: 32,
                                //   fit: BoxFit.cover,
                                // ),
                                child: FaIcon(FontAwesomeIcons.solidUser, color: (_page == 2)
                                    ? appBlueColorOld
                                    : (darkMode ? iconColorLight : iconColorDark),
                                ),
                              ),
                              SizedBox(
                                // color: Colors.deepPurple,
                                // width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  'Profile',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: (_page == 2)
                                        ? appBlueColorOld
                                        : (darkMode ? iconColorLight : iconColorDark), //Colors.white,
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
          ],
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
          // KeepAlivePage(child:FeedScreen(key: const PageStorageKey<String>('FeedScreen'), darkMode: darkMode),),
          // KeepAlivePage(child: MapScreen(key: const PageStorageKey<String>('MapScreen'), darkMode: darkMode),),
          // KeepAlivePage(child:ProfileScreen(key: const PageStorageKey<String>('ProfileScreen'),uid: FirebaseAuth.instance.currentUser!.uid,)),

          attachedToFirebase
              ? AllPostsScreen(key: const PageStorageKey<String>('AllPostsScreen'), darkMode: darkMode)
              : AllFeedScreen(key: const PageStorageKey<String>('AllFeedScreen'), darkMode: darkMode),
          // AddPostScreen(),
          attachedToFirebase
              ? MapScreen(key: const PageStorageKey<String>('MapScreen'), darkMode: darkMode)
              : FeedMapScreen(key: const PageStorageKey<String>('FeedMapScreen'), darkMode: darkMode),
          // const HomeScreenLayout(title: "Home screen"),
          ProfileScreenNew1(
            key: const PageStorageKey<String>('ProfileScreen'),
            darkMode: darkMode,
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
