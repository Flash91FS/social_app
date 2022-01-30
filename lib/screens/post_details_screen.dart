import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart' as model;
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/comments_screen.dart';

// import 'package:social_app/screens/comments_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:social_app/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const String TAG = "FS - PostDetailsScreen - ";

class PostDetailsScreen extends StatefulWidget {
  final snap;
  final QuerySnapshot<Object?>? commentsSnap;

  const PostDetailsScreen({
    Key? key,
    required this.snap,
    required this.commentsSnap,
    // required QuerySnapshot<Object?>? commentsSnap,
  }) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  int commentLen = 0;
  double _cardRadius = 14.0;
  bool isLikeAnimating = false;
  final TextEditingController commentEditingController = TextEditingController();

  void postComment(String uid, String name, String profilePic) async {
    try {
      String res = await FireStoreMethods().postComment(
        widget.snap['postId'],
        commentEditingController.text,
        uid,
        name,
        profilePic,
      );

      if (res != 'success') {
        showSnackBar(msg: res, context: context, duration: 1500);
      }
      setState(() {
        commentEditingController.text = "";
      });
    } catch (err) {
      showSnackBar(msg: err.toString(), context: context, duration: 1500);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
  }

  @override
  void dispose() {
    super.dispose();
    log("$TAG dispose()");
  }

  // QuerySnapshot? commentsSnap;

  fetchCommentLen() async {
    try {
      if (widget.commentsSnap != null) {
        commentLen = widget.commentsSnap!.docs.length;
      }
      // // QuerySnapshot snap =
      // commentsSnap = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .doc(widget.snap['postId'])
      //     .collection('comments')
      //     .orderBy("datePublished", descending: true)
      //     .get();
      // commentLen = commentsSnap!.docs.length;
      // for (var i = 0; i < commentLen; i++) {
      //   QueryDocumentSnapshot docc = commentsSnap!.docs[i];
      //   // docc.data()['title'];
      //   Map<String, dynamic> dataMap = docc.data()! as Map<String, dynamic>;
      //
      //   log("$TAG fetchCommentLen(): name = ${dataMap['name']}");
      //   log("$TAG fetchCommentLen(): text = ${dataMap['text']}");
      //   log("$TAG fetchCommentLen(): datePublished = ${dataMap['datePublished']}");
      // }
    } catch (err) {
      log("$TAG fetchCommentLen(): Error ==  ${err.toString()}");
      // showSnackBar(
      //   context,
      //   err.toString(),
      // );
    }
    if (!mounted) {
      log("$TAG fetchCommentLen(): Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {});
  }

  void openCommentsScreen(String postID) {
    log("openCommentsScreen()");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CommentsScreen(
        postId: postID,
      ),
    ));
  }

  Widget getCommentsList() {
    Column someColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
    if (widget.commentsSnap != null && widget.commentsSnap!.docs.length > 0) {
      someColumn.children.add(CommentCard(
        verticalPadding: 9,
        snap: widget.commentsSnap!.docs[0],
      ));
      if (widget.commentsSnap!.docs.length > 1) {
        someColumn.children.add(CommentCard(
          verticalPadding: 9,
          snap: widget.commentsSnap!.docs[1],
        ));
      }
      someColumn.children.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
          child: InkWell(
            onTap: (){
              openCommentsScreen(widget.snap['postId'].toString());
            },
            child: const Text(
              'View all comments',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                // fontFamily: 'Roboto-Regular',
              ),
            ),
          ),
        ),
      );
      return someColumn;
    } else {
      someColumn.children.add(Container());

      return someColumn;
    }
  }


  Widget returnProfilePicWidgetIfAvailable(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(photoUrl),
        // backgroundColor: Colors.white,
      );
    } else {
      return const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
      );
    }
  }

  deletePost(String postId) async {
    // try {
    //   await FireStoreMethods().deletePost(postId);
    // } catch (err) {
    //   showSnackBar(
    //     context,
    //     err.toString(),
    //   );
    // }
  }

  model.User? user = null;

  void likeDislikePost() {
    FireStoreMethods().likePost(
      widget.snap['postId'].toString(),
      user!.uid,
      widget.snap['likes'],
    );
    if (widget.snap['likes'].contains(user!.uid)) {
      // if the likes list contains the user uid, we need to remove it
      widget.snap['likes'].remove(user!.uid);
      // _firestore.collection('posts').doc(postId).update({
      //   'likes': FieldValue.arrayRemove([uid])
      // });
    } else {
      // else we need to add uid to the likes array
      widget.snap['likes'].add(user!.uid);
      // _firestore.collection('posts').doc(postId).update({
      //   'likes': FieldValue.arrayUnion([uid])
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build()");
    try {
      // final model.User
      user = Provider.of<UserProvider>(context).getUser;
    } catch (err) {
      log("$TAG Error == ${err.toString()}");
    }
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Spot Details',
        ),
        centerTitle: false,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                Container(
                  // boundary needed for web
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: mobileBackgroundColor,
                    ),
                    color: mobileBackgroundColor,
                    // color: Colors.blue,
                  ),
                  // padding: const EdgeInsets.symmetric(
                  //   vertical: 10,
                  // ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: Container(
                    // color: Colors.grey[850],
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: mobileBackgroundColor,
                      // ),
                      // borderRadius: BorderRadius.circular(_cardRadius),
                      color: Colors.grey[850], // mobileBackgroundColor,
                      // color: Colors.blue, // mobileBackgroundColor,
                    ),
                    child: Wrap(
                      children: [
                        // HEADER SECTION OF THE POST
                        Container(
                          height: 46,
                          // color: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 10,
                          ).copyWith(right: 0),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: NetworkImage(
                                  widget.snap['profImage'].toString(),
                                ),
                              ),
                              // Container(
                              // // color: Colors.grey[900],
                              //   height: 38,
                              //   width: 38,
                              //   decoration: BoxDecoration(
                              //     color: Colors.grey[900],
                              //     borderRadius: BorderRadius.circular(19),
                              //   ),
                              //   child: FadeInImage.assetNetwork(placeholder: "assets/images/placeholder_img.png", image: "${widget.snap['postUrl']}"),
                              //
                              // ),
                              //     SizedBox(width: 10,),
                              //     CircleAvatar(
                              //       radius: 18,
                              //       backgroundImage: AssetImage(
                              //         "assets/images/default_profile_pic.png",
                              //       ),
                              //     ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        widget.snap['username'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              widget.snap['uid'].toString() == user!.uid
                                  ? IconButton(
                                      onPressed: () {
                                        log("$TAG overflow icon clicked");
                                        //todo show dialog below
                                        // showDialog(
                                        //   useRootNavigator: false,
                                        //   context: context,
                                        //   builder: (context) {
                                        //     return Dialog(
                                        //       child: ListView(
                                        //           padding: const EdgeInsets.symmetric(vertical: 16),
                                        //           shrinkWrap: true,
                                        //           children: [
                                        //             'Delete',
                                        //           ]
                                        //               .map(
                                        //                 (e) => InkWell(
                                        //                     child: Container(
                                        //                       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                        //                       child: Text(e),
                                        //                     ),
                                        //                     onTap: () {
                                        //                       deletePost(
                                        //                         widget.snap['postId'].toString(),
                                        //                       );
                                        //                       // remove the dialog box
                                        //                       Navigator.of(context).pop();
                                        //                     }),
                                        //               )
                                        //               .toList()),
                                        //     );
                                        //   },
                                        // );
                                      },
                                      icon: const Icon(Icons.more_vert),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),

// DATE SECTION OF THE POST
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // DefaultTextStyle(
                              //     style: Theme.of(context)
                              //         .textTheme
                              //         .subtitle2!
                              //         .copyWith(fontWeight: FontWeight.w800),
                              //     child: Text(
                              //       '${widget.snap['likes'].length} likes',
                              //       style: Theme.of(context).textTheme.bodyText2,
                              //     )),

                              // Container(
                              //   width: double.infinity,
                              //   padding: const EdgeInsets.only(
                              //     top: 8,
                              //   ),
                              //   child: RichText(
                              //     text: TextSpan(
                              //       style: const TextStyle(color: primaryColor),
                              //       children: [
                              //         TextSpan(
                              //           text: widget.snap['username'].toString(),
                              //           style: const TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //           ),
                              //         ),
                              //         TextSpan(
                              //           text: ' ${widget.snap['description']}',
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),

                              // InkWell(
                              //     child: Container(
                              //       child: Text(
                              //         'View all $commentLen comments',
                              //         style: const TextStyle(
                              //           fontSize: 16,
                              //           color: secondaryColor,
                              //         ),
                              //       ),
                              //       padding: const EdgeInsets.symmetric(vertical: 4),
                              //     ),
                              //     onTap: () { }
                              //   // onTap: () => Navigator.of(context).push(
                              //   //   MaterialPageRoute(
                              //   //     builder: (context) => CommentsScreen(
                              //   //       postId: widget.snap['postId'].toString(),
                              //   //     ),
                              //   //   ),
                              //   // ),
                              // ),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: secondaryColor,
                                  ),
                                ),
                                // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              ),
                            ],
                          ),
                        ),

