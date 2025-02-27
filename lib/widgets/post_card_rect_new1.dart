import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart' as model;
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/firebase_side/comments_screen.dart';
import 'package:social_app/screens/firebase_side/post_details_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/screens/profile_screen_new1.dart';

// import 'package:social_app/screens/comments_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';

const String TAG = "FS - PostCardRectNew1 - ";

class PostCardRectNew1 extends StatefulWidget {
  final snap;
  final darkMode;

  const PostCardRectNew1({
    Key? key,
    required this.snap, required bool this.darkMode,
  }) : super(key: key);

  @override
  State<PostCardRectNew1> createState() => _PostCardRectNew1State();
}

class _PostCardRectNew1State extends State<PostCardRectNew1> {
  int commentLen = 0;
  double _cardRadius = 14.0;
  bool isLikeAnimating = false;
  model.User? user = null;

  @override
  void initState() {
    super.initState();
    log("$TAG initState()");
    fetchCommentLen();
  }

  @override
  void dispose() {
    super.dispose();
    log("$TAG dispose()");
  }

  QuerySnapshot? commentsSnap;
  fetchCommentLen() async {
    log("$TAG fetchCommentLen()");
    try {
      // QuerySnapshot snap =
      commentsSnap = await FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId'])
          .collection('comments').orderBy("datePublished", descending: true).get();
      commentLen = commentsSnap!.docs.length;
    } catch (err) {
      // showSnackBar(
      //   context,
      //   err.toString(),
      // );
    }
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
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

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
      showSnackBar(context: context, msg: "Post Deleted", duration: 2000);
    } catch (err) {
      showSnackBar(context: context, msg: err.toString(), duration: 2000);
    }
  }

  void openSpotDetailsScreen(snap) {
    log("openSpotDetailsScreen()");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PostDetailsScreen(
        snap: snap,
        commentsSnap: commentsSnap,
      ),
    ));
  }

  void openUserProfileScreen(String uid) {
    log("openUserProfileScreen()");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          ProfileScreenNew1(
            darkMode: widget.darkMode,
            uid: uid,
            showBackButton: true,
          ),
    ));
  }
  String getAssetPathFor(String s) {
    return "assets/map_icons/${s}_96.png";
  }

  Widget getImageForCategory(String categoryID) {
    log("$TAG getImageForCategory(): ");
    String assetPath = 'assets/map_icons/ic_general_96.png';
    switch (categoryID) {
      case "1":
        assetPath = getAssetPathFor("ic_atm");
        break;
      case "2":
        assetPath = getAssetPathFor("ic_brawl");
        break;
      case "3":
        assetPath = getAssetPathFor("ic_doctor");
        break;
      case "4":
        assetPath = getAssetPathFor("ic_fire");
        break;
      case "5":
        assetPath = getAssetPathFor("ic_hospital");
        break;
      case "6":
        assetPath = getAssetPathFor("ic_info");
        break;
      case "7":
        assetPath = getAssetPathFor("ic_job");
        break;
      case "8":
        assetPath = getAssetPathFor("ic_party");
        break;
      case "9":
        assetPath = getAssetPathFor("ic_pharmacy");
        break;
      case "10":
        assetPath = getAssetPathFor("ic_theft");
        break;
      case "11":
        assetPath = getAssetPathFor("ic_police");
        break;
      case "12":
        assetPath = getAssetPathFor("ic_car_accident");
        break;
      case "13":
        assetPath = getAssetPathFor("ic_general");
        break;
      case "14":
        assetPath = getAssetPathFor("ic_find_number_plate");
        break;
      case "15":
        assetPath = getAssetPathFor("ic_speed_detector");
        break;
      case "16":
        assetPath = getAssetPathFor("ic_find_atm");
        break;
      case "17":
        assetPath = getAssetPathFor("ic_find_doctor");
        break;
      case "18":
        assetPath = getAssetPathFor("ic_find_hospital");
        break;
      case "19":
        assetPath = getAssetPathFor("ic_find_party");
        break;
      case "20":
        assetPath = getAssetPathFor("ic_find_hair_stylist");
        break;
      case "21":
        assetPath = getAssetPathFor("ic_find_health_expert");
        break;
      case "22":
        assetPath = getAssetPathFor("ic_find_pharmacy");
        break;
      case "23":
        assetPath = getAssetPathFor("ic_find_gym");
        break;
      case "24":
        assetPath = getAssetPathFor("ic_find_restaurant");
        break;
      case "25":
        assetPath = getAssetPathFor("ic_find_tattooist");
        break;
      case "26":
        assetPath = getAssetPathFor("ic_find_woman");
        break;
      case "27":
        assetPath = getAssetPathFor("ic_find_man");
        break;
      case "28":
        assetPath = getAssetPathFor("ic_find_car");
        break;
      case "29":
        assetPath = getAssetPathFor("ic_find_something");
        break;

      default:
        assetPath = getAssetPathFor("ic_general");
        break;
    }

    return Image(
        height: 44,
        width: 44,
        image: AssetImage(assetPath));
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build()");
    log("$TAG build() : postUrl = ${widget.snap['postUrl']}");
    log("$TAG build() : username = ${widget.snap['username']}");
    log("$TAG build() : profImage = ${widget.snap['profImage']}");
    try {
      // final model.User
      user = Provider.of<UserProvider>(context).getUser;
    } catch (err) {
      log("$TAG Error == ${err.toString()}");
    }
    final width = MediaQuery.of(context).size.width;

    if (user == null) {
      return Container();
      // return const Center(child: CircularProgressIndicator());
    } else {
      return GestureDetector(
        onTap: () {
          log("$TAG Full section Clicked");
          openSpotDetailsScreen(widget.snap);
        },
        onDoubleTap: () {
          log("$TAG Full section onDoubleTap");
        },
        child: Container(
          // boundary needed for web
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.darkMode ? mobileBackgroundColor : mobileBackgroundColorLight2,
            ),
            color: widget.darkMode ? mobileBackgroundColor : mobileBackgroundColorLight2,
          ),
          // padding: const EdgeInsets.symmetric(
          //   vertical: 10,
          // ),
          // padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          padding: const EdgeInsets.all(2),
          // color: cardColorDark,
          child: Container(
            // color: cardColorDark,

            decoration: BoxDecoration( // to apply shadows to the card
              // boxShadow: const [
              //   BoxShadow(
              //     color: darkCardShadowColor,
              //     offset: Offset(0.0, 1.0), //(x,y)
              //     blurRadius: 4.0,
              //   ),
              // ],
              // border: Border.all(
              //   color: mobileBackgroundColorLight,
              // ),
              // borderRadius: BorderRadius.circular(_cardRadius),
              color: widget.darkMode ? cardColorDark : cardColorLight, // mobileBackgroundColorLight,
            ),
            child: Column(
              children: [
                // HEADER SECTION OF THE POST
                Container(
                  // height: 46,
                  // color: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ).copyWith(right: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () {
                            log("$TAG profImage pressed");
                            log("$TAG uid: ${widget.snap['uid']}");
                            log("$TAG username: ${widget.snap['username']}");
                            openUserProfileScreen(widget.snap['uid']);
                          },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              showUnsplashImage ? unsplashImageURL : widget.snap['profImage'].toString(),
                            ),
                          ),
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
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: InkWell(
                                  onTap: () {
                                    log("$TAG Username pressed");
                                    log("$TAG uid: ${widget.snap['uid']}");
                                    log("$TAG username: ${widget.snap['username']}");
                                    openUserProfileScreen(widget.snap['uid']);
                                  },
                                  child: Text(
                                    widget.snap['username'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: widget.darkMode ? textColorDark : textColorLight,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(0,5,8,6),
                                // padding: const EdgeInsets.only(
                                //   top: 8,
                                // ),
                                child: Text('${widget.snap['description']}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: widget.darkMode ? textColorDark : textColorLight),),
                                // child: RichText(
                                //   text: TextSpan(
                                //     style: TextStyle(color: widget.darkMode ? textColorDark : textColorLight),
                                //     children: [
                                //       // TextSpan(
                                //       //   text: widget.snap['username'].toString(),
                                //       //   style: const TextStyle(
                                //       //     fontWeight: FontWeight.bold,
                                //       //   ),
                                //       // ),
                                //       TextSpan(
                                //         text: '${widget.snap['description']}',
                                //       ),
                                //     ],
                                //   ),
                                // ),
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
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                deletePost(
                                                  widget.snap['postId'].toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.more_vert,
                          color: widget.darkMode ? textColorDark : textColorLight,
                        ),
                      )
                          : Container(),
                    ],
                  ),
                ),

                // IMAGE SECTION OF THE POST
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5,0,2,0),
                      child: getImageForCategory("${widget.snap['categoryID']}"),
                    ),
                // Image(
                //     height: 44,
                //     width: 44,
                //     image: AssetImage('assets/map_icons/ic_general_96.png')),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,5,0),
                        child: GestureDetector(
                          // onTap: (){
                          //   log("$TAG Image Clicked");
                          // },
                          onDoubleTap: () {
                            log("$TAG Image DoubleTap");
                            FireStoreMethods().likePost(
                              widget.snap['postId'].toString(),
                              user!.uid,
                              widget.snap['likes'],
                            );
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
                                height: postHeight, //MediaQuery.of(context).size.height * 0.36,
                                width: double.infinity,
                                // child: Image.network(
                                //   widget.snap['postUrl'].toString(),
                                //   fit: BoxFit.cover,
                                // ),
                                // child: Image.asset("assets/images/placeholder_img.png",),

                                child: ClipRRect( // using ClipRRect as Image's parent (and Container's child) coz Container's decoration doesn't apply on front Image
                                  // borderRadius: BorderRadius.only(
                                  //   topLeft: Radius.circular(_cardRadius),
                                  //   topRight: Radius.circular(_cardRadius),
                                  // ),
                                  child: FadeInImage.assetNetwork(
                                      fit: coverFit ? BoxFit.cover : BoxFit.contain,
                                      placeholder: "assets/images/placeholder_img.png",
                                      image: showUnsplashImage ? unsplashImageURL : "${widget.snap['postUrl']}"),
                                ),
                                //todo uncomment to see actual pic
                                // child: FadeInImage.assetNetwork(
                                //     fit:coverFit ? BoxFit.cover : BoxFit.contain,
                                //     placeholder: "assets/images/placeholder_img.png", image: "${widget.snap['postUrl']}"),

                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: mobileBackgroundColor,
                                  // ),
                                  // borderRadius: BorderRadius.only(
                                  //   topLeft: Radius.circular(_cardRadius),
                                  //   topRight: Radius.circular(_cardRadius),
                                  // ),
                                  color: widget.darkMode ? Colors.grey[900] : Colors.grey[200], // mobileBackgroundColor,
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
                      ),
                    ),
                  ],
                ),

                // DESC, LIKE, COMMENT SECTION OF THE POST
                // Container(
                //   width: double.infinity,
                //   padding: const EdgeInsets.fromLTRB(18,0,8,0),
                //   // padding: const EdgeInsets.only(
                //   //   top: 8,
                //   // ),
                //   child: RichText(
                //     text: TextSpan(
                //       style: TextStyle(color: widget.darkMode ? textColorDark : textColorLight),
                //       children: [
                //         // TextSpan(
                //         //   text: widget.snap['username'].toString(),
                //         //   style: const TextStyle(
                //         //     fontWeight: FontWeight.bold,
                //         //   ),
                //         // ),
                //         TextSpan(
                //           text: ' ${widget.snap['description']}',
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.fromLTRB(40,5,5,0),
                  height: 30,
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
                                : Icon(
                              Icons.favorite_border,color: widget.darkMode ? Colors.white : textColorLight,// Colors.black,
                            ),
                            onPressed: () => FireStoreMethods().likePost(
                              widget.snap['postId'].toString(),
                              user!.uid,
                              widget.snap['likes'],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                          child: Container(
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
                              style: TextStyle(fontWeight: FontWeight.bold,
                                  color: widget.darkMode ? textColorDark : textColorLight),
                            ),
                          ),
                          onTap: () {
                            log("$TAG Likes pressed");
                          }),

                      IconButton(
                        icon: Icon(
                          Icons.comment_outlined,
                          color: widget.darkMode ? textColorDark : textColorLight,
                        ),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          log("$TAG comment icon pressed");
                          openCommentsScreen(widget.snap['postId'].toString());
                        },
                      ),
                      InkWell(
                          child: Container(
                            child: Text(
                              '$commentLen comments',
                              style: TextStyle(fontWeight: FontWeight.bold,
                                color: widget.darkMode ? textColorDark : textColorLight,
                              ),
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
                            log("$TAG comment text pressed");
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
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: widget.darkMode ? textColorDark : textColorLight,
                        ),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          log("$TAG send icon pressed");
                          // openCommentsScreen(widget.snap['postId'].toString());
                        },
                      ),
                      InkWell(
                          child: Container(
                            child: Text(
                              'Share',
                              style: TextStyle(fontWeight: FontWeight.bold,
                                color: widget.darkMode ? textColorDark : textColorLight,
                              ),
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
                            log("$TAG comment text pressed");
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
                      //     )),

                      // Flexible(
                      //   child: Container(),
                      //   flex: 1,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(12,0,12,0),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       log("$TAG share pressed");
                      //
                      //     },
                      //     child: ImageIcon(
                      //       const AssetImage('assets/images/send_48.png'),
                      //       size: 26,
                      //       // color: (darkMode ? iconColorLight : iconColorDark) ,//Colors.white,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),


                      // IconButton(
                      //   icon: const Icon(
                      //     Icons.share,
                      //   ),
                      //   padding: const EdgeInsets.all(0.0),
                      //   onPressed: () {
                      //     log("$TAG share pressed");
                      //
                      //   },
                      // ),
                    ],
                  ),
                ),
                //DESCRIPTION AND NUMBER OF COMMENTS
                Container(
                  padding: const EdgeInsets.fromLTRB(46,5,5,0),
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
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
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
// class PostCardRectNew1 extends StatefulWidget {
//   final snap;
//   const PostCardRectNew1({
//     Key? key,
//     required this.snap,
//   }) : super(key: key);
//
//   @override
//   State<PostCardRectNew1> createState() => _PostCardRectNew1State();
// }
//
// class _PostCardRectNew1State extends State<PostCardRectNew1> {
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
