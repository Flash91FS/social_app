import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/apis/dio_api_helper.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';

// import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:video_player/video_player.dart';

const String TAG = "FS - AddFeedScreen - ";

class AddFeedScreen extends StatefulWidget {
  final LocationData? loc;

  const AddFeedScreen({Key? key, required this.loc}) : super(key: key);

  @override
  _AddFeedScreenState createState() => _AddFeedScreenState();
}

class _AddFeedScreenState extends State<AddFeedScreen> {
  Uint8List? _file;
  Uint8List? _videoFile;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _spotTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  List<DropdownMenuItem<String>>? _dropdownMenuItems;

  String? _selectedCompany; // = "Choose a Category";
  String path = "";
  String fileName = "";

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
                  XFile? file = await pickImage2(ImageSource.camera);
                  setState(() {
                    if (file != null) {
                      getFileAndPath(file);
                    }
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile? file = await pickImage2(ImageSource.gallery);
                  setState(() {
                    if (file != null) {
                      getFileAndPath(file);
                    }
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Capture video'),
                onPressed: () async {
                  Navigator.pop(context);
                  XFile? file = await pickVideo2(ImageSource.camera);
                  setState(() {
                    if (file != null) {
                      getVideoFileAndPath(file);
                    }
                  });
                }),
            SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose video from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  XFile? file = await pickVideo2(ImageSource.gallery);
                  setState(() {
                    if (file != null) {
                      getVideoFileAndPath(file);
                    }
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

  void postImage(String uid, String username, String profImage) async {
    // showSnackBar(
    //   context: context,
    //   msg: "add post image ... will be implemented soon",
    // );
    FocusScope.of(context).unfocus();
    log('postImage clicked');
    log("$TAG postImage(): _selectedCompany ==  $_selectedCompany");
    String? category = categoryMap[_selectedCompany!];
    log("$TAG postImage(): category ==  $category");
    bool error = false;
    String errorMsg = "Oops! Something went wrong.";
    if (_spotTitleController.text.trim().isEmpty) {
      errorMsg = "Please enter a Title before adding a Spot";
      error = true;
    } else if (_descriptionController.text.trim().isEmpty) {
      errorMsg = "You must add a description";
      error = true;
      // } else if (_categoryController.text.trim().isEmpty) {
      //   errorMsg = "You must add a category";
      //   error = true;
    } else if (_selectedCompany!.contains("0") || category == null) {
      errorMsg = "You must add a category";
      error = true;
      // } else if (_file == null) {
      //   errorMsg = "An Image has to be added to add a Spot";
      //   error = true;
    } else if (_file == null && _videoFile == null) {
      errorMsg = "An Image or Video has to be added to add a Spot";
      error = true;
    } else if (path == "") {
      errorMsg = "An Image path could not be found";
      error = true;
    }

    log('Error: $error');
    log('ErrorMsg: $errorMsg');
    if (!error) {
      // todo add post image
      setState(() {
        isLoading = true;
      });
      // start the loading
      try {
        // // upload to storage and db
        final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
        LocationData? userLoc = locProvider.getLoc;
        if (userLoc == null) {
          throw Exception("Could not get user location please go back and try again");
        } else {
          // String res = await FireStoreMethods().uploadPost(
          //   _spotTitleController.text,
          //   _descriptionController.text,
          //   category!,
          //   // _categoryController.text,
          //   _file!,
          //   uid,
          //   username,
          //   profImage,
          //   userLoc.latitude!.toString(),
          //   userLoc.longitude!.toString(),
          // );
          // log("Result (uploadPost) : $res");
          // if (res == "success") {
          //   setState(() {
          //     isLoading = false;
          //   });
          //   showSnackBar(
          //       context: context, msg: 'Spot Added Successfully!', duration: 2500
          //   );
          //   clearImage();
          //
          //   Navigator.of(context).pop();
          //
          // } else {
          //   showSnackBar(context: context, msg: res);
          // }

          HTTPResponse<Map<String, dynamic>> response = await DioApiHelper.addPostMultiPart(
              user_id: "8",
              category_id: "1",
              title: _spotTitleController.text,
              //"Post 4",
              description: _descriptionController.text,
              //"Forth test post now from phone",
              location: "Islamabad Pakistan",
              latitude: userLoc.latitude!.toString(),
              longitude: userLoc.longitude!.toString(),

              //     _spotTitleController.text,
              //     _descriptionController.text,
              //     category!,
              //     // _categoryController.text,
              //     _file!,
              //     uid,
              //     username,
              //     profImage,
              //     userLoc.latitude!.toString(),
              //     userLoc.longitude!.toString(),
              path: path,
              fileName: fileName,
              file: _file,
              isVideo: (_videoFile != null));
          if (response.isSuccessful) {
            log("SHOW SUCCESS ");
            showSnackBar(context: context, msg: 'Spot Added Successfully!', duration: 2500);
            clearImage();
            Navigator.of(context).pop();
          } else {
            log("SHOW ERROR ");
            showSnackBar(context: context, msg: "Error: Could not add Spot", duration: 2500);
          }
          setState(() {
            isLoading = false;
          });
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        log("Exception : ${err.toString()}");
        showSnackBar(context: context, msg: err.toString(), duration: 2000);
      }
    } else {
      showSnackBar(msg: errorMsg, context: context, duration: 2000);
    }
  }

  void goBack() {
    _file = null;
    _videoFile = null;
    Navigator.pop(context);
  }

  void clearImage() {
    setState(() {
      _file = null;
      _videoFile = null;
    });
  }

  @override
  void initState() {
    super.initState();
    log("$TAG initState():");

    _dropdownMenuItems = buildDropdownMenuItems();
    log("$TAG initState(): _dropdownMenuItems.length ==  ${_dropdownMenuItems!.length}");
    _selectedCompany =
        (_dropdownMenuItems != null && _dropdownMenuItems!.isNotEmpty) ? _dropdownMenuItems![0].value! : null;
  }

  List<DropdownMenuItem<String>> buildDropdownMenuItems() {
    //List companies) {
    List<DropdownMenuItem<String>> items = [];
    categoryMap.forEach((key, v) {
      print("sortedMap KEY == $key");
      print("sortedMap VAL == $v");
      items.add(
        DropdownMenuItem(
          value: key,
          child: Text(v),
        ),
      );
    });
//    for (Company company in companies) {
//      items.add(
//        DropdownMenuItem(
//          value: company,
//          child: Text(company.name),
//        ),
//      );
//    }
    return items;
  }

  onChangeDropdownItem(selectedCompany) {
    setState(() {
      _selectedCompany = selectedCompany;
    });
    // _refreshWatchlistPage();
  }

  @override
  void didUpdateWidget(covariant AddFeedScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    log("$TAG didUpdateWidget():");
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _spotTitleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build():");
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool darkMode = themeChange.darkTheme;
    log("$TAG build(): darkMode == ${darkMode}");
    if (widget.loc != null) {
      log("$TAG build(): _locationData = ${widget.loc}");
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
      backgroundColor: darkMode ? cardColorDark : cardColorLight,
      appBar: AppBar(
        backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight,
        //
        iconTheme: IconThemeData(color: darkMode ? Colors.white : Colors.black),
        //todo back button feature
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: goBack,
        // ),
        title: Text(
          'Add a Spot',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (!isLoading) {
                postImage(
                  userProvider.getUser.uid,
                  userProvider.getUser.username,
                  userProvider.getUser.photoUrl,
                );
              } else {
                showSnackBar(context: context, msg: "Already adding a Spot, please wait", duration: 1200);
              }
            },
            // onPressed: () => postImage(
            //   userProvider.getUser.uid,
            //   userProvider.getUser.username,
            //   userProvider.getUser.photoUrl,
            // ),
            child: const Text(
              "Post",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          )
        ],
      ),
      // POST FORM
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isLoading ? const LinearProgressIndicator() : const Padding(padding: EdgeInsets.only(top: 0.0)),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: TextFieldInput(
                hintText: 'Spot Title',
                textInputType: TextInputType.text,
                textEditingController: _spotTitleController,
                darkBackground: darkMode,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: TextFieldInput(
                hintText: 'Description',
                textInputType: TextInputType.text,
                textEditingController: _descriptionController,
                darkBackground: darkMode,
                maxLines: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: DropdownButton(
                value: _selectedCompany,
                items: _dropdownMenuItems,
                onChanged: onChangeDropdownItem,
                style: TextStyle(
                  color: darkMode ? textColorDark : textColorLight,
                ),
              ),
              // child: TextFieldInput(
              //   hintText: 'Choose Category',
              //   textInputType: TextInputType.text,
              //   textEditingController: _categoryController,
              // ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Text(
                'Choose Picture',
                style: TextStyle(
                  color: darkMode ? textColorDark : textColorLight,
                  fontSize: 18,
                  // fontFamily: 'Roboto-Regular',
                ),
              ),
            ),

            //------------ CHOOSE PICTURE WIDGET -------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: GestureDetector(
                onTap: () {
                  _selectImage(context);
                },
                child: SizedBox(
                  // height: 55.0,
                  // width: 55.0,
                  height: 205.0,
                  width: double.infinity,
                  child: AspectRatio(
                    aspectRatio: 487 / 451,
                    child: getImageOrVideoWidget(darkMode),

                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () {
                    if (!isLoading) {
                      postImage(
                        userProvider.getUser.uid,
                        userProvider.getUser.username,
                        userProvider.getUser.photoUrl,
                      );
                    } else {
                      showSnackBar(context: context, msg: "Already adding a Spot, please wait", duration: 1200);
                    }
                  },
                  // onTap: () => postImage(
                  //   userProvider.getUser.uid,
                  //   userProvider.getUser.username,
                  //   userProvider.getUser.photoUrl,
                  // ),
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
                        "Add Spot",
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
            //         controller: _descriptionController,
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

  Future<void> getFileAndPath(XFile file) async {
    try {
      _file = null;
      _videoFile = null;
      path = "";
      fileName = "";
      path = file.path;
      fileName = path.split("/").last;
      log("$TAG getFileAndPath == ${path}");
      log("$TAG fileName == ${fileName}");
      _file = await file.readAsBytes();
    } catch (e) {
      log("$TAG -- getFileAndPath() Error: ${e.toString()}");
    }
  }

  Future<void> getVideoFileAndPath(XFile file) async {
    try {
      _file = null;
      _videoFile = null;
      path = "";
      fileName = "";
      path = file.path;
      fileName = path.split("/").last;
      log("$TAG getFileAndPath == ${path}");
      log("$TAG fileName == ${fileName}");
      _videoFile = await file.readAsBytes();
      initializePlayerFromFile();
    } catch (e) {
      log("$TAG -- getVideoFileAndPath() Error: ${e.toString()}");
    }
  }

  late VideoPlayerController _videoPlayerController1;
  late Future<void> _initializeVideoPlayerFuture;
  Future<void> initializePlayerFromFile() async {
    log("$TAG initializePlayerFromFile(): path = ${path}");
    final File file = File(path);
    // _videoPlayerController1 = VideoPlayerController.network(srcs[currPlayIndex]);
    _videoPlayerController1 = VideoPlayerController.file(file);

    _initializeVideoPlayerFuture = _videoPlayerController1.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    // if (widget.play) {
    //   _videoPlayerController1.play();
    //   _videoPlayerController1.addListener(() {
    //
    //   });
    //   // _videoPlayerController1.setLooping(true);
    // }
    // await Future.wait([
    //   _videoPlayerController1.initialize(),
    // ]);
    // _createChewieController();
    // setState(() {});
  }

  Widget getImageOrVideoWidget(bool darkMode) {

    if (_file != null) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[900],
            image: DecorationImage(
              fit: BoxFit.contain,
              alignment: FractionalOffset.topCenter,
              image: MemoryImage(_file!),
            )),
      );
    } else if (_videoFile != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.grey[900],
          color: darkMode ? Colors.grey[900] : Colors.grey[400],
        ),
        child: Center(
            child: FutureBuilder(
                // key: PageStorageKey(widget.snap["postId"]),
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Chewie(
                      // key: PageStorageKey(widget.snap["postId"]),
                      controller: ChewieController(
                        videoPlayerController: _videoPlayerController1,
                        autoPlay: false,
                        looping: false,
                        // Try playing around with some of these other options:

                        showControls: true,
                        placeholder: Container(
                          color: Colors.black,
                        ),
                        autoInitialize: true,
                      ),
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    );
                  }
                })
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: Colors.grey[900],
        color: darkMode ? Colors.grey[900] : Colors.grey[400],
      ),
      child: const Center(
        // child: ImageIcon(
        //   const AssetImage('assets/images/send_48.png'),
        //   size: 32,
        //   color: Colors.white,//(darkMode ? iconColorLight : iconColorDark),//Colors.white,
        // ),
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
    );
  }
}