// DESCRIPTION SECTION OF THE POST
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          // padding: const EdgeInsets.only(
                          //   top: 8,
                          // ),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: primaryColor),
                              children: [
                                // TextSpan(
                                //   text: widget.snap['username'].toString(),
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                // ),
                                TextSpan(
                                  text: ' ${widget.snap['description']}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        // IMAGE SECTION OF THE POST
                        GestureDetector(
                          onDoubleTap: () {
                            likeDislikePost();

                            if (!mounted) {
                              log("$TAG Already unmounted i.e. Dispose called");
                              return;
                            }
                            setState(() {
                              isLikeAnimating = true;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                // color: Colors.grey[900],
                                height: MediaQuery.of(context).size.height * 0.34,
                                width: double.infinity,
                                // child: Image.network(
                                //   widget.snap['postUrl'].toString(),
                                //   fit: BoxFit.cover,
                                // ),
                                // child: Image.asset("assets/images/placeholder_img.png",),
                                child: FadeInImage.assetNetwork(
                                    placeholder: "assets/images/placeholder_img.png",
                                    image: "${widget.snap['postUrl']}"),

                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: mobileBackgroundColor,
                                  // ),
                                  // borderRadius: BorderRadius.only(
                                  //   topLeft: Radius.circular(_cardRadius),
                                  //   topRight: Radius.circular(_cardRadius),
                                  // ),
                                  color: Colors.grey[900], // mobileBackgroundColor,
                                ),
                              ),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: isLikeAnimating ? 1 : 0,
                                child: LikeAnimation(
                                  isAnimating: isLikeAnimating,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 100,
                                  ),
                                  duration: const Duration(
                                    milliseconds: 400,
                                  ),
                                  onEnd: () {
                                    if (!mounted) {
                                      log("$TAG Already unmounted i.e. Dispose called");
                                      return;
                                    }
                                    setState(() {
                                      isLikeAnimating = false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // LIKE, COMMENT SECTION OF THE POST
                        Container(
                          height: 40,
                          child: Row(
                            children: <Widget>[
                              Container(
                                // color: Colors.blue,
                                height: 28,
                                width: 40,
                                child: LikeAnimation(
                                  isAnimating: widget.snap['likes'].contains(user!.uid),
                                  smallLike: true,
                                  child: IconButton(
                                    padding: const EdgeInsets.all(0.0),
                                    icon: widget.snap['likes'].contains(user!.uid)
                                        ? const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          )
                                        : const Icon(
                                            Icons.favorite_border,
                                          ),
                                    onPressed: () {
                                      likeDislikePost();

                                      if (!mounted) {
                                        log("$TAG Already unmounted i.e. Dispose called");
                                        return;
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                // color: Colors.red,
                                padding: const EdgeInsets.all(0.0),
                                // child: DefaultTextStyle(
                                //     style: Theme.of(context)
                                //         .textTheme
                                //         .subtitle2!
                                //         .copyWith(fontWeight: FontWeight.w800),
                                //     child: Text(
                                //       '${widget.snap['likes'].length} likes',
                                //       style: Theme.of(context).textTheme.bodyText2,
                                //     ),),
                                child: Text(
                                  '${widget.snap['likes'].length} likes',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.comment_outlined,
                                ),
                                padding: const EdgeInsets.all(0.0),
                                onPressed: () {
                                  log("$TAG comment icon pressed");
                                  openCommentsScreen(widget.snap['postId'].toString());
                                },
                                // onPressed: () => Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => CommentsScreen(
                                //       postId: widget.snap['postId'].toString(),
                                //     ),
                                //   ),
                                // ),
                              ),
                              InkWell(
                                  child: Container(
                                    child: Text(
                                      '$commentLen comments',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    // child: Text(
                                    //   '$commentLen comments',
                                    //   style: const TextStyle(
                                    //     fontSize: 16,
                                    //     color: secondaryColor,
                                    //   ),
                                    // ),
                                    // padding: const EdgeInsets.all(1.0),
                                    padding: const EdgeInsets.symmetric(vertical: 0),
                                  ),
                                  onTap: () {
                                    log("$TAG comment icon pressed");
                                    openCommentsScreen(widget.snap['postId'].toString());
                                  }
                                  // onTap: () => Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) => CommentsScreen(
                                  //       postId: widget.snap['postId'].toString(),
                                  //     ),
                                  //   ),
                                  // ),
                                  ),
                              // IconButton(
                              //     icon: const Icon(
                              //       Icons.send,
                              //     ),
                              //     onPressed: () {}),
                              // Expanded(
                              //     child: Align(
                              //       alignment: Alignment.bottomRight,
                              //       child: IconButton(
                              //           icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                              //     ))
                            ],
                          ),
                        ),
                        //DESCRIPTION AND NUMBER OF COMMENTS
                      ],
                    ),
                  ),
                ),
                // Container(
                //   height: 400,
                //   child: ListView.builder(
                //     itemCount: widget.commentsSnap!.docs.length,
                //     itemBuilder: (ctx, index) =>
                //         CommentCard(
                //           snap: widget.commentsSnap!.docs[index],
                //         ),
                //   ),
                // ),

                getCommentsList(),
              ],
            ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.grey[900],
          height: kToolbarHeight,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              returnProfilePicWidgetIfAvailable(user!.photoUrl),
              // CircleAvatar(
              //   backgroundImage: NetworkImage(user!.photoUrl),
              //   radius: 18,
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user!.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postComment(
                  user!.uid,
                  user!.username,
                  user!.photoUrl,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:social_app/models/user.dart' as model;
// import 'package:social_app/providers/user_provider.dart';
// import 'package:social_app/utils/colors.dart';
// import 'package:social_app/utils/global_variable.dart';
// import 'package:social_app/utils/utils.dart';
// // import 'package:social_app/widgets/like_animation.dart';
// import 'package:social_app/resources/firestore_methods.dart';
// // import 'package:social_app/screens/comments_screen.dart';
// import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
//
// class PostDetailsScreen extends StatefulWidget {
//   final snap;
//   const PostDetailsScreen({
//     Key? key,
//     required this.snap,
//   }) : super(key: key);
//
//   @override
//   State<PostDetailsScreen> createState() => _PostDetailsScreenState();
// }
//
// class _PostDetailsScreenState extends State<PostDetailsScreen> {
//   int commentLen = 0;
//   bool isLikeAnimating = false;
//
//   @override
//   void initState() {
//     super.initState();
//     //todo uncomment for number of like and comments
//     fetchCommentLen();
//   }
//
// //todo uncomment for number of like and comments
//   fetchCommentLen() async {
//     try {
//       QuerySnapshot snap = await FirebaseFirestore.instance
//           .collection('posts')
//           .doc(widget.snap['postId'])
//           .collection('comments')
//           .get();
//       commentLen = snap.docs.length;
//     } catch (err) {
//       showSnackBar(msg:err.toString(), context: context, duration: 1500);
//     }
//     setState(() {});
//   }
//
//   //todo uncomment for delete post
//   deletePost(String postId) async {
//     try {
//       await FireStoreMethods().deletePost(postId);
//     } catch (err) {
//       showSnackBar(msg:err.toString(), context: context, duration: 1500);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // final model.User user = Provider.of<UserProvider>(context).getUser;
//     final width = MediaQuery.of(context).size.width;
//
//     return Container(
//       // boundary needed for web
//       decoration: BoxDecoration(
//         border: Border.all(
//           color: mobileBackgroundColor,
//         ),
//         color: mobileBackgroundColor,
//       ),
//       padding: const EdgeInsets.symmetric(
//         vertical: 10,
//       ),
//       child: Column(
//         children: [
//           // HEADER SECTION OF THE POST
//           Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 4,
//               horizontal: 16,
//             ).copyWith(right: 0),
//             child: Row(
//               children: <Widget>[
//                 // const CircleAvatar(
//                 //   radius: 16,
//                 //   backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
//                 //   // backgroundImage: NetworkImage(
//                 //   //   // "https://i.stack.imgur.com/l60Hf.png",
//                 //   // ),
//                 // ),
//                 // todo uncomment for original profile pic from firebase
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundImage: NetworkImage(
//                     widget.snap['profImage'].toString(),
//                   ),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.only(
//                       left: 8,
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const <Widget>[
//                         // Text(
//                         //   widget.snap['username'].toString(),
//                         //   style: const TextStyle(
//                         //     fontWeight: FontWeight.bold,
//                         //   ),
//                         // ),
//                         Text(
//                           "Name",
//                           // widget.snap['username'].toString(), // todo uncomment for original name from firebase
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 IconButton(
//                   onPressed: () {
//                     showDialog(
//                       useRootNavigator: false,
//                       context: context,
//                       builder: (context) {
//                         return Dialog(
//                           child: ListView(
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 16),
//                               shrinkWrap: true,
//                               children: [
//                                 'Delete',
//                               ]
//                                   .map(
//                                     (e) => InkWell(
//                                     child: Container(
//                                       padding:
//                                       const EdgeInsets.symmetric(
//                                           vertical: 12,
//                                           horizontal: 16),
//                                       child: Text(e),
//                                     ),
//                                     onTap: () {
//                                       log("Delete Post");
//                                       //todo uncomment for delete post
//                                       // deletePost(
//                                       //   widget.snap['postId']
//                                       //       .toString(),
//                                       // );
//                                       // remove the dialog box
//                                       Navigator.of(context).pop();
//                                     }),
//                               )
//                                   .toList()),
//                         );
//                       },
//                     );
//                   },
//                   icon: const Icon(Icons.more_vert),
//                 )
//                 // widget.snap['uid'].toString() == user.uid
//                 //     ? IconButton(
//                 //   onPressed: () {
//                 //     showDialog(
//                 //       useRootNavigator: false,
//                 //       context: context,
//                 //       builder: (context) {
//                 //         return Dialog(
//                 //           child: ListView(
//                 //               padding: const EdgeInsets.symmetric(
//                 //                   vertical: 16),
//                 //               shrinkWrap: true,
//                 //               children: [
//                 //                 'Delete',
//                 //               ]
//                 //                   .map(
//                 //                     (e) => InkWell(
//                 //                     child: Container(
//                 //                       padding:
//                 //                       const EdgeInsets.symmetric(
//                 //                           vertical: 12,
//                 //                           horizontal: 16),
//                 //                       child: Text(e),
//                 //                     ),
//                 //                     onTap: () {
//                 //                       log("Delete Post");
//                 //                       //todo uncomment for delete post
//                 //                       // deletePost(
//                 //                       //   widget.snap['postId']
//                 //                       //       .toString(),
//                 //                       // );
//                 //                       // remove the dialog box
//                 //                       Navigator.of(context).pop();
//                 //                     }),
//                 //               )
//                 //                   .toList()),
//                 //         );
//                 //       },
//                 //     );
//                 //   },
//                 //   icon: const Icon(Icons.more_vert),
//                 // )
//                 //     : Container(),
//               ],
//             ),
//           ),
//           // IMAGE SECTION OF THE POST
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.35,
//             width: double.infinity,
//             child: Image.asset(
//               "assets/images/default_profile_pic.png",
//               // widget.snap['postUrl'].toString(),
//               fit: BoxFit.cover,
//             ),
//             // child: Image.network(
//             //   "https://i.stack.imgur.com/l60Hf.png",
//             //   // widget.snap['postUrl'].toString(),
//             //   fit: BoxFit.cover,
//             // ),
//           ),
//           //todo uncomment below code for double tap like animation and commemnt above pic code
//           // GestureDetector(
//           //   onDoubleTap: () {
//           //     FireStoreMethods().likePost(
//           //       widget.snap['postId'].toString(),
//           //       user.uid,
//           //       widget.snap['likes'],
//           //     );
//           //     setState(() {
//           //       isLikeAnimating = true;
//           //     });
//           //   },
//           //   child: Stack(
//           //     alignment: Alignment.center,
//           //     children: [
//           //       SizedBox(
//           //         height: MediaQuery.of(context).size.height * 0.35,
//           //         width: double.infinity,
//           //         child: Image.network(
//           //           widget.snap['postUrl'].toString(),
//           //           fit: BoxFit.cover,
//           //         ),
//           //       ),
//           //       AnimatedOpacity(
//           //         duration: const Duration(milliseconds: 200),
//           //         opacity: isLikeAnimating ? 1 : 0,
//           //         child: LikeAnimation(
//           //           isAnimating: isLikeAnimating,
//           //           child: const Icon(
//           //             Icons.favorite,
//           //             color: Colors.white,
//           //             size: 100,
//           //           ),
//           //           duration: const Duration(
//           //             milliseconds: 400,
//           //           ),
//           //           onEnd: () {
//           //             setState(() {
//           //               isLikeAnimating = false;
//           //             });
//           //           },
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // LIKE, COMMENT SECTION OF THE POST
//           Row(
//             children: <Widget>[
//               IconButton(
//                 icon: const Icon(
//                   Icons.favorite_border,
//                 ),
//                 onPressed: () {
//                   showSnackBar(context: context, msg: "Show like animation");
//                 }
//
//               ),
//               // todo uncomment for like animation and comment above code  of IconButton
//               // LikeAnimation(
//               //   isAnimating: widget.snap['likes'].contains(user.uid),
//               //   smallLike: true,
//               //   child: IconButton(
//               //     icon: widget.snap['likes'].contains(user.uid)
//               //         ? const Icon(
//               //       Icons.favorite,
//               //       color: Colors.red,
//               //     )
//               //         : const Icon(
//               //       Icons.favorite_border,
//               //     ),
//               //     onPressed: () => FireStoreMethods().likePost(
//               //       widget.snap['postId'].toString(),
//               //       user.uid,
//               //       widget.snap['likes'],
//               //     ),
//               //   ),
//               // ),
//               IconButton(
//                 icon: const Icon(
//                   Icons.comment_outlined,
//                 ),
//                 onPressed: (){
//                   showSnackBar(context: context, msg: "Show comment screen");
//                 }
//                 // => Navigator.of(context).push(
//                 //   MaterialPageRoute(
//                 //     builder: (context) => CommentsScreen(
//                 //       postId: widget.snap['postId'].toString(),
//                 //     ),
//                 //   ),
//                 // ),
//               ),
//               IconButton(
//                   icon: const Icon(
//                     Icons.send,
//                   ),
//                   onPressed: () {
//                     showSnackBar(context: context, msg: "Send Option");
//                   }),
//               Expanded(
//                   child: Align(
//                     alignment: Alignment.bottomRight,
//                     child: IconButton(
//                         icon: const Icon(Icons.bookmark_border), onPressed: () {}),
//                   ))
//             ],
//           ),
//           //DESCRIPTION AND NUMBER OF COMMENTS
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 DefaultTextStyle(
//                     style: Theme.of(context)
//                         .textTheme
//                         .subtitle2!
//                         .copyWith(fontWeight: FontWeight.w800),
//                     child: Text(
//                       '69 likes',
//                       // '${widget.snap['likes'].length} likes',
//                       style: Theme.of(context).textTheme.bodyText2,
//                     )),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(
//                     top: 8,
//                   ),
//                   child: RichText(
//                     text: TextSpan(
//                       style: const TextStyle(color: primaryColor),
//                       children: [
//                         TextSpan(
//                           text: "Faiz",
//                           // text: widget.snap['username'].toString(),
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         TextSpan(
//                           text: ' description',
//                           // text: ' ${widget.snap['description']}',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 InkWell(
//                   child: Container(
//                     child: Text(
//                       'View all $commentLen comments',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: secondaryColor,
//                       ),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 4),
//                   ),
//                   onTap: (){
//                     showSnackBar(context: context, msg: "Show comment screen");
//                   }
//                   // => Navigator.of(context).push(
//                   //   MaterialPageRoute(
//                   //     builder: (context) => CommentsScreen(
//                   //       postId: widget.snap['postId'].toString(),
//                   //     ),
//                   //   ),
//                   // ),
//                 ),
//                 Container(
//                   child: const Text("11-08-2012",
//                     //todo uncomment for date
//                     // DateFormat.yMMMd()
//                     //     .format(widget.snap['datePublished'].toDate()),
//                     style: TextStyle(
//                       color: secondaryColor,
//                     ),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
