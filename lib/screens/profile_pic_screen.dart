import 'dart:ffi';
import 'dart:typed_data';

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
  String profilePicURLInFirebase = "";

  // final TextEditingController _spotTitleController = TextEditingController();
  // final TextEditingController _categoryController = TextEditingController();

  _selectImage(BuildContext parentContext) async {
    return showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
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
    model.User user = _userProvider.getUser;
    log("$TAG getUserData(): currentUser!.uid: ${user.uid}");
    profilePicURLInFirebase = user.photoUrl;
    log("$TAG getUserData(): profilePicURLInFirebase: ${profilePicURLInFirebase}");
  }

  void addUserProfilePicAndBio(String uid, String username, String profImage) async {
    // showSnackBar(
    //   context: context,
    //   msg: "add post image ... will be implemented soon",
    // );
    FocusScope.of(context).unfocus();
    log('addUserProfilePicAndBio clicked');
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

    log('Error: $error');
    log('ErrorMsg: $errorMsg');
    if ((_file != null || _bioController.text.trim().isNotEmpty) && !error) {
      log('addUserProfilePicAndBio(): calling setUserProfilePicAndBio API');
      setState(() {
        isLoading = true;
      });
      // start the loading
      try {
        // upload profile pic to Firebase DB
        String res = await AuthMethods().setUserProfilePicAndBio(
          uid: uid,
          bio: _bioController.text,
          imgFile: _file,
        );
        log("Result (uploadPost) : $res");
        if (res == "success") {
          setState(() {
            isLoading = false;
          });
          showSnackBar(context: context, msg: 'Profile Picture Added Successfully!', duration: 2500);
          clearImage();
          if (widget.fromSignUp) {
            log("$TAG going to HomeScreen");
            goToHomeScreen();
          } else {
            log("$TAG going back");
            goBack();
          }
        } else {
          showSnackBar(context: context, msg: res);
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
      goToHomeScreen();
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

  void goBack() {
    _file = null;
    Navigator.pop(context);
  }

  void clearImage() {
    setState(() {
      _file = null;
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    // _spotTitleController.dispose();
    // _categoryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Widget returnProfilePicWidgetIfAvailable() {
    return Consumer<UserProvider>(
      builder: (_, provider, __) => provider.getProfilePicURL==""
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
              image: FadeInImage.assetNetwork(placeholder: "assets/images/placeholder_img.png", image: provider.getProfilePicURL).image,
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
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    String? bio="";
    try {
      if (userProvider != null && userProvider.getUser != null && userProvider.getUser.photoUrl != null) {
        log("$TAG build(): profileIMG in Firebase: ${userProvider.getUser.photoUrl}");
        bio=userProvider.getUser.bio;

        if(bio==null) {
          bio = "";
        }
      } else {
        if (userProvider == null) {
          log("$TAG build(): userProvider == null");
        } else if (userProvider.getUser == null) {
          log("$TAG build(): userProvider.getUser == null");
        } else if (userProvider.getUser.photoUrl == null) {
          log("$TAG build(): userProvider.getUser.photoUrl == null");
        }
      }
    } catch (e) {
      log("$TAG build(): Error: ${e.toString()}");
    }
    if(bio!=null) {
      _bioController.text = bio;
    }
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
                onPressed: goBack,
              )
            : null,
        title: const Text(
          'Add Profile Picture',
        ),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Center(
                child: Text(
                  "Let's build your profile",
                  style: TextStyle(
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
                  hintText: 'Add your bio',
                  textInputType: TextInputType.text,
                  textEditingController: _bioController,
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
                    onTap: () => addUserProfilePicAndBio(
                      userProvider.getUser.uid,
                      userProvider.getUser.username,
                      userProvider.getUser.photoUrl,
                    ),
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
