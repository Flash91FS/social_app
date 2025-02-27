import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/categories_screen.dart';

// import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/text_field_input.dart';

const String TAG = "FS - AddPostScreen - ";

class AddPostScreen extends StatefulWidget {
  final LocationData? loc;

  const AddPostScreen({Key? key, required this.loc}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _spotTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  // List<DropdownMenuItem<String>>? _dropdownMenuItems;

  // String? _selectedCompany;// = "Choose a Category";

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

  void postImage(String uid, String username, String profImage) async {
    // showSnackBar(
    //   context: context,
    //   msg: "add post image ... will be implemented soon",
    // );
    FocusScope.of(context).unfocus();
    log('postImage clicked');
    // log("$TAG postImage(): _selectedCompany ==  $_selectedCompany");
    // String? category = categoryMap[_selectedCompany!];
    // log("$TAG postImage(): category ==  $category");
    log("$TAG postImage(): selectedCategoryKey ==  $selectedCategoryKey");
    log("$TAG postImage(): selectedCategoryValue ==  $selectedCategoryValue");
    bool error = false;
    String errorMsg = "Oops! Something went wrong.";
    if (_spotTitleController.text.trim().isEmpty) {
      errorMsg = "Please enter a Title before adding a Spot";
      error = true;
    } else if (_descriptionController.text.trim().isEmpty) {
      errorMsg = "You must add a description";
      error = true;
    } else if (selectedCategoryKey=="") {
      errorMsg = "You must select a category";
      error = true;
    } else if (selectedCategoryValue=="") {
      errorMsg = "You must select a category";
      error = true;
    } else if (_categoryController.text.trim().isEmpty) {
      errorMsg = "You must select a category";
      error = true;
      // } else if (_selectedCompany!.contains("0") || category == null) {
      //   errorMsg = "You must add a category";
      //   error = true;
    } else if (_file == null) {
      errorMsg = "An Image has to be added to add a Spot";
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
        // upload to storage and db
        final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
        LocationData? userLoc = locProvider.getLoc;
        if (userLoc == null) {
          throw Exception("Could not get user location please go back and try again");
        } else {
          // log("$TAG postImage(): userLoc.latitude ==  ${userLoc.latitude!.toString()}");
          // log("$TAG postImage(): userLoc.longitude ==  ${userLoc.longitude!.toString()}");
          String res = await FireStoreMethods().uploadPost(
            _spotTitleController.text,
            _descriptionController.text,
            // category!,
            _categoryController.text,
            selectedCategoryKey,
            _file!,
            uid,
            username,
            profImage,
            userLoc.latitude!.toString(),
            userLoc.longitude!.toString(),
          );
          log("Result (uploadPost) : $res");
          if (res == "success") {
            setState(() {
              isLoading = false;
            });
            showSnackBar(context: context, msg: 'Spot Added Successfully!', duration: 2500);
            clearImage();

            Navigator.of(context).pop();
          } else {
            showSnackBar(context: context, msg: res);
          }
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
    // todo add post image
    // setState(() {
    //   isLoading = true;
    // });
    // // start the loading
    // try {
    //   // upload to storage and db
    //   String res = await FireStoreMethods().uploadPost(
    //     _descriptionController.text,
    //     _file!,
    //     uid,
    //     username,
    //     profImage,
    //   );
    //   if (res == "success") {
    //     setState(() {
    //       isLoading = false;
    //     });
    //     showSnackBar(
    //       context: context, msg: 'Posted!',
    //     );
    //     clearImage();
    //   } else {
    //     showSnackBar(context: context, msg: res);
    //   }
    // } catch (err) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   showSnackBar(
    //     context: context, msg: err.toString(),
    //   );
    // }
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

  String selectedCategoryKey = "";
  String selectedCategoryValue = "";

  Future<void> openCategoriesScreen() async {
    log("openCategoriesScreen");

    var result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CategoriesScreen(),
    ));
    log("openCategoriesScreen: result == $result");

    if (result != null) {
      String? categoryValue = categoryMap222["$result"];
      if (categoryValue != null) {
        selectedCategoryKey = "$result";
        selectedCategoryValue = categoryValue;
        _categoryController.text = categoryValue;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    log("$TAG initState():");

    // _dropdownMenuItems = buildDropdownMenuItems();
    // log("$TAG initState(): _dropdownMenuItems.length ==  ${_dropdownMenuItems!.length}");
    // _selectedCompany = (_dropdownMenuItems != null && _dropdownMenuItems!.isNotEmpty) ? _dropdownMenuItems![0].value! : null;
  }

//   List<DropdownMenuItem<String>> buildDropdownMenuItems() {
//     //List companies) {
//     List<DropdownMenuItem<String>> items = [];
//     categoryMap.forEach((key, v) {
//       print("sortedMap KEY == $key");
//       print("sortedMap VAL == $v");
//       items.add(
//         DropdownMenuItem(
//           value: key,
//           child: Text(v),
//         ),
//       );
//     });
// //    for (Company company in companies) {
// //      items.add(
// //        DropdownMenuItem(
// //          value: company,
// //          child: Text(company.name),
// //        ),
// //      );
// //    }
//     return items;
//   }

  // onChangeDropdownItem(selectedCompany) {
  //   setState(() {
  //     _selectedCompany = selectedCompany;
  //   });
  //   // _refreshWatchlistPage();
  // }

  @override
  void didUpdateWidget(covariant AddPostScreen oldWidget) {
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
              child: ElevatedButton(
                onPressed: () {
                  openCategoriesScreen();
                },
                child: Text("Select a Category"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              child: TextFieldInput(
                hintText: 'Category',
                textInputType: TextInputType.text,
                readOnly: true,
                darkBackground: darkMode,
                textEditingController: _categoryController,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            //   child: DropdownButton(
            //     value: _selectedCompany,
            //     items: _dropdownMenuItems,
            //     onChanged: onChangeDropdownItem,
            //     style: TextStyle(
            //       color: darkMode ? textColorDark : textColorLight,
            //     ),
            //   ),
            //   // child: TextFieldInput(
            //   //   hintText: 'Choose Category',
            //   //   textInputType: TextInputType.text,
            //   //   textEditingController: _categoryController,
            //   // ),
            // ),
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
                    child: _file == null
                        ? Container(
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
                          )
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
}
