import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/reply_card.dart';

const String TAG = "FS - RepliesScreen - ";
class RepliesScreen extends StatefulWidget {
  final postId;
  final commentId;
  final commentSnap;
  int repliesLen;

  RepliesScreen({Key? key, required this.postId, required this.commentId, required this.commentSnap, required this.repliesLen}) : super(key: key);

  @override
  _RepliesScreenState createState() => _RepliesScreenState();
}

class _RepliesScreenState extends State<RepliesScreen> {
  final TextEditingController commentEditingController = TextEditingController();
  bool anythingChanged = false;
  // int repliesLen = 0;

  void postReply(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postReply(
        widget.postId,
        widget.commentId,
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        showSnackBar(msg:res, context: context, duration: 1500);
      }
      setState(() {
        anythingChanged = true;
        widget.repliesLen = widget.repliesLen+1;
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

  Future<bool> _moveBackToPreviousScreen(BuildContext context) async {
    log("$TAG _moveBackToPreviousScreen(): ");
    Navigator.pop(context, anythingChanged);
    return false;
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

    return  WillPopScope(
      onWillPop: () {
        log("$TAG onWillPop(): Back Pressed ");
        if(anythingChanged){
          getFeedPosts(context);
        }
        return _moveBackToPreviousScreen(context);
      },
      child: Scaffold(
      backgroundColor: darkMode ? cardColorDark : cardColorLight,
      appBar: AppBar(
        iconTheme: IconThemeData(color: darkMode ? Colors.white:Colors.black),
        backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight, //
        title: Text(
          'Replies',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // mainAxisSize: MainAxisSize.max,
        children: [
          // const Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          //     child: TextField(
          //       decoration: InputDecoration(
          //           hintText: "Type in here!"
          //       ),
          //     )
          // ),
          topCommentCard(darkMode, user.uid),
          const Divider(height: 1.5, color: secondaryColor,),
          Expanded(child: repliesList(darkMode, user.uid)),
        ],
      ),
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
                      hintText: 'Reply as ${user.username}',
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
                onTap: () => postReply(
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
    ),);
  }


  Widget repliesList(bool darkMode, String uid){
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(widget.commentId)
          .collection('replies').orderBy("datePublished", descending: false)
          .snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        // repliesLen = snapshot.data!.docs.length;
        // log("$TAG build(): replySnap == ${snapshot.data!.docs[0].data()}");
        // log("$TAG build(): replySnap == ${snapshot.data!.docs[1].data()}");
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (ctx, index) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
            child: ReplyCard(
              darkMode: darkMode,
              replySnap: snapshot.data!.docs[index].data(),
              postId: widget.postId,
              commentId: widget.commentId,
              userID: uid,
            ),
          ),
        );
      },
    );
  }


  Widget topCommentCard(bool darkMode, String uid) {
    log("$TAG build() darkMode = ${darkMode}");

    return Container(
      color: darkMode ? cardColorDark : cardColorLight,
      padding: const EdgeInsets.fromLTRB(12,16,2,16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              showUnsplashImage
                  ? unsplashImageURL
                  : (
                  // widget.comment != null
                  // ? widget.comment!.user!.profile!.profile
                  // :
              widget.commentSnap['profilePic']),
            ),
            radius: 18,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                      children: [
                        TextSpan(
                            // text: (widget.comment != null ? widget.comment!.user!.name : widget.commentSnap['name']),
                            text: widget.commentSnap['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        TextSpan(
                          // text: (widget.comment != null ? ' ${widget.comment!.comment}' : ' ${widget.commentSnap['text']}'),
                          text: ' ${widget.commentSnap['text']}',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      // (widget.comment != null ? "12-12-2022" : DateFormat.yMMMd().format( widget.commentSnap['datePublished'].toDate(), )),
                      (DateFormat.yMMMd().format(widget.commentSnap['datePublished'].toDate(),)),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  widget.commentSnap != null ? Row(
                    children: [
                      Padding(
                        // padding: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 2),
                        child: widget.commentSnap.containsKey("likes")
                            ? Text(
                          "${widget.commentSnap['likes'].length} Likes",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: secondaryColor,
                          ),
                        )
                            : const Text(
                          "0 Likes",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                      Padding(
                        // padding: const EdgeInsets.only(top: 4),
                        padding: EdgeInsets.fromLTRB(10, 5, 5, 2),
                        child: Text(
                          "${widget.repliesLen} Replies",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ) : Container(),

                  // (repliesLen > 0 && widget.commentSnap != null) ? Container(
                  //   alignment: Alignment.center,
                  //   // padding: const EdgeInsets.only(top: 4),
                  //   padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  //   child: GestureDetector(
                  //     onTap: (){
                  //       openRepliesScreen();
                  //     },
                  //     child: Text(
                  //       "View $repliesLen more replies",
                  //       style: const TextStyle(
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w700,
                  //         color: secondaryColor,
                  //       ),
                  //     ),
                  //   ),
                  // ) : Container(),
                ],
              ),
            ),
          ),
          // todo uncomment to add Liking a comment feature
          widget.commentSnap != null ? IconButton(
            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
            iconSize: 18,
            alignment: Alignment.topCenter,
            icon: (widget.commentSnap.containsKey("likes") && widget.commentSnap['likes'].contains(uid))
                ? const Icon(
              Icons.favorite,
              color: Colors.red,
            )
                : Icon(
              Icons.favorite_border,
              color: darkMode ? textColorDark : textColorLight,
            ),
            onPressed: () {
              likeDislikeComment(uid);

              if (!mounted) {
                log("$TAG Already unmounted i.e. Dispose called");
                return;
              }
              setState(() {});
            },
          ) : Container(),
        ],
      ),
    );
  }

  void likeDislikeComment(String uid) {
    log("$TAG likeDislikeComment() userID = ${uid}");
    log("$TAG likeDislikeComment() postID = ${widget.postId}");
    if (widget.commentSnap != null) {
      try {
        bool containsLikes = widget.commentSnap.containsKey("likes");
        // bool containsCommentId = widget.commentSnap.containsKey("commentId");
        log("$TAG likeDislikeComment() containsLikes = ${containsLikes}");
        // log("$TAG likeDislikeComment() containsCommentId = ${containsCommentId}");
        List likesList = widget.commentSnap.containsKey("likes") ? widget.commentSnap['likes'] : [];
        log("$TAG likeDislikeComment() likesList = ${likesList}");
        if (likesList == null) {
          likesList = [];
        }
        if (uid != null && widget.postId != null) {
          FireStoreMethods().likeComment(
            widget.postId,
            widget.commentSnap['commentId'],
            uid,
            likesList,
          );
          if (likesList.contains("${uid}")) {
            // if the likes list contains the user uid, we need to remove it
            // log("$TAG likeDislikeComment() : BEFORE likesList : ${likesList}");
            log("$TAG likeDislikeComment() : BEFORE widget.commentSnap['likes'] : ${widget.commentSnap['likes']}");
            // likesList.remove("${uid}");
            widget.commentSnap['likes'].remove("${uid}");
            // log("$TAG likeDislikeComment() : AFTER likesList : ${likesList}");
            log("$TAG likeDislikeComment() : AFTER widget.commentSnap['likes'] : ${widget.commentSnap['likes']}");


          } else {
            // else we need to add uid to the likes array
            // log("$TAG likeDislikeComment() : BEFORE likesList : ${likesList}");
            log("$TAG likeDislikeComment() : BEFORE widget.commentSnap['likes'] : ${widget.commentSnap['likes']}");
            // likesList.add("${uid}");
            widget.commentSnap['likes'].add("${uid}");
            // log("$TAG likeDislikeComment() : AFTER likesList : ${likesList}");
            log("$TAG likeDislikeComment() : AFTER widget.commentSnap['likes'] : ${widget.commentSnap['likes']}");


          }

          if (!mounted) {
            log("$TAG Already unmounted i.e. Dispose called");
            return;
          }
          log("$TAG likeDislikeComment() : widget.commentSnap['likes'] : ${widget.commentSnap['likes']}");
          setState(() {
          });
        }
      } catch (e) {
        log("$TAG likeDislikeComment() : Exception : ${e.toString()}");
      }
    }
  }
}