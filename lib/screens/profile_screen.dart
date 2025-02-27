import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/models/onboarding_content.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/all_chats_screen.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/login_screen_new1.dart';
import 'package:social_app/screens/message_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

// import 'package:social_app/resources/firestore_methods.dart';
// import 'package:social_app/widgets/follow_button.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - ProfileScreen - ";

class ProfileScreen extends StatefulWidget {
  final String uid;
  final bool showBackButton;
  final bool darkMode;

  const ProfileScreen({
    Key? key,
    required this.uid,
    this.darkMode = false,
    this.showBackButton = false,
  }) : super(key: key);

  // const TestProfileScreen({
  //   Key? key,
  // }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  Uint8List? _image;
  late PageController _controller;
  int currentIndex = 0;
  double bottomPadding = 20;

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

  void openAllChatsScreen() {
    log("openAllChatsScreen");

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AllChatsScreen(),
    ));
  }

  getData() async {
    log("$TAG getData called : UID =  ${widget.uid}");
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      log("$TAG got userSnap");

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get();
      log("$TAG got postSnap");

      postLen = postSnap.docs.length;
      log("$TAG postLen = $postLen");
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      setState(() {});
    } catch (e) {
      log("$TAG Error: ${e.toString()}");
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      showSnackBar(msg: e.toString(), context: context, duration: 1500);
      // showSnackBar(
      //   context,
      //   e.toString(),
      // );
    }
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = false;
    });
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
      return const CircleAvatar(
        radius: 42,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
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
    // final deviceHeight = MediaQuery.of(context).size.height;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        // : SafeArea(
        // top: true,
        // bottom: true,
        : Scaffold(
            backgroundColor: darkMode ? profileBackgroundColor : profileBackgroundColorLight2,
            extendBodyBehindAppBar: true,
            appBar: (showProfileScreenAppBar && widget.showBackButton)
                ? AppBar(
                    title: Text(
                      //"Profile",
                      "@${userData['username']}",
                        style: TextStyle(
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    iconTheme: IconThemeData(color: darkMode ? Colors.white : Colors.black),
                    centerTitle: true,
                    // backgroundColor: Colors.transparent,
                    // elevation: 0,
                    backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight,

                    // leading:  IconButton(
                    //   icon: const Icon(
                    //     Icons.arrow_back,
                    //     color: primaryColor,
                    //   ),
                    //   onPressed: () {
                    //   },
                    // ),
                    actions: [
                      // TextButton(
                      //   onPressed: (){},
                      //   child: const Text(
                      //     "Skip",
                      //     style: TextStyle(
                      //       fontSize: 16,
                      //       color: Colors.white,
                      //       // fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),
                    ],
                  )
                : null,

            // body: getTestOnboardingBody(deviceHeight),

            body: getProfileScreenBody(darkMode),
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
        FutureBuilder(
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
        )
      ],
    );
  }

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

}
