import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/models/user.dart' as userModel;
import 'package:social_app/providers/comments_provider.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/login_prefs_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:provider/provider.dart';

const String TAG = "FS - FeedCommentsScreen - ";
class FeedCommentsScreen extends StatefulWidget {
  Feed feed;
  bool gotComments;

  FeedCommentsScreen({Key? key, required this.feed, required this.gotComments}) : super(key: key);

  @override
  _FeedCommentsScreenState createState() => _FeedCommentsScreenState();
}

class _FeedCommentsScreenState extends State<FeedCommentsScreen> {
  final TextEditingController commentEditingController = TextEditingController();
  Map<String, dynamic> userDetails = {};
  bool anythingChanged = false;

  void postComment(String uid, String name) async {
    anythingChanged = true;
    FocusScope.of(context).unfocus();
    log("$TAG postComment()");
    try {
      if(commentEditingController.text.trim().isNotEmpty) {
        HTTPResponse<Map<String, dynamic>> response = await APIHelper.postComment(
            uid: uid, postID:"${widget.feed.id}", comment: commentEditingController.text);
        if(response.isSuccessful && response.data !=null){
          Map<String, dynamic> map = response.data!;
          if(map["status_code"] == "200" && map["status_message"]=="Comment Added Successfully."){
            setState(() {
              commentEditingController.text = "";
            });
            showSnackBar(msg:"Comment Added Successfully.", context: context, duration: 1500);
            // fetchCommentLen(false);
            fetchCommentLen(showLoader:false,id:"${widget.feed.id}", context:context);
          }
        }
      }else{
        showSnackBar(msg:"Cannot post empty comment", context: context, duration: 1500);
      }
      // String res = await FireStoreMethods().postComment(
      //   widget.postId,
      //   commentEditingController.text,
      //   uid,
      //   name,
      //   profilePic,
      // );
      //
      // if (res != 'success') {
      //   showSnackBar(msg:res, context: context, duration: 1500);
      // }
      // setState(() {
      //   commentEditingController.text = "";
      // });
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
  void initState() {
    super.initState();
    // fetchCommentLen(true);
    fetchCommentLen(showLoader:true,id:"${widget.feed.id}", context:context);
  }

  @override
  void dispose() {
    super.dispose();
    log("$TAG dispose()");
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

  // fetchCommentLen(bool showLoader) async {
  //   log("$TAG fetchCommentLen()");
  //   final CommentsProvider commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
  //   if (showLoader) {
  //     commentsProvider.setIsProcessing(true, notify: false);
  //   }
  //   HTTPResponse<Feed> response = await APIHelper.getPostDetails(postID:"${widget.feed.id}");
  //   if (response.isSuccessful) {
  //     // commentsProvider.setFeedsList(response.data!);
  //     commentsProvider.setFeed(response.data!);
  //   } else {
  //     log("SHOW ERROR ");
  //   }
  //   commentsProvider.setIsProcessing(false, notify: false);
  // }

  @override
  Widget build(BuildContext context) {
    // final userModel.User user = Provider.of<UserProvider>(context).getUser;
    final LoginPrefsProvider loginPrefsProvider = Provider.of<LoginPrefsProvider>(context, listen: false);
    userDetails = loginPrefsProvider.getUserDetailsMap;

    // final themeChange = Provider.of<DarkThemeProvider>(context);
    // bool darkMode = themeChange.darkTheme;
    bool darkMode = updateThemeWithSystem();
    DarkThemeProvider _darkThemeProvider = Provider.of(context);
    _darkThemeProvider.setSysDarkTheme(darkMode);
    log("$TAG build(): darkMode == ${darkMode}");

    return WillPopScope(
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
            'Comments',
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: false,
        ),
        //--------------------------------------------------------------
        body: Consumer<CommentsProvider>(
          builder: (_, provider, __) => provider.isProcessing
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : (provider.feed !=null && provider.feed!.comments != null &&  provider.feed!.comments!.length > 0)
              ? ListView.builder(
            itemBuilder: (_, index) {

              return CommentCard(
                darkMode: darkMode,
                comment:provider.feed!.comments![index],
                snap: null,
                postID: null,
                userID: userDetails["id"], buttonHandler: _passedFunction,
              );
              // return ListTile(
              //   title: Text(post.title!),
              //   subtitle: Text(
              //     post.description!,
              //     maxLines: 2,
              //     overflow: TextOverflow.ellipsis,
              //   ),
              // );
            },
            itemCount: provider.feed!.comments!.length,
          )
              : const Center(
            child: Text('No Comments posted!'),
          ),
        ),
        //--------------------------------------------------------------

        // body: StreamBuilder(
        //   stream: FirebaseFirestore.instance
        //       .collection('posts')
        //       .doc(widget.postId)
        //       .collection('comments')
        //       .snapshots(),
        //   builder: (context,
        //       AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //
        //     return ListView.builder(
        //       itemCount: snapshot.data!.docs.length,
        //       itemBuilder: (ctx, index) => CommentCard(
        //         darkMode: darkMode,
        //         snap: snapshot.data!.docs[index],
        //       ),
        //     );
        //   },
        // ),

        //--------------------------------------------------------------
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
                //todo fix profile pic issue
                // returnProfilePicWidgetIfAvailable(user!.photoUrl),
                returnProfilePicWidgetIfAvailable(unsplashImageURL),
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
                        hintText: 'Comment as ${userDetails["name"]}',
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
                    userDetails["id"],
                    userDetails["name"],
                    // user.photoUrl,
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
      ),
    );
  }
}