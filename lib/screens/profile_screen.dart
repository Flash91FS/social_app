import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';

// import 'package:social_app/resources/firestore_methods.dart';
// import 'package:social_app/widgets/follow_button.dart';
import 'package:social_app/utils/utils.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({Key? key, required this.uid}) : super(key: key);
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

  @override
  void initState() {
    super.initState();
    log("initState called");
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    log("dispose called");
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

  Future<void> selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  getData() async {
    log("getData called : UID =  ${widget.uid}");
    if (!mounted) {
      log("Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      log("got userSnap");

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      log("got postSnap");

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      if (!mounted) {
        log("Already unmounted i.e. Dispose called");
        return;
      }
      setState(() {});
    } catch (e) {

      log("Error: ${e.toString()}");
      if (!mounted) {
        log("Already unmounted i.e. Dispose called");
        return;
      }
      showSnackBar(msg:e.toString(), context: context, duration: 1500);
      // showSnackBar(
      //   context,
      //   e.toString(),
      // );
    }
    if (!mounted) {
      log("Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            // appBar: AppBar(
            //   backgroundColor: mobileBackgroundColor,
            //   title: Text(
            //     "Profile",
            //     // userData['username'],
            //   ),
            //   centerTitle: true,
            // ),
            body: ListView(
              children: [
                Column(
                  children: [
                    Container(
                        width: double.infinity,
                        height: 260,
                        // color: Colors.grey,
                        child: Stack(children: [
                          Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/social-app-2b7dd.appspot.com/o/posts%2FEgDtot0E3ZQ56qa8U0dMcNDwfg03%2F9ad533f0-779c-11ec-a8a8-3f9f6134b863?alt=media&token=c469a927-e12a-4bd4-8d2e-ca83207c3c03",
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
                                      : CircleAvatar(
                                    radius: 40,
                                    // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
                                    backgroundImage: NetworkImage("${userData['photoUrl']}"),
                                    backgroundColor: Colors.white,
                                  ),
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
                        ],),),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      // color: Colors.blue,
                      child: Center(
                        child: Text(
                          // "@username",
                          "@${userData['username']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                          userData['bio'],
                          style: const TextStyle(
                            fontSize: 18,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    SizedBox(
                      width: 200,
                      height: 45,
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
                            color: Colors.blue[800],
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
                    const SizedBox(height: 10,),
                    const Divider(),
                  ],
                ),

                FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('posts')
                      .where('uid', isEqualTo: widget.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 1.5,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];

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
            ),

            // body: ListView(
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.all(16),
            //       child: Column(
            //         children: [
            //           Row(
            //             children: [
            //               CircleAvatar(
            //                 backgroundColor: Colors.grey,
            //                 backgroundImage: NetworkImage(
            //                   userData['photoUrl'],
            //                 ),
            //                 radius: 40,
            //               ),
            //               Expanded(
            //                 flex: 1,
            //                 child: Column(
            //                   children: [
            //                     Row(
            //                       mainAxisSize: MainAxisSize.max,
            //                       mainAxisAlignment:
            //                       MainAxisAlignment.spaceEvenly,
            //                       children: [
            //                         buildStatColumn(postLen, "posts"),
            //                         buildStatColumn(followers, "followers"),
            //                         buildStatColumn(following, "following"),
            //                       ],
            //                     ),
            //                     // Row(
            //                     //   mainAxisAlignment:
            //                     //   MainAxisAlignment.spaceEvenly,
            //                     //   children: [
            //                     //     FirebaseAuth.instance.currentUser!.uid ==
            //                     //         widget.uid
            //                     //         ? FollowButton(
            //                     //       text: 'Sign Out',
            //                     //       backgroundColor:
            //                     //       mobileBackgroundColor,
            //                     //       textColor: primaryColor,
            //                     //       borderColor: Colors.grey,
            //                     //       function: () async {
            //                     //         await AuthMethods().signOut();
            //                     //         Navigator.of(context)
            //                     //             .pushReplacement(
            //                     //           MaterialPageRoute(
            //                     //             builder: (context) =>
            //                     //             const LoginScreen(),
            //                     //           ),
            //                     //         );
            //                     //       },
            //                     //     )
            //                     //         : isFollowing
            //                     //         ? FollowButton(
            //                     //       text: 'Unfollow',
            //                     //       backgroundColor: Colors.white,
            //                     //       textColor: Colors.black,
            //                     //       borderColor: Colors.grey,
            //                     //       function: () async {
            //                     //         await FireStoreMethods()
            //                     //             .followUser(
            //                     //           FirebaseAuth.instance
            //                     //               .currentUser!.uid,
            //                     //           userData['uid'],
            //                     //         );
            //                     //
            //                     //         setState(() {
            //                     //           isFollowing = false;
            //                     //           followers--;
            //                     //         });
            //                     //       },
            //                     //     )
            //                     //         : FollowButton(
            //                     //       text: 'Follow',
            //                     //       backgroundColor: Colors.blue,
            //                     //       textColor: Colors.white,
            //                     //       borderColor: Colors.blue,
            //                     //       function: () async {
            //                     //         await FireStoreMethods()
            //                     //             .followUser(
            //                     //           FirebaseAuth.instance
            //                     //               .currentUser!.uid,
            //                     //           userData['uid'],
            //                     //         );
            //                     //
            //                     //         setState(() {
            //                     //           isFollowing = true;
            //                     //           followers++;
            //                     //         });
            //                     //       },
            //                     //     )
            //                     //   ],
            //                     // ),
            //                   ],
            //                 ),
            //               ),
            //             ],
            //           ),
            //           Container(
            //             alignment: Alignment.centerLeft,
            //             padding: const EdgeInsets.only(
            //               top: 15,
            //             ),
            //             child: Text(
            //               userData['username'],
            //               style: TextStyle(
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            //           Container(
            //             alignment: Alignment.centerLeft,
            //             padding: const EdgeInsets.only(
            //               top: 1,
            //             ),
            //             child: Text(
            //               userData['bio'],
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //     const Divider(),
            //     FutureBuilder(
            //       future: FirebaseFirestore.instance
            //           .collection('posts')
            //           .where('uid', isEqualTo: widget.uid)
            //           .get(),
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return const Center(
            //             child: CircularProgressIndicator(),
            //           );
            //         }
            //
            //         return GridView.builder(
            //           shrinkWrap: true,
            //           itemCount: (snapshot.data! as dynamic).docs.length,
            //           gridDelegate:
            //           const SliverGridDelegateWithFixedCrossAxisCount(
            //             crossAxisCount: 3,
            //             crossAxisSpacing: 5,
            //             mainAxisSpacing: 1.5,
            //             childAspectRatio: 1,
            //           ),
            //           itemBuilder: (context, index) {
            //             DocumentSnapshot snap =
            //             (snapshot.data! as dynamic).docs[index];
            //
            //             return Container(
            //               child: Image(
            //                 image: NetworkImage(snap['postUrl']),
            //                 fit: BoxFit.cover,
            //               ),
            //             );
            //           },
            //         );
            //       },
            //     )
            //   ],
            // ),
          );
  }

// Column buildStatColumn(int num, String label) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         num.toString(),
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       Container(
//         margin: const EdgeInsets.only(top: 4),
//         child: Text(
//           label,
//           style: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w400,
//             color: Colors.grey,
//           ),
//         ),
//       ),
//     ],
//   );
// }
}
