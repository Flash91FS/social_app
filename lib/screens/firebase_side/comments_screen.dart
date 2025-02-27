import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:provider/provider.dart';

const String TAG = "FS - CommentsScreen - ";
class CommentsScreen extends StatefulWidget {
  final postId;
  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController commentEditingController =
  TextEditingController();

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.postId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        showSnackBar(msg:res, context: context, duration: 1500);
      }
      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(msg:err.toString(), context: context, duration: 1500);
    }
  }


  Widget returnProfilePicWidgetIfAvailable(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
        backgroundImage: NetworkImage(showUnsplashImage ? unsplashImageURL : photoUrl),
        // backgroundColor: Colors.white,
      );
    } else {
      return const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    // final themeChange = Provider.of<DarkThemeProvider>(context);
    // bool darkMode = themeChange.darkTheme;
    bool darkMode = updateThemeWithSystem();
    DarkThemeProvider _darkThemeProvider = Provider.of(context);
    _darkThemeProvider.setSysDarkTheme(darkMode);
    log("$TAG build(): darkMode == ${darkMode}");

    return Scaffold(
      backgroundColor: darkMode ? cardColorDark : cardColorLight,
      appBar: AppBar(
        iconTheme: IconThemeData(color: darkMode ? Colors.white:Colors.black),
        backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight, //
        title: Text(
          'Comments',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: commentsList(darkMode, user.uid),
      // body: Column(
      //   // mainAxisAlignment: MainAxisAlignment.center,
      //   // mainAxisSize: MainAxisSize.max,
      //   children: [
      //     // new Padding(
      //     //     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      //     //     child: new TextField(
      //     //       decoration: new InputDecoration(
      //     //           hintText: "Type in here!"
      //     //       ),
      //     //     )
      //     // ),
      //     Expanded(child: commentsList(darkMode, user.uid)),
      //   ],
      // ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          color: darkMode ? Colors.grey[900] : Colors.grey[200],
          height: kToolbarHeight,
          margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              returnProfilePicWidgetIfAvailable(user.photoUrl),
              // CircleAvatar(
              //   backgroundImage: NetworkImage(user.photoUrl),
              //   radius: 18,
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: darkMode ? hintTextColorDark : hintTextColorLight,
                      ),
                    ),
                    style: TextStyle(
                      color: darkMode ? textColorDark : textColorLight,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postComment(
                  user.uid,
                  user.username,
                  user.photoUrl,
                ),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget commentsList(bool darkMode, String uid){
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments').orderBy("datePublished", descending: true)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          shrinkWrap: true,
          itemBuilder: (ctx, index) => CommentCard(
            darkMode: darkMode,
            snap: snapshot.data!.docs[index],
            postID: widget.postId,
            userID: uid,
            buttonHandler: _passedFunction,
          ),
        );
      },
    );
  }

  void _passedFunction(String input) {
    log("$TAG _passedFunction(): $input");
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
      return;
    }
    log("$TAG _passedFunction() calling setState()");
    setState(() {});
  }
}