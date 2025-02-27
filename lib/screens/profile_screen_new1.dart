import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/onboarding_content.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/all_chats_screen.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/login_screen_new1.dart';
import 'package:social_app/screens/message_screen.dart';
import 'package:social_app/screens/profile_pic_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

// import 'package:social_app/resources/firestore_methods.dart';
// import 'package:social_app/widgets/follow_button.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/text_field_input.dart';

const String TAG = "FS - ProfileScreenNew1 - ";

class ProfileScreenNew1 extends StatefulWidget {
  final String uid;
  final bool showBackButton;
  final bool darkMode;

  const ProfileScreenNew1({
    Key? key,
    required this.uid,
    this.darkMode = false,
    this.showBackButton = false,
  }) : super(key: key);

  // const TestProfileScreen({
  //   Key? key,
  // }) : super(key: key);

  @override
  _ProfileScreenNew1State createState() => _ProfileScreenNew1State();
}

class _ProfileScreenNew1State extends State<ProfileScreenNew1> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  int likesCount = 0;
  int commentsCount = 0;
  bool isFollowing = false;
  bool isLoading = false;
  Uint8List? _image;
  late PageController _controller;
  int currentIndex = 0;
  double bottomPadding = 20;
  GlobalKey _widgetKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // color: Theme.of(context).primaryColor,
        color: appBlueColor,
        // color: Colors.blue[800],
      ),
    );
  }

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
    log("$TAG initState called");
    getData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    log("$TAG dispose called");
  }

  void signOutUser() async {
    // openAllChatsScreen();
    await AuthMethods().signOut();
    showSnackBar(msg: "Sign Out Success!", context: context, duration: 500);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreenNew1(),
        ),
        (route) => false);
  }

  Future<void> selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void openMessageScreen() {
    log("openMessageScreen");
    if (showMessagingScreen) {
      String photoUrl = userData['photoUrl'] ?? "";
      String name = "";

      if (userData['fullName'] != null && userData['fullName'].toString().isNotEmpty) {
        name = userData['fullName'];
      } else {
        name = userData['username'];
      }

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MessageScreen(
          uid: widget.uid,
          name: name,
          photoUrl: photoUrl,
        ),
      ));
    }
  }

  String getUserNameFromUserData() {
    log("getUserNameFromUserData");

    String name = "";
    if (userData['fullName'] != null && userData['fullName'].toString().isNotEmpty) {
      name = userData['fullName'];
    } else {
      name = userData['username'];
    }
    return name;
  }

  void openAllChatsScreen() {
    log("openAllChatsScreen");

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AllChatsScreen(),
    ));
  }

  getData() async {
    log("$TAG getData(): called : UID =  ${widget.uid}");
    dynamic postSnap = null;
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      log("$TAG getData(): got userSnap");

      // get post lENGTH
      postSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get();
      log("$TAG getData(): got postSnap");

      postLen = postSnap.docs.length;
      log("$TAG getData(): postLen = $postLen");
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      likesCount = 0;
      for (var doc in postSnap.docs) {
        log("$TAG getData(): post = ${doc.data()}");
        try {
          List likes = doc.data()["likes"];
          if (likes != null && likes.isNotEmpty) {
            likesCount = likesCount + likes.length;
          }
        } catch (e) {
          log("$TAG getData(): Error == ${e.toString()}");
        }
      }

      if (!mounted) {
        log("$TAG getData(): Already unmounted i.e. Dispose called");
        return;
      }
      setState(() {});
    } catch (e) {
      log("$TAG getData(): Error: ${e.toString()}");
      if (!mounted) {
        log("$TAG getData(): Already unmounted i.e. Dispose called");
        return;
      }
      showSnackBar(msg: e.toString(), context: context, duration: 1500);
      // showSnackBar(
      //   context,
      //   e.toString(),
      // );
    }
    if (!mounted) {
      log("$TAG getData(): Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = false;
    });
    getAllComments(postSnap);
  }

  void getAllComments(postSnap) async {
    for (var doc in postSnap.docs) {
      String postId = doc.data()["postId"];
      log("$TAG post ID = $postId");
      int comLen = await fetchCommentLen(postId);
      log("$TAG getAllComments(): comLen == $comLen");
      commentsCount += comLen;
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<int> fetchCommentLen(String postId) async {
    try {
      // QuerySnapshot snap =
      QuerySnapshot? commentsSnap =
          await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').get();
      int commentLen = commentsSnap.docs.length;
      log("$TAG fetchCommentLen(): comLen == $commentLen");
      return commentLen;
      // return "$commentLen";
    } catch (err) {
      log("$TAG fetchCommentLen(): Error == ${err.toString()}");
    }
    return 0;
    // return "0";
  }

  navigateToProfileEditScreen() async {
    final result = await Navigator.of(context).push(
        MaterialPageRoute(
          // builder: (context) => const MobileScreenLayout(title: "Home screen"),
          builder: (context) => const ProfilePicScreen(
            showBackButton: true,
            showSkipButton: false,
            fromSignUp: false,
          ),
        ));
    log("$TAG navigateToProfileEditScreen() result == $result");
    if(result){
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      log("$TAG navigateToProfileEditScreen(): got userSnap");
      userData = userSnap.data()!;

      // dynamic postSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get();
      // for (var doc in postSnap.docs) {
      //   // log("$TAG navigateToProfileEditScreen(): post = ${doc.data()}");
      //   final postId = doc.data()['postId'];
      //   log("$TAG navigateToProfileEditScreen(): postId: = $postId");
      //   try {
      //     await FirebaseFirestore.instance.collection("posts").doc(postId).update({
      //       "profImage": profImage,
      //     });
      //   } catch (e) {
      //     log("$TAG navigateToProfileEditScreen(): Error == ${e.toString()}");
      //   }
      // }
      if(mounted){
        setState(() {});
      }
    }
  }

  Widget getAllUserPosts() {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          itemCount: (snapshot.data! as dynamic).docs.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 1.5,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

            return Container(
              child: Image(
                image: NetworkImage(snap['postUrl']),
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }

  Widget returnProfilePicWidgetIfAvailable() {
    if (userData['photoUrl'] != null && userData['photoUrl'].toString().isNotEmpty) {
      return CircleAvatar(
        radius: 42,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 40,
          // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
          backgroundImage: NetworkImage("${userData['photoUrl']}"),
          // backgroundColor: Colors.white,
        ),
      );
    } else {
      return CircleAvatar(
        radius: 42,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 40,
          // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
          backgroundImage: NetworkImage(unsplashImageURL),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = false;
    try {
      // final themeChange = Provider.of<DarkThemeProvider>(context);
      // darkMode = themeChange.darkTheme;

      darkMode = updateThemeWithSystem();
      DarkThemeProvider _darkThemeProvider = Provider.of(context);
      _darkThemeProvider.setSysDarkTheme(darkMode);
      log("$TAG build(): darkMode == ${darkMode}");
    } catch (err) {
      log("$TAG Error == ${err.toString()}");
    }
    final deviceHeight = MediaQuery.of(context).size.height;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        // : SafeArea(
        // top: true,
        // bottom: true,
        : SafeArea(
            child: Scaffold(
              backgroundColor: widget.darkMode ? Colors.black : profileBackgroundLight,
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                child: Stack(
                  children: [
                    // ----- BACKGROUND COLOR -------
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 300,
                      child: Ink(
                        // color: Colors.blue[800],
                        // color: appBlueColor,
                        decoration: const BoxDecoration(
                          // borderRadius: BorderRadius.circular(25),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                          color: appBlueColor, //Colors.pink,
                        ),
                      ),
                    ),

                    // ----- APP BAR - title and options -------
                    // Positioned(
                    //   top: 10,
                    //   left: 0,
                    //   right: 0,
                    //   height: 52,
                    //   child: Row(
                    //     children: [
                    //       IconButton(
                    //         onPressed: () {
                    //           log("$TAG overflow icon clicked ----");
                    //           //todo add functionality
                    //         },
                    //         // splashColor: appBlueColor,
                    //         // highlightColor: appBlueColor,
                    //         icon: const Icon(
                    //           Icons.more_vert,
                    //           color: Colors.pink,
                    //           // color: widget.darkMode ? textColorDark : textColorLight,
                    //         ),
                    //       ),
                    //       Expanded(
                    //         child: Text(
                    //           'Profile',
                    //           textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6,
                    //           // style: TextStyle(fontSize: 20.0,
                    //           //     fontWeight: FontWeight.bold, color: widget.darkMode ? textColorDark : textColorLight),
                    //         ),
                    //       ),
                    //       IconButton(
                    //         onPressed: () {
                    //           log("$TAG overflow icon clicked");
                    //           //todo add functionality
                    //         },
                    //         icon: Icon(
                    //           Icons.add_photo_alternate_outlined,
                    //           color: widget.darkMode ? textColorDark : textColorLight,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(
                      // padding: const EdgeInsets.symmetric(horizontal: 22),
                      // color: Colors.grey,
                      width: double.infinity,
                      child: Column(
                        key: _widgetKey,
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Flexible(
                          //   child: Container(),
                          //   flex: 1,
                          // ),

                          const SizedBox(
                            height: 20,
                          ),
                          // ----- APP BAR - title and options -------
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  log("$TAG Back icon clicked ----");
                                  //Back functionality
                                  if (widget.showBackButton) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                splashColor: widget.showBackButton ? null : appBlueColor,
                                highlightColor: widget.showBackButton ? null : appBlueColor,
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: widget.showBackButton ? Colors.white : appBlueColor,
                                  // color: widget.darkMode ? textColorDark : textColorLight,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Profile',
                                  // "@${userData['username']}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.white),
                                  // style: TextStyle(fontSize: 20.0,
                                  //     fontWeight: FontWeight.bold, color: widget.darkMode ? textColorDark : textColorLight),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  log("$TAG EDIT icon clicked");
                                  if (!widget.showBackButton) {
                                    //todo add EDIT functionality only for current user
                                    navigateToProfileEditScreen();
                                  }
                                },
                                splashColor: widget.showBackButton ? appBlueColor : null,
                                highlightColor: widget.showBackButton ? appBlueColor : null,
                                icon: Icon(
                                  FontAwesomeIcons.penToSquare,
                                  color: widget.showBackButton ? appBlueColor : Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                            // height: 80,
                          ),

                          // ----- INNER ROUNDED BOX DECORATION WITH WHITE COLOR - and inner elements -------
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Ink(
                              // color: Colors.red,
                              // ----- WHITE BOX DECORATION -------
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
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
                                    // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    width: double.infinity,
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(25),
                                    //   color: Color(0xFFFFFFFF),
                                    //
                                    // ),
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          const SizedBox(
                                            height: 24,
                                          ),
                                          _image != null
                                              ? CircleAvatar(
                                                  radius: 40,
                                                  backgroundImage: MemoryImage(_image!),
                                                  backgroundColor: Colors.white,
                                                )
                                              : returnProfilePicWidgetIfAvailable(),
                                          // Positioned(
                                          //   bottom: 1,
                                          //   right: 1,
                                          //   left: 1,
                                          //   child: Center(
                                          //     child: Stack(
                                          //       children: [
                                          //         _image != null
                                          //             ? CircleAvatar(
                                          //           radius: 40,
                                          //           backgroundImage: MemoryImage(_image!),
                                          //           backgroundColor: Colors.white,
                                          //         )
                                          //             : returnProfilePicWidgetIfAvailable()
                                          //         // CircleAvatar(
                                          //         //   radius: 40,
                                          //         //   // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
                                          //         //   backgroundImage: returnProfilePicWidgetIfAvailable(),
                                          //         //   // backgroundImage: (userData['photoUrl']!=null && userData['photoUrl'].toString().isNotEmpty) ? NetworkImage("${userData['photoUrl']}"):AssetImage('assets/images/default_profile_pic.png'),
                                          //         //   backgroundColor: Colors.white,
                                          //         // ),
                                          //         //todo uncomment to add change profile pic feature
                                          //         // Positioned(
                                          //         //   bottom: -12,
                                          //         //   left: 44,
                                          //         //   child: IconButton(
                                          //         //     iconSize: 20,
                                          //         //     onPressed: selectImage,
                                          //         //     icon: Icon(Icons.add_a_photo, color: Colors.blue[800],),
                                          //         //   ),
                                          //         // ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            // 'Full Name',
                                            getUserNameFromUserData(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              // fontFamily: 'Roboto-Regular',
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            // "@username",
                                            "@${userData['username']}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Text(
                                            // "Some long bio description telling about the user like in intagram",
                                            userData['bio'],
                                            // "@${userData['username']}",
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          // const SizedBox(
                                          //   height: 24,
                                          // ),
                                          // TextFieldInput(
                                          //   hintText: 'Email',
                                          //   textInputType: TextInputType.emailAddress,
                                          //   textEditingController: _emailController,
                                          //   // prefixIconData: Icons.mail_outlined,
                                          //   darkBackground: false,
                                          //   rounded: true,
                                          // ),
                                          // const SizedBox(
                                          //   height: 24,
                                          // ),
                                          // TextFieldInput(
                                          //   hintText: 'Password',
                                          //   textInputType: TextInputType.text,
                                          //   textEditingController: _passwordController,
                                          //   isPass: true,
                                          //   // prefixIconData: Icons.lock_outlined,
                                          //   suffixIconData: Icons.visibility_off,
                                          //   darkBackground: false,
                                          //   rounded: true,
                                          // ),
                                          // const SizedBox(
                                          //   height: 24,
                                          // ),
                                          const SizedBox(
                                            height: 90,
                                          ),
                                          // const SizedBox(
                                          //   height: 27,
                                          // ),
                                        ]),
                                  ),

                                  // ----------- Login Button -----------
                                  Positioned(
                                    // bottom: -27,
                                    bottom: 20,
                                    right: 1,
                                    left: 1,
                                    child: (widget.uid == FirebaseAuth.instance.currentUser!.uid)
                                        ? logoutButtonRow()
                                        : followMessageButtonRow(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // ----- Second ROUNDED BOX DECORATION WITH WHITE COLOR - and inner OVERVIEW elements -------
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Ink(
                              // color: Colors.red,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
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
                                    // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    width: double.infinity,
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(25),
                                    //   color: Color(0xFFFFFFFF),
                                    //
                                    // ),
                                    child: Column(
                                      // mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const SizedBox(
                                          height: 24,
                                        ),
                                        const Text(
                                          'Overview',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            // fontFamily: 'Roboto-Regular',
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 24,
                                        ),
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceAround,// set your alignment
                                          children: <Widget>[
                                            // Expanded(
                                            //   child: getOverviewWidget(
                                            //     assetName: "assets/map_icons/ic_general_96.png",
                                            //     name: "Posts",
                                            //     amount: "15",
                                            //   ),
                                            // ),
                                            // Expanded(
                                            //   child: getOverviewWidget(
                                            //     assetName: "assets/map_icons/ic_general_96.png",
                                            //     name: "Posts",
                                            //     amount: "15",
                                            //   ),
                                            // ),
                                            getOverviewWidget(
                                              assetName: "assets/map_icons/ic_general_96.png",
                                              name: "Posts",
                                              amount: postLen.toString(), //"15",
                                            ),
                                            getOverviewWidget(
                                              assetName: "assets/map_icons/ic_general_96.png",
                                              name: "Likes",
                                              amount: likesCount.toString(), //"15",
                                            ),
                                            getOverviewWidget(
                                              assetName: "assets/map_icons/ic_general_96.png",
                                              name: "Comments",
                                              amount: commentsCount.toString(), //"15",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 24,
                                        ),
                                        Row(
                                          // mainAxisAlignment: MainAxisAlignment.spaceAround,// set your alignment
                                          children: <Widget>[
                                            getOverviewWidget(
                                              assetName: "assets/map_icons/ic_general_96.png",
                                              name: "Messages",
                                              amount: "15",
                                            ),
                                            getOverviewWidget(
                                              assetName: "assets/map_icons/ic_general_96.png",
                                              name: "Followers",
                                              amount: followers.toString(), //"15",
                                            ),
                                            getOverviewWidget(
                                              assetName: "assets/map_icons/ic_general_96.png",
                                              name: "Following",
                                              amount: following.toString(), //"15",
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 34,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          // ----- TODO show user posts -------
                          // Container(
                          //   color: Colors.purple,
                          //   height:300,
                          //   child:getAllUserPosts(),
                          // ),
                          // const SizedBox(
                          //   height: 124,
                          // ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Container(
                          //       child: const Text(
                          //         "Don't have an account? ",
                          //         style: TextStyle(
                          //           color: Colors.white70,
                          //         ),
                          //       ),
                          //       padding: const EdgeInsets.symmetric(vertical: 18),
                          //     ),
                          //     GestureDetector(
                          //         onTap: () {
                          //           log('Sign up clicked');
                          //         },
                          //         child: Container(
                          //           child: const Text(
                          //             "Sign up.",
                          //             style: TextStyle(color: appBlueColor, fontWeight: FontWeight.bold),
                          //             // style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                          //           ),
                          //           padding: EdgeInsets.symmetric(vertical: 18),
                          //         )),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget getOverviewWidget({required String assetName, required String name, required String amount}) {
    return Expanded(
      child: Row(
        children: [
          Image.asset(
            "assets/map_icons/ic_general_96.png",
            // "https://i.ytimg.com/vi/LPe56fezmoo/maxresdefault.jpg",
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
          const Padding(
            padding: EdgeInsets.all(1.6),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                amount,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  // fontFamily: 'Roboto-Regular',
                ),
              ),
              Text(
                name,
                // textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  // fontFamily: 'Roboto-Regular',
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getLogoutOrMessageButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(25),
      onTap: () {
        // showSnackBar(
        // msg: "Logout... Will be implemented soon!", context: context, duration: 2000);
        if (widget.uid == FirebaseAuth.instance.currentUser!.uid) {
          signOutUser();
        } else {
          openMessageScreen();
        }
      },
      child: Ink(
        height: 45,
        // color: Colors.blue,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: appBlueColor,
          // color: Colors.blue[800],
        ),
        child: Center(
          child: Text(
            (widget.uid == FirebaseAuth.instance.currentUser!.uid) ? "Logout" : "Message",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              // fontFamily: 'Roboto-Regular',
            ),
          ),
        ),
      ),
    );
  }

  // old profile screen body... not used anymore
  Widget getProfileScreenBody(bool darkMode) {
    return ListView(
      children: [
        Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 260,
              // color: Colors.grey,
              child: Stack(
                children: [
                  // Image.network(
                  //   "https://firebasestorage.googleapis.com/v0/b/social-app-2b7dd.appspot.com/o/posts%2FEgDtot0E3ZQ56qa8U0dMcNDwfg03%2F9ad533f0-779c-11ec-a8a8-3f9f6134b863?alt=media&token=c469a927-e12a-4bd4-8d2e-ca83207c3c03",
                  //   // "https://i.ytimg.com/vi/LPe56fezmoo/maxresdefault.jpg",
                  //   width: MediaQuery.of(context).size.width,
                  //   height: 220,
                  //   fit: BoxFit.cover,
                  // ),
                  Image.asset(
                    "assets/images/placeholder_img.png",
                    // "https://i.ytimg.com/vi/LPe56fezmoo/maxresdefault.jpg",
                    width: MediaQuery.of(context).size.width,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 1,
                    left: 1,
                    child: Center(
                      child: Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 40,
                                  backgroundImage: MemoryImage(_image!),
                                  backgroundColor: Colors.white,
                                )
                              : returnProfilePicWidgetIfAvailable()
                          // CircleAvatar(
                          //   radius: 40,
                          //   // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
                          //   backgroundImage: returnProfilePicWidgetIfAvailable(),
                          //   // backgroundImage: (userData['photoUrl']!=null && userData['photoUrl'].toString().isNotEmpty) ? NetworkImage("${userData['photoUrl']}"):AssetImage('assets/images/default_profile_pic.png'),
                          //   backgroundColor: Colors.white,
                          // ),
                          //todo uncomment to add change profile pic feature
                          // Positioned(
                          //   bottom: -12,
                          //   left: 44,
                          //   child: IconButton(
                          //     iconSize: 20,
                          //     onPressed: selectImage,
                          //     icon: Icon(Icons.add_a_photo, color: Colors.blue[800],),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Positioned(
                  //   bottom: 0,
                  //   right: 1,
                  //   left: 1,
                  //   child: CircleAvatar(
                  //     backgroundColor: Colors.grey,
                  //     backgroundImage: NetworkImage(
                  //       "https://i.ytimg.com/vi/LPe56fezmoo/maxresdefault.jpg",
                  //       // userData['photoUrl'],
                  //     ),
                  //     radius: 40,
                  //   ),
                  // ),

                  // Positioned(
                  //   child: Container(
                  //     width: double.infinity,
                  //     height: 50,
                  //     color: Colors.blue,
                  //     child: Center(
                  //       child: Text(
                  //         "Profile",
                  //         // userData['username'],
                  //         style: TextStyle(
                  //           fontSize: 21,
                  //           // fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 15, bottom: 5),
              width: double.infinity,
              // height: 40,
              // color: Colors.blue,
              child: Center(
                child: Text(
                  // "@username",
                  "@${userData['username']}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkMode ? textColorDark : textColorLight,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              // color: Colors.blue,
              child: Center(
                child: Text(
                  // "Full Name",
                  userData['fullName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkMode ? textColorDark : textColorLight,
                  ),
                ),
              ),
            ),
            // const SizedBox(
            //   height: 8,
            // ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
              width: double.infinity,
              // color: Colors.blue,
              child: Center(
                child: Text(
                  // "Full Name",
                  userData['bio'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkMode ? textColorDark : textColorLight,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(width: 200, height: 45, child: getLogoutOrMessageButton()),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
          ],
        ),
        getAllUserPosts(),
      ],
    );
  }

  //old code to test onboarding screen designs
  Widget getTestOnboardingBody(double deviceHeight) {
    return Container(
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
                            ? MediaQuery.of(context).size.height / 2.1
                            : MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        // color: Colors.blue[800],
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.elliptical(MediaQuery.of(context).size.width / 2, 50),
                            bottomRight: Radius.elliptical(MediaQuery.of(context).size.width / 2, 50),
                          ),
                          // color: Theme.of(context).primaryColor,
                          color: Colors.blue[800],
                          // color: Colors.grey[900],
                        ),
                        child: Container(
                          // height: 50,
                          // width: 50,
                          padding: const EdgeInsets.all(1.0), //increase padding to reduce SVG size
                          // child: SvgPicture.asset(
                          //   contents[i].image,
                          //   // height: 50,
                          //   // width: 50,
                          //   color: Colors.white,
                          // ),

                          // child: Image.asset(
                          //         "assets/images/placeholder_img.png",
                          //         // "https://i.ytimg.com/vi/LPe56fezmoo/maxresdefault.jpg",
                          //         width: MediaQuery.of(context).size.width,
                          //         height: 120,
                          //         fit: BoxFit.contain,
                          //       ),
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
                  // navigateToProfileScreen();
                  log("Going back");
                  Navigator.pop(context);
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
    );
  }

  Widget followMessageButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: 110,
            height: 48,
            // color: Colors.blue,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(25),
            //   color: Colors.purple,
            //   // gradient: const LinearGradient(
            //   //     colors: [
            //   //       Colors.blue,
            //   //       Colors.deepPurple,
            //   //     ],
            //   //     stops: [
            //   //       0.0,
            //   //       100.0
            //   //     ],
            //   //     begin: FractionalOffset.centerLeft,
            //   //     end: FractionalOffset.centerRight,
            //   //     tileMode: TileMode.repeated),
            // ),

            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                log('Follow clicked');
              },
              child: Ink(
                height: 45,
                // color: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: appBlueColor,
                  ),
                  // color: Colors.blue[800],
                  // color: appBlueColor,
                  //   gradient: const LinearGradient(
                  //       colors: [
                  //         Colors.blue,
                  //         Colors.deepPurple,
                  //       ],
                  //       stops: [
                  //         0.0,
                  //         100.0
                  //       ],
                  //       begin: FractionalOffset.centerLeft,
                  //       end: FractionalOffset.centerRight,
                  //       tileMode: TileMode.repeated),
                ),
                child: const Center(
                  child: Text(
                    "Follow",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appBlueColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Roboto-Regular',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Center(
        //   child: OutlinedButton(
        //     style: OutlinedButton.styleFrom(
        //       primary: Colors.white,
        //       backgroundColor: Colors.teal,
        //     ),
        //     child: Text('Woolha.com'),
        //     onPressed: () {
        //       print('Pressed');
        //     },
        //   ),
        // ),
        const SizedBox(
          width: 20,
        ),

        Center(
          child: Container(
            width: 110,
            height: 48,
            // color: Colors.blue,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(25),
            //   color: Colors.purple,
            //   // gradient: const LinearGradient(
            //   //     colors: [
            //   //       Colors.blue,
            //   //       Colors.deepPurple,
            //   //     ],
            //   //     stops: [
            //   //       0.0,
            //   //       100.0
            //   //     ],
            //   //     begin: FractionalOffset.centerLeft,
            //   //     end: FractionalOffset.centerRight,
            //   //     tileMode: TileMode.repeated),
            // ),

            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                log('Message clicked');
                openMessageScreen();
              },
              child: Ink(
                height: 45,
                // color: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // color: Colors.blue[800],
                  color: appBlueColor,
                  //   gradient: const LinearGradient(
                  //       colors: [
                  //         Colors.blue,
                  //         Colors.deepPurple,
                  //       ],
                  //       stops: [
                  //         0.0,
                  //         100.0
                  //       ],
                  //       begin: FractionalOffset.centerLeft,
                  //       end: FractionalOffset.centerRight,
                  //       tileMode: TileMode.repeated),
                ),
                child: const Center(
                  child: Text(
                    "Message",
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
      ],
    );
  }

  Widget logoutButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Center(
        //   child: Container(
        //     width: 110,
        //     height: 48,
        //     // color: Colors.blue,
        //     // decoration: BoxDecoration(
        //     //   borderRadius: BorderRadius.circular(25),
        //     //   color: Colors.purple,
        //     //   // gradient: const LinearGradient(
        //     //   //     colors: [
        //     //   //       Colors.blue,
        //     //   //       Colors.deepPurple,
        //     //   //     ],
        //     //   //     stops: [
        //     //   //       0.0,
        //     //   //       100.0
        //     //   //     ],
        //     //   //     begin: FractionalOffset.centerLeft,
        //     //   //     end: FractionalOffset.centerRight,
        //     //   //     tileMode: TileMode.repeated),
        //     // ),
        //
        //     child: InkWell(
        //       borderRadius: BorderRadius.circular(15),
        //       onTap: () {
        //         log('Follow clicked');
        //       },
        //       child: Ink(
        //         height: 45,
        //         // color: Colors.blue,
        //         decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(15),
        //           border: Border.all(
        //             color: appBlueColor,
        //           ),
        //           // color: Colors.blue[800],
        //           // color: appBlueColor,
        //           //   gradient: const LinearGradient(
        //           //       colors: [
        //           //         Colors.blue,
        //           //         Colors.deepPurple,
        //           //       ],
        //           //       stops: [
        //           //         0.0,
        //           //         100.0
        //           //       ],
        //           //       begin: FractionalOffset.centerLeft,
        //           //       end: FractionalOffset.centerRight,
        //           //       tileMode: TileMode.repeated),
        //         ),
        //         child: const Center(
        //           child: Text(
        //             "Follow",
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               color: appBlueColor,
        //               fontSize: 18,
        //               fontWeight: FontWeight.bold,
        //               // fontFamily: 'Roboto-Regular',
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // // Center(
        // //   child: OutlinedButton(
        // //     style: OutlinedButton.styleFrom(
        // //       primary: Colors.white,
        // //       backgroundColor: Colors.teal,
        // //     ),
        // //     child: Text('Woolha.com'),
        // //     onPressed: () {
        // //       print('Pressed');
        // //     },
        // //   ),
        // // ),
        // const SizedBox(
        //   width: 20,
        // ),

        Center(
          child: Container(
            width: 110,
            height: 48,
            // color: Colors.blue,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(25),
            //   color: Colors.purple,
            //   // gradient: const LinearGradient(
            //   //     colors: [
            //   //       Colors.blue,
            //   //       Colors.deepPurple,
            //   //     ],
            //   //     stops: [
            //   //       0.0,
            //   //       100.0
            //   //     ],
            //   //     begin: FractionalOffset.centerLeft,
            //   //     end: FractionalOffset.centerRight,
            //   //     tileMode: TileMode.repeated),
            // ),

            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                log('Logout clicked');
                signOutUser();
              },
              child: Ink(
                height: 45,
                // color: Colors.blue,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // color: Colors.blue[800],
                  color: appBlueColor,
                  //   gradient: const LinearGradient(
                  //       colors: [
                  //         Colors.blue,
                  //         Colors.deepPurple,
                  //       ],
                  //       stops: [
                  //         0.0,
                  //         100.0
                  //       ],
                  //       begin: FractionalOffset.centerLeft,
                  //       end: FractionalOffset.centerRight,
                  //       tileMode: TileMode.repeated),
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
      ],
    );
  }
}
