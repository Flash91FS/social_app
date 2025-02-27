import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/home_page_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/firebase_side/add_post_screen_2.dart';
import 'package:social_app/screens/login_screen_new1.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/feed_card.dart';
import 'package:social_app/widgets/post_card.dart';
import 'package:social_app/widgets/post_card_2.dart';
import 'package:social_app/widgets/post_card_light.dart';
import 'package:social_app/widgets/post_card_rect.dart';
import 'package:social_app/widgets/post_card_rect_new1.dart';
import 'package:social_app/widgets/post_card_rect_new2.dart';
import 'package:social_app/widgets/video_post_card.dart';
// import 'package:social_app/widgets/video_post_card_2.dart';
import 'package:social_app/widgets/video_post_card_3.dart';
import 'package:social_app/widgets/video_post_card_4.dart';

import '../../widgets/post_card_rect_new3.dart';
import '../all_chats_screen.dart';
import 'add_post_screen.dart';
import '../login_screen.dart';

const String TAG = "FS - AllPostsScreen - ";

class AllPostsScreen extends StatefulWidget {
  final bool darkMode;
  const AllPostsScreen({Key? key,
  required this.darkMode,}) : super(key: key);

  @override
  State<AllPostsScreen> createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  ScrollController _scrollController = ScrollController();

