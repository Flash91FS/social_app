import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';

// import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/text_field_input.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool isLoading = false;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _spotTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

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
    bool error = false;
    String errorMsg = "Oops! Something went wrong.";
    if (_spotTitleController.text.trim().isEmpty) {
      errorMsg = "Please enter a Title before adding a Spot";
      error = true;
    } else if (_descriptionController.text.trim().isEmpty) {
      errorMsg = "You must add a description";
      error = true;
    } else if (_categoryController.text.trim().isEmpty) {
      errorMsg = "You must add a category";
      error = true;
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
        String res = await FireStoreMethods().uploadPost(
          _spotTitleController.text,
          _descriptionController.text,
          _categoryController.text,
          _file!,
          uid,
          username,
          profImage,
        );
        log("Result (uploadPost) : $res");
        if (res == "success") {
          setState(() {
            isLoading = false;
          });
          showSnackBar(
            context: context, msg: 'Spot Added Successfully!', duration: 2500
          );
          clearImage();
        } else {
          showSnackBar(context: context, msg: res);
        }
      } catch (err) {
        setState(() {
          isLoading = false;
        });
        log("Exception : ${err.toString()}");
        showSnackBar(
          context: context, msg: err.toString(),
        );
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

  @override
  void dispose() {
    _descriptionController.dispose();
    _spotTitleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
        title: const Text(
          'Add a Spot',
        ),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            // onPressed: () {},
            onPressed: () => postImage(
              userProvider.getUser.uid,
              userProvider.getUser.username,
              userProvider.getUser.photoUrl,
            ),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: TextFieldInput(
                hintText: 'Description',
                textInputType: TextInputType.text,
                textEditingController: _descriptionController,
                maxLines: 4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: TextFieldInput(
                hintText: 'Choose Category',
                textInputType: TextInputType.text,
                textEditingController: _categoryController,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              child: Text('Choose Picture',
                style: TextStyle(
                  // color: Colors.white,
                  fontSize: 18,
                  // fontFamily: 'Roboto-Regular',
                ),),
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
                  // onTap: () {
                  //   showSnackBar(msg: "Add Spot... Will be implemented soon!", context: context, duration: 2000);
                  // },
                  onTap: () => postImage(
                    userProvider.getUser.uid,
                    userProvider.getUser.username,
                    userProvider.getUser.photoUrl,
                  ),
                  child: Ink(
                    height: 45,
                    // color: Colors.blue,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.blue[800],
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
