import 'dart:ffi';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/resources/firestore_methods.dart';

// import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/models/user.dart' as model;

import '../providers/dark_theme_provider.dart';
import 'mobile_screen_layout.dart';

const String TAG = "FS - ProfilePicScreen - ";

class ProfilePicScreen extends StatefulWidget {
  final bool showBackButton;
  final bool showSkipButton;
  final bool fromSignUp;

  const ProfilePicScreen({
    Key? key,
    required bool this.showBackButton,
    required bool this.showSkipButton,
    this.fromSignUp = true,
  }) : super(key: key);

  @override
  _ProfilePicScreenState createState() => _ProfilePicScreenState();
}

class _ProfilePicScreenState extends State<ProfilePicScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  String profilePicURLInFirebase = "";

  // final TextEditingController _spotTitleController = TextEditingController();
  // final TextEditingController _categoryController = TextEditingController();

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Add Profile Picture'),
          children: <Widget>[
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List file = await pickImage(ImageSource.camera);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(ImageSource.gallery);
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void getUserData() async {
    log("$TAG getUserData(): currentUser!.uid: ${FirebaseAuth.instance.currentUser!.uid}");
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();

    String? bio = "";
    String? fullName = "";
    try {
      if (_userProvider != null && _userProvider.getUser != null && _userProvider.getUser.photoUrl != null) {
        log("$TAG getUserData(): currentUser!.uid: ${_userProvider.getUser.uid}");
        profilePicURLInFirebase = _userProvider.getUser.photoUrl;
        log("$TAG getUserData(): profilePicURL In Firebase: $profilePicURLInFirebase");

        bio = _userProvider.getUser.bio;
        fullName = _userProvider.getUser.fullName;

        if (bio == null) {
          bio = "";
        }
        if (fullName == null) {
          fullName = "";
        }
      } else {
        if (_userProvider == null) {
          log("$TAG getUserData(): userProvider == null");
        } else if (_userProvider.getUser == null) {
          log("$TAG getUserData(): userProvider.getUser == null");
        } else if (_userProvider.getUser.photoUrl == null) {
          log("$TAG getUserData(): userProvider.getUser.photoUrl == null");
        }
      }
    } catch (e) {
      log("$TAG build(): Error: ${e.toString()}");
    }
    if (bio != null) {
      _bioController.text = bio;
    }
    if (fullName != null) {
      _fullNameController.text = fullName;
    }
  }

  void addUserProfilePicAndBio(String uid, String username, String profImage) async {
    // showSnackBar(
    //   context: context,
    //   msg: "add post image ... will be implemented soon",
    // );
    FocusScope.of(context).unfocus();
    log('$TAG addUserProfilePicAndBio clicked');
    bool error = false;
    String errorMsg = "Oops! Something went wrong.";

    // todo remove comments to make it compulsory to add profile pic and bio
    // if (_file == null) {
    //   log('_file == null');
    //   errorMsg = "You need to add a profile picture";
    //   error = true;
    // } else if (_bioController.text.trim().isEmpty) {
    //   errorMsg = "You must add something about yourself in bio";
    //   error = true;
    // }

    log('$TAG Error: $error');
    log('$TAG ErrorMsg: $errorMsg');
    if ((_file != null || _bioController.text.trim().isNotEmpty || _fullNameController.text.trim().isNotEmpty) &&
        !error) {
      log('$TAG addUserProfilePicAndBio(): calling setUserProfilePicAndBio API');
      setState(() {
        isLoading = true;
      });
      // start the loading
      try {
        // upload profile pic to Firebase DB
        Map<String, String> result = await AuthMethods().setUserProfilePicAndBio(
          uid: uid,
          fullName: _fullNameController.text,
          bio: _bioController.text,
          oldPhotoUrl: profilePicURLInFirebase,
          imgFile: _file,
        );
        log("$TAG Result (uploadPost) : $result");
        String? res = result['result'];
        log("$TAG Result (uploadPost) : $result");
        if (res == "success") {
          if (widget.fromSignUp) {
            log("$TAG going to HomeScreen");
            setState(() {
              isLoading = false;
            });
            showSnackBar(context: context, msg: 'Profile Updated Successfully!', duration: 2500);
            clearImage();
            goToHomeScreen();
          } else {
            log("$TAG going back");

            String photoUrl = '';
            if (result.containsKey("photoUrl")) {
              photoUrl = result['photoUrl'] ?? '';
            }
            dynamic postSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: uid).get();
            for (var doc in postSnap.docs) {
              // log("$TAG navigateToProfileEditScreen(): post = ${doc.data()}");
              final postId = doc.data()['postId'];
              log("$TAG navigateToProfileEditScreen(): postId: = $postId");
              try {
                await FirebaseFirestore.instance.collection("posts").doc(postId).update({
                  "profImage": photoUrl,
                });
              } catch (e) {
                log("$TAG navigateToProfileEditScreen(): Error == ${e.toString()}");
              }
            }

            setState(() {
              isLoading = false;
            });
            showSnackBar(context: context, msg: 'Profile Updated Successfully!', duration: 2500);
            clearImage();
            goBack(true);
          }
        } else {
          showSnackBar(context: context, msg: res.toString());
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        log("addUserProfilePicAndBio() Exception : ${err.toString()}");
        showSnackBar(
          context: context,
          msg: err.toString(),
        );
      }
    } else {
      // showSnackBar(msg: errorMsg, context: context, duration: 2000);
      if (widget.fromSignUp) {
        log("$TAG going to HomeScreen");
        goToHomeScreen();
      } else {
        log("$TAG going back");
        goBack(false);
      }
    }
  }

  void goToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MobileScreenLayout(title: "Home screen"),
        ),
        (route) => false);
  }

  void skip() {
    goToHomeScreen();
  }

  void goBack(bool anythingChanged) {
    _file = null;
    Navigator.pop(context, anythingChanged);
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Widget returnProfilePicWidgetIfAvailable() {
    return Consumer<UserProvider>(
      builder: (_, provider, __) => provider.getProfilePicURL == ""
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[900],
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                ),
                // child: IconButton(
                //   icon: Icon(Icons.add,),
                //   onPressed: (){
                //     _selectImage(context);
                //     },
                // ),
              ),
            )
          : Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[900],
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    alignment: FractionalOffset.topCenter,
                    image: FadeInImage.assetNetwork(
                            placeholder: "assets/images/placeholder_img.png", image: provider.getProfilePicURL)
                        .image,
                  )),
            ),
    );
    // if (picURL == "") {
    //   return Container(
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(10),
    //       color: Colors.grey[900],
    //     ),
    //     child: const Center(
    //       child: Icon(
    //         Icons.add,
    //       ),
    //       // child: IconButton(
    //       //   icon: Icon(Icons.add,),
    //       //   onPressed: (){
    //       //     _selectImage(context);
    //       //     },
    //       // ),
    //     ),
    //   );
    // } else {
    //   return Container(
    //     decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         color: Colors.grey[900],
    //         image: DecorationImage(
    //           fit: BoxFit.contain,
    //           alignment: FractionalOffset.topCenter,
    //           image: FadeInImage.assetNetwork(placeholder: "assets/images/placeholder_img.png", image: picURL).image,
    //         )),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = false;
    darkMode = updateThemeWithSystem();
    DarkThemeProvider _darkThemeProvider = Provider.of(context);
    _darkThemeProvider.setSysDarkTheme(darkMode);
    log("$TAG build(): darkMode == ${darkMode}");

    final UserProvider userProvider = Provider.of<UserProvider>(context);
    // return _file == null
    //     ? Center(
    //   child: IconButton(
    //     icon: const Icon(
    //       Icons.upload,
    //     ),
    //     onPressed: () => _selectImage(context),
    //   ),
    // )
    //     :
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        //todo back button feature
        leading: (widget.showBackButton)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => goBack(false),
              )
            : null,
        title: widget.fromSignUp
            ? const Text(
                'Add Profile Picture',
              )
            : const Text('Edit Profile'),
        centerTitle: true,
        actions: (widget.showSkipButton)
            ? <Widget>[
                TextButton(
                  onPressed: () {
                    skip();
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                )
              ]
            : null,
      ),
      // POST FORM
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isLoading ? const LinearProgressIndicator() : const Padding(padding: EdgeInsets.only(top: 0.0)),
            const Divider(),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            //   child: TextFieldInput(
            //     hintText: 'Spot Title',
            //     textInputType: TextInputType.text,
            //     textEditingController: _spotTitleController,
            //   ),
            // ),

            //------------ CHOOSE PICTURE WIDGET -------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: GestureDetector(
                onTap: () {
                  _selectImage(context);
                },
                child: Center(
                  child: SizedBox(
                    // height: 55.0,
                    // width: 55.0,
                    height: 250.0,
                    width: 250.0,
                    // width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 487 / 451,
                      child: _file == null
                          ? returnProfilePicWidgetIfAvailable()
                          : Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[900],
                                  image: DecorationImage(
                                    fit: BoxFit.contain,
                                    alignment: FractionalOffset.topCenter,
                                    image: MemoryImage(_file!),
                                  )),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Center(
                child: Text(
                  widget.fromSignUp ? "Let's build your profile" : "Update your profile details",
                  style: const TextStyle(
                    // color: Colors.white,
                    fontSize: 18,
                    // fontFamily: 'Roboto-Regular',
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: TextFieldInput(
                  hintText: 'Full Name',
                  textInputType: TextInputType.name,
                  textEditingController: _fullNameController,
                  darkBackground: darkMode,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                child: TextFieldInput(
                  hintText: 'Add your bio',
                  textInputType: TextInputType.text,
                  textEditingController: _bioController,
                  darkBackground: darkMode,
                  maxLines: 4,
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            //   child: TextFieldInput(
            //     hintText: 'Choose Category',
            //     textInputType: TextInputType.text,
            //     textEditingController: _categoryController,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 54,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    // onTap: () {
                    //   showSnackBar(msg: "Add Spot... Will be implemented soon!", context: context, duration: 2000);
                    // },
                    onTap: () {
                      if (!isLoading) {
                        addUserProfilePicAndBio(
                          userProvider.getUser.uid,
                          userProvider.getUser.username,
                          userProvider.getUser.photoUrl,
                        );
                      } else {
                        showSnackBar(context: context, msg: 'Already uploading, please wait!', duration: 1500);
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
                      child: const Center(
                        child: Text(
                          "Done",
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
            const SizedBox(
              height: 54,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: <Widget>[
            //     CircleAvatar(
            //       backgroundImage: NetworkImage(
            //         "https://i.stack.imgur.com/l60Hf.png",
            //         // userProvider.getUser.photoUrl,
            //       ),
            //     ),
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width * 0.3,
            //       child: TextField(
            //         controller: _bioController,
            //         decoration: const InputDecoration(hintText: "Write a caption...", border: InputBorder.none),
            //         maxLines: 8,
            //       ),
            //     ),
            //     GestureDetector(
            //       onTap: () {
            //         _selectImage(context);
            //       },
            //       child: SizedBox(
            //         height: 55.0,
            //         width: 55.0,
            //         child: AspectRatio(
            //           aspectRatio: 487 / 451,
            //           child: _file == null
            //               ? Container(
            //                   decoration: BoxDecoration(
            //                     color: Colors.grey[800],
            //                   ),
            //                   child: Center(
            //                     child: Icon(
            //                       Icons.add,
            //                     ),
            //                     // child: IconButton(
            //                     //   icon: Icon(Icons.add,),
            //                     //   onPressed: (){
            //                     //     _selectImage(context);
            //                     //     },
            //                     // ),
            //                   ),
            //                 )
            //               : Container(
            //                   decoration: BoxDecoration(
            //                       image: DecorationImage(
            //                     fit: BoxFit.fill,
            //                     alignment: FractionalOffset.topCenter,
            //                     image: MemoryImage(_file!),
            //                   )),
            //                 ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // const Divider(),
          ],
        ),
      ),
    );
  }
}