  void openAddSpotScreen() {
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    // if (locProvider.getLoc != null) {
      //open add spot screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddPostScreen2(loc: null),
        ),
      );
    // } else {
    //   String error = "Please wait while your location is being fetched";
    //   log("openAddSpotScreen(): locProvider.isLocServiceEnabled = ${locProvider.isLocServiceEnabled}");
    //   log("openAddSpotScreen(): locProvider.isLocPermissionGranted = ${locProvider.isLocPermissionGranted}");
    //   if (!locProvider.isLocServiceEnabled) {
    //     error = "Could not get user Location, Please make sure that your location service is enabled";
    //   } else if (!locProvider.isLocPermissionGranted) {
    //     error = "Could not get user Location, Please make sure that you have granted permission to get your location";
    //   }
    //   showSnackBar(context: context, msg: error, duration: 3000);
    // }
  }

  void openAllChatsScreen() {
    log("openAllChatsScreen");

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AllChatsScreen(),
    ));
  }

  void getLocData() async {
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    LocationData? loc = locProvider.getLoc;
    log("getLocData(): loc = $loc");
    // _locationData ??= loc;
    bool canGetLoc = await locProvider.enableLocService();
    if (canGetLoc) {
      loc ??= await locProvider.refreshLoc();
      // _locationData = loc;
      // _locationData = await location.getLocation();
      // log("getLocData(): _locationData = $_locationData");
      // if (mounted) {
      //   log("getLocData(): mounted = $mounted");
      //   if (isMapCreated) {
      //     log("getLocData(): isMapCreated = $isMapCreated");
      //     animateToCurrentLoc();
      //   }
      //   setState(() {});
      // }
    }
  }

  void getFeedPosts() async {
    log("getFeedPosts() called ");
    //todo uncomment to connect to server
    // final HomePageProvider homeProvider = Provider.of<HomePageProvider>(context, listen: false);
    // homeProvider.setIsHomePageProcessing(true, notify: false);
    // HTTPResponse<List<Feed>> response =  await APIHelper.getPostsFeed();
    // if(response.isSuccessful){
    //   homeProvider.setFeedsList(response.data!);
    // }else{
    //   log("SHOW ERROR ");
    // }
    // homeProvider.setIsHomePageProcessing(false, notify: false);
    // // String respCodeStr = await APIHelper.getPostsFeed();
    // // log("getFeedPosts(): respCodeStr = $respCodeStr");
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
  void initState() {
    // TODO: implement initState
    super.initState();
    // _enableLocService();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
          // _getPosts();
          log("initState(): maxScrollExtent == _getPosts(); with Refresh = TRUE");
        }
      }
    });
    try {
      // getLocData();
      getFeedPosts();
      log("initState(): getFeedPosts() called ---");
    } catch (e) {
      log("initState(): Error == ${e.toString()}");
    }
    // _checkPermissions();
  }

  // Widget returnLightDarkThemeOption() {
  //   return Consumer<DarkThemeProvider>(
  //     builder: (_, provider, __) => provider.darkTheme
  //         ? ListTile(
  //             onTap: () {
  //               provider.darkTheme = false;
  //             }, // widget.toggleTheme,
  //             leading: const Icon(Icons.brightness_3,),// color: Theme.of(context).buttonColor),
  //             title: const Text("Toggle Theme"),//.apply(color: Theme.of(context).buttonColor)),
  //           )
  //         : ListTile(
  //             onTap: () {
  //               provider.darkTheme = true;
  //               }, // widget.toggleTheme,
  //             leading: const Icon(Icons.brightness_7,),// color: Theme.of(context).buttonColor),
  //             title: const Text("Toggle Theme"),//.apply(color: Theme.of(context).buttonColor)),
  //           ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    log("$TAG build(): called ---");
    // final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.darkMode ? mobileBackgroundColor : mobileBackgroundColorLight2,
      drawer: Drawer(
        child: Scaffold(
          backgroundColor: widget.darkMode ? mobileBackgroundColor : mobileBackgroundColorLight,
          // bottomNavigationBar: Container(
          //   decoration: BoxDecoration(
          //       border: Border(
          //     top: BorderSide(color: Theme.of(context).bottomAppBarColor),
          //   )),
          //   child: returnLightDarkThemeOption(),
          //
          //   // themeChange.darkTheme ? ListTile(
          //   //   onTap: () {
          //   //     themeChange.darkTheme = false;
          //   //   }, // widget.toggleTheme,
          //   //   leading: const Icon(Icons.brightness_3,),// color: Theme.of(context).buttonColor),
          //   //   title: const Text("Toggle Theme"),//.apply(color: Theme.of(context).buttonColor)),
          //   // )
          //   //     : ListTile(
          //   //   onTap: () {}, // widget.toggleTheme,
          //   //   leading: const Icon(Icons.brightness_7,),// color: Theme.of(context).buttonColor),
          //   //   title: const Text("Toggle Theme"),//.apply(color: Theme.of(context).buttonColor)),
          //   // ),
          // ),
          body: Container(
            // color: Colors.white,
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                Container(
                  // decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
                    child: ListTile(leading:
                    Icon(CupertinoIcons.home,
                      color: widget.darkMode ? Colors.white : iconColorLight2,
                    ), title: const Text("Home",
                      style: TextStyle(
                          color: appBlueColor
                      ),
                    ),
                      //do nothing on tap
//                    onTap: () => Navigator.pushNamed(context, "/settings"),
                    ),
                ),

                // ListTile(
                //   leading: Icon(CupertinoIcons.bell,
                //     color: widget.darkMode ? Colors.white : iconColorLight2,
                //   ),
                //   title: Text("Notifications",
                //     style: TextStyle(
                //       color: widget.darkMode ? Colors.white : textColorLight,
                //     ),
                //   ),
                //   onTap: () {},
                // ),

                ListTile(
                  leading: Icon(CupertinoIcons.chat_bubble,
                    color: widget.darkMode ? Colors.white : iconColorLight2,
                  ),
                  title: Text("Chat",
                    style: TextStyle(
                      color: widget.darkMode ? Colors.white : textColorLight,
                    ),
                  ),
                  onTap: () {
                    openAllChatsScreen();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.live_help_outlined,
                    color: widget.darkMode ? Colors.white : iconColorLight2,
                  ),
                  title: Text("Help & Feedback",
                    style: TextStyle(
                      color: widget.darkMode ? Colors.white : textColorLight,
                    ),
                  ),
                  onTap: () {
                    testAppAllowed();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.work,
                    color: widget.darkMode ? Colors.white : iconColorLight2,
                  ),
                  title: Text("Terms & Conditions",
                    style: TextStyle(
                      color: widget.darkMode ? Colors.white : textColorLight,
                    ),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(CupertinoIcons.smiley,
                    color: widget.darkMode ? Colors.white : iconColorLight2,
                  ),
                  title: Text("About Us",
                    style: TextStyle(
                      color: widget.darkMode ? Colors.white : textColorLight,
                    ),
                  ),
                  onTap: () {
                    // showAboutDialog(context: context, applicationVersion: "1.0.0", applicationIcon: myAppIcon("assets/images/round_map_icon.png"));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings,
                    color: widget.darkMode ? Colors.white : iconColorLight2,
                  ),
                  title: Text("Settings",
                    style: TextStyle(
                      color: widget.darkMode ? Colors.white : textColorLight,
                    ),
                  ),
                  onTap: () {},//=> Navigator.pushNamed(context, "/settings"),
                ),
                ListTile(
                    leading: Icon(Icons.logout,
                      color: widget.darkMode ? Colors.white : iconColorLight2,
                    ),
                    title: Text("Logout",
                      style: TextStyle(
                        color: widget.darkMode ? Colors.white : textColorLight,
                      ),
                    ),
                    onTap: () {
                      signOutUser();
                      // user = "";
                      // token = "";
                      // Navigator.of(context).pushNamedAndRemoveUntil(
                      //     "/loginPage", (Route<dynamic> route) => false);
                    }),
                const SizedBox(height: 10,),
                ListTile(
                  leading: Icon(CupertinoIcons.burn,
                    color: widget.darkMode ? Colors.white : iconColorLight2,
                  ),
                  title: Text("Test App Crash",
                    style: TextStyle(
                      color: widget.darkMode ? Colors.red : Colors.red,
                    ),
                  ),
                  subtitle: Text("Just a button added to test app crash and get crash info on Firebase for debugging purpose, it will be removed later...",
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.darkMode ? Colors.red : Colors.red,
                    ),
                  ),
                  onTap: () {
                    FirebaseCrashlytics.instance.crash();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: widget.darkMode ? Colors.white : Colors.black),
        backgroundColor: widget.darkMode ? mobileBackgroundColor : mobileBackgroundColorLight, //
        centerTitle: true,
        title: Text(
          "Feed",
          style: TextStyle(
            color: widget.darkMode ? Colors.white : Colors.black,
          ),
        ),
        // title: SvgPicture.asset(
        //   'assets/ic_instagram.svg',
        //   color: primaryColor,
        //   height: 32,
        // ),
        actions: [
          // ImageIcon(
          //   const AssetImage('assets/images/add_post_icon.png'),
          //   size: 32,
          //   // color: (_page == 0)
          //   //     ? appBlueColorLight
          //   //     : (darkMode ? iconColorLight : iconColorDark), //Colors.white,
          // ),
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: widget.darkMode ? iconColorLight : iconColorDark,
            ),
            onPressed: () {
              openAddSpotScreen();
            },
          ),
        ],
      ),
      // body: PostCard(),
      // Center(
      //   child: CircularProgressIndicator(),
      // ),
      //--------------------------------------------------------------
      body: StreamBuilder(
        key: PageStorageKey<String>('AllPostsScreen-StreamBuilder'),
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if(inViewList){
            return InViewNotifierList(
              scrollDirection: Axis.vertical,
              initialInViewIds: ['0'],
              isInViewPortCondition:
                  (double deltaTop, double deltaBottom, double viewPortDimension) {
                return (deltaTop < (0.5 * viewPortDimension) + 10 &&
                    deltaBottom > (0.5 * viewPortDimension) - 10);
              },
              itemCount: snapshot.data!.docs.length, // 10,
              builder: (BuildContext context, int index) {
                return Container(
                  // width: double.infinity,
                  // height: 300.0,
                  // alignment: Alignment.center,
                  margin: index == 0 ? EdgeInsets.symmetric(vertical: 2.5) : EdgeInsets.symmetric(vertical: 12.0),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      Map mMap = snapshot.data!.docs[index].data();

                      return InViewNotifierWidget(
                        id: '$index',
                        builder:
                            (BuildContext context, bool isInView, Widget? child) {
                          // return VideoWidget(
                          //     play: isInView,
                          //     url:
                          //     'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4');

                          // if(widget.darkMode) {
                          //   return PostCardRect(
                          //   snap: snapshot.data!.docs[index].data(),
                          // );
                          // //     return VideoPostCard4(
                          // //       key: PageStorageKey<String>('AllPostsScreen-StreamBuilder'),
                          // //       snap: snapshot.data!.docs[index].data(), play: isInView,
                          // //     );
                          // }else{
                          //   return PostCardLight(
                          //     snap: snapshot.data!.docs[index].data(),
                          //   );
                          // }

                              log("$TAG build(): index == ${index}");
                              // log("$TAG build(): index == ${index} -- snapData == ${snapshot.data!.docs[index].data()}");
                              String multiImages = "0";
                              try {
                                multiImages = snapshot.data!.docs[index].data().containsKey("multiImages") ?
                                snapshot.data!.docs[index].data()["multiImages"] : "0";
                                Post post = Post.fromMap(snapshot.data!.docs[index].data());
                                // log("$TAG build(): post == ${post.toJson()}");
                              } catch (e, s) {
                                log("$TAG build(): index == $index -- ERROR == $e");
                              }
                              // log("$TAG build(): index == ${index} -- multiImages == ${multiImages}");
                              if (showVideoFeature && mMap["hasVideo"] == "1") { //(index == 3 || index == 4) && //todo put condition here for video  (mMap["hasVideo"] == "1")

                                log("$TAG build(): index == $index -- isInView == $isInView");
                                return VideoPostCard4(
                                  key: const PageStorageKey<String>('AllPostsScreen-StreamBuilder'),
                                  snap: snapshot.data!.docs[index].data(),
                                  darkMode: widget.darkMode,
                                  play: isInView,
                                );
                              }
                              if (multiImages == "1"){
                              // if (index == 0 || multiImages == "1"){
                                return PostCardRectNew3(
                                  darkMode: widget.darkMode,
                                  snap: snapshot.data!.docs[index].data(),
                                );
                              }
                              return PostCardRectNew2(
                                darkMode: widget.darkMode,
                                snap: snapshot.data!.docs[index].data(),
                              );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }

          return ListView.separated(
            key: PageStorageKey<String>('AllPostsScreen-StreamBuilder'),
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              child: widget.darkMode
              //     ? PostCard(
              //   snap: snapshot.data!.docs[index].data(),
              // )
                  ? VideoPostCard3(
                key: PageStorageKey<String>('AllPostsScreen-StreamBuilder'),
                snap: snapshot.data!.docs[index].data(),
              )
                  : PostCardLight(
                      snap: snapshot.data!.docs[index].data(),
                    ),
            ),
            separatorBuilder: (context, index) {
              return Divider();
            },
          );
        },
      ),
      //--------------------------------------------------------------
      // body: Consumer<HomePageProvider>(
      //   builder: (_, provider, __) => provider.isHomePageProcessing
      //       ? const Center(
      //           child: CircularProgressIndicator(),
      //         )
      //       : provider.feedsListLength > 0
      //           ? ListView.builder(
      //               physics: const BouncingScrollPhysics(),
      //               controller: _scrollController,
      //               itemBuilder: (_, index) {
      //                 Feed feed = provider.getFeedByIndex(index);
      //
      //                 return FeedCard(
      //                   feed: feed,
      //                 );
      //                 // return ListTile(
      //                 //   title: Text(post.title!),
      //                 //   subtitle: Text(
      //                 //     post.description!,
      //                 //     maxLines: 2,
      //                 //     overflow: TextOverflow.ellipsis,
      //                 //   ),
      //                 // );
      //               },
      //               itemCount: provider.feedsListLength,
      //             )
      //           : const Center(
      //               child: Text('Nothing to show here!'),
      //             ),
      // ),
      //--------------------------------------------------------------
    );
  }
  bool inViewList = true;

  Future<void> testAppAllowed() async {
    String res = await FireStoreMethods().postAppAllowed("1");
    log("$TAG testAppAllowed(): res = $res");
  }
}
