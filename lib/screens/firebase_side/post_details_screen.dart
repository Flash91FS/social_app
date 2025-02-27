import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:social_app/models/user.dart' as model;
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/firebase_side/comments_screen.dart';

// import 'package:social_app/screens/comments_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:social_app/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
// import 'package:geocoding/geocoding.dart';

import '../../main.dart';
import 'map_screen.dart';

const String TAG = "FS - PostDetailsScreen - ";

class PostDetailsScreen extends StatefulWidget {
  final snap;
  final String multiImages;
  QuerySnapshot<Object?>? commentsSnap;

  PostDetailsScreen({
    Key? key,
    required this.snap,
    required this.commentsSnap,
    this.multiImages = "0",
  }) : super(key: key);

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  int commentLen = 0;
  String postAddress = "";
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
    log("$TAG initState()");
    getLocAddress();
    fetchCommentLen();
  }

  @override
  void dispose() {
    super.dispose();
    log("$TAG dispose()");
  }

  getLocAddress() async {
    log("$TAG getLocAddress() Lat = ${widget.snap['lat']}");
    log("$TAG getLocAddress() Lng = ${widget.snap['lng']}");
    double lat = 0.0;
    double lng = 0.0;
    try {
      lat = double.parse(widget.snap['lat'].toString());
      lng = double.parse(widget.snap['lng'].toString());
    } catch (e, s) {
      log("$TAG getLocAddress(): ERROR 1 == ${e.toString()}");
    }
    try {
      if (lat != 0.0 && lng != 0.0) {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          var pm = placemarks.first;
          log("$TAG getLocAddress() administrativeArea = ${pm.administrativeArea}"); //3
          log("$TAG getLocAddress() country = ${pm.country}"); //4
          log("$TAG getLocAddress() locality = ${pm.locality}"); //2
          log("$TAG getLocAddress() name = ${pm.name}"); //1
          log("$TAG getLocAddress() postalCode = ${pm.postalCode}"); //5
          log("$TAG getLocAddress() street = ${pm.street}");
          log("$TAG getLocAddress() subLocality = ${pm.subLocality}");
          log("$TAG getLocAddress() subThoroughfare = ${pm.subThoroughfare}");
          log("$TAG getLocAddress() thoroughfare = ${pm.thoroughfare}");
          String address = "";
          if (pm.name != null && pm.name!.isNotEmpty) {
            address = address + pm.name!;
          }
          if (pm.locality != null && pm.locality!.isNotEmpty) {
            address = address + ", " + pm.locality!;
          }
          if (pm.administrativeArea != null && pm.administrativeArea!.isNotEmpty) {
            address = address + ", " + pm.administrativeArea!;
          }
          if (pm.country != null && pm.country!.isNotEmpty) {
            address = address + ", " + pm.country!;
          }
          if (pm.postalCode != null && pm.postalCode!.isNotEmpty) {
            address = address + ", " + pm.postalCode!;
          }
          log("$TAG getLocAddress() address = $address");
          postAddress = address;
        }
      }
    } catch (e, s) {
      log("$TAG getLocAddress(): ERROR 2 == ${e.toString()}");
    }
    if (mounted) {
      setState(() {});
    } else {
      log("$TAG getLocAddress(): Already unmounted i.e. Dispose called");
    }
  }

  // QuerySnapshot? commentsSnap;

  fetchCommentLen() async {
    log("$TAG fetchCommentLen()");
    try {
      if (widget.commentsSnap != null) {
        commentLen = widget.commentsSnap!.docs.length;
      } else {
        widget.commentsSnap = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy("datePublished", descending: true)
            .get();
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
    log("$TAG openCommentsScreen()");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CommentsScreen(
        postId: postID,
      ),
    ));
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

  Widget getCommentsList(bool darkMode) {
    log("$TAG getCommentsList(): darkMode = $darkMode");
    Column someColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
    if (widget.commentsSnap != null && widget.commentsSnap!.docs.length > 0) {
      someColumn.children.add(CommentCard(
        darkMode: darkMode,
        verticalPadding: 9,
        snap: widget.commentsSnap!.docs[0],
        postID: widget.snap['postId'],
        userID: user!.uid,
        buttonHandler: _passedFunction,
      ));
      if (widget.commentsSnap!.docs.length > 1) {
        someColumn.children.add(CommentCard(
          darkMode: darkMode,
          verticalPadding: 9,
          snap: widget.commentsSnap!.docs[1],
          postID: widget.snap['postId'],
          userID: user!.uid,
          buttonHandler: _passedFunction,
        ));
      }
      someColumn.children.add(
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
          child: InkWell(
            onTap: () {
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

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
      showSnackBar(context: context, msg: "Post Deleted", duration: 2000);
      Navigator.pop(context);
    } catch (err) {
      showSnackBar(context: context, msg: err.toString(), duration: 2000);
    }
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
    bool darkMode = false;
    try {
      // final model.User
      user = Provider.of<UserProvider>(context).getUser;
      // final themeChange = Provider.of<DarkThemeProvider>(context);
      // darkMode = themeChange.darkTheme;

      darkMode = updateThemeWithSystem();
      DarkThemeProvider _darkThemeProvider = Provider.of(context);
      _darkThemeProvider.setSysDarkTheme(darkMode);
      log("$TAG build(): darkMode == $darkMode");
    } catch (err) {
      log("$TAG Error == ${err.toString()}");
    }
    // final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: darkMode ? cardColorDark : cardColorLight,
      appBar: AppBar(
        iconTheme: IconThemeData(color: darkMode ? Colors.white : Colors.black),
        backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight, //
        title: Text(
          'Spot Details',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
          ),
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
                  color: darkMode ? dividerColorDark : dividerColorLight, //Colors.blue,
                  // boundary needed for web
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: mobileBackgroundColor,
                  //   ),
                  //   color: mobileBackgroundColor,
                  //   // color: Colors.blue,
                  // ),
                  // padding: const EdgeInsets.symmetric(
                  //   vertical: 10,
                  // ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 1.5),
                  child: Container(
                    // color: Colors.grey[850],
                    decoration: BoxDecoration(
                      // border: Border.all(
                      //   color: mobileBackgroundColor,
                      // ),
                      // borderRadius: BorderRadius.circular(_cardRadius),
                      color: darkMode ? cardColorDark : cardColorLight, // mobileBackgroundColor,
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
                              returnProfilePicWidgetIfAvailable(widget.snap['profImage'].toString()),
                              // CircleAvatar(
                              //   radius: 16,
                              //   backgroundImage: NetworkImage(
                              //     showUnsplashImage ? unsplashImageURL : widget.snap['profImage'].toString(),
                              //   ),
                              // ),
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: darkMode ? textColorDark : textColorLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              //Overflow icon
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
                                                              padding: const EdgeInsets.symmetric(
                                                                  vertical: 12, horizontal: 16),
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      postAddress,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: darkMode ? textColorDark : textColorLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

// DESCRIPTION SECTION OF THE POST
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                // padding: const EdgeInsets.only(
                                //   top: 8,
                                // ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: darkMode ? textColorDark : textColorLight,
                                    ),
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
                              GestureDetector(
                                onTap: (){
                                  log("$TAG getLocAddress(): See on Map clicked();");
                                  double lat = 0.0;
                                  double lng = 0.0;
                                  try {
                                    lat = double.parse(widget.snap['lat'].toString());
                                    lng = double.parse(widget.snap['lng'].toString());
                                  } catch (e, s) {
                                    log("$TAG getLocAddress(): ERROR 1 == ${e.toString()}");
                                  }
                                  showPostOnMap(darkMode, lat, lng);
                                },
                                child: Container(
                                  // color: Colors.pink,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  width: 90,
                                  child: const Text(
                                    "See on Map",
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,//darkMode ? textColorDark : textColorLight,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                height: postHeight, //MediaQuery.of(context).size.height * 0.4,
                                width: double.infinity,
                                // child: Image.network(
                                //   widget.snap['postUrl'].toString(),
                                //   fit: BoxFit.cover,
                                // ),
                                // child: Image.asset("assets/images/placeholder_img.png",),
                                child: widget.multiImages == "1"
                                    ? getCarouselSliderOld()
                                    : FadeInImage.assetNetwork(
                                        fit: coverFit ? BoxFit.cover : BoxFit.contain,
                                        placeholder: "assets/images/placeholder_img.png",
                                        image: showUnsplashImage ? unsplashImageURL : "${widget.snap['postUrl']}"),

                                decoration: BoxDecoration(
                                  // border: Border.all(
                                  //   color: mobileBackgroundColor,
                                  // ),
                                  // borderRadius: BorderRadius.only(
                                  //   topLeft: Radius.circular(_cardRadius),
                                  //   topRight: Radius.circular(_cardRadius),
                                  // ),
                                  color: darkMode ? Colors.grey[900] : Colors.grey[200], // mobileBackgroundColor,
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
                                        : Icon(
                                            Icons.favorite_border,
                                            color: darkMode ? textColorDark : textColorLight,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkMode ? textColorDark : textColorLight,
                                  ),
                                ),
                              ),

                              IconButton(
                                icon: Icon(
                                  Icons.comment_outlined,
                                  color: darkMode ? textColorDark : textColorLight,
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: darkMode ? textColorDark : textColorLight,
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

                getCommentsList(darkMode),
              ],
            ),
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          color: darkMode ? Colors.grey[900] : Colors.grey[200],
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

  LinearGradient storyGradient = const LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black45]);

  // final CarouselController _controller = CarouselController();
  int _current = 0;
  List imageList = ["a1", "a2", "a3", "a4", "a5"];
  Map imagesMap = ["a1", "a2", "a3", "a4", "a5"].asMap();

  Widget getCarouselSliderOld() {
    try {
      if (widget.snap.containsKey("imagesList")) {
        List imgList = widget.snap["imagesList"] ?? [];
        if (imgList != null && imgList.length > 0) {
          imageList = imgList;
          imagesMap = imageList.asMap();
        }
      }
    } catch (e, s) {
      log("$TAG getCarouselSliderOld(): ERROR == $e");
    }

    log("$TAG getCarouselSliderOld(): postId == ${widget.snap['postId']}");
    log("$TAG getCarouselSliderOld(): imageList == $imageList");
    log("$TAG getCarouselSliderOld(): imagesMap == $imagesMap");

    return CarouselSlider(
      // carouselController: _controller,
      options: CarouselOptions(
        height: 300.0,
        viewportFraction: 1.0,
        initialPage: 0,
        pageViewKey: PageStorageKey<String>('carousel_key-${widget.snap['postId']}'),
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          _current = index;
          log("_current = $_current");
          log("reason = ${reason.toString()}");
          // setState(() {
          //   _current = index;
          // });
        },
      ),
      items: imagesMap.entries.map((mapEntry) {
        log("mapEntry = $mapEntry");
        log("value = ${mapEntry.value}");
        return Builder(
          builder: (BuildContext context) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 1.0),
                  // decoration: BoxDecoration(
                  //     color: Colors.green
                  // ),
                  child: CachedNetworkImage(
                    imageUrl: widget.multiImages == "1"
                        ? "${mapEntry.value}"
                        : "https://images.unsplash.com/photo-1532264523420-881a47db012d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9%27",
                    // imageUrl: "http://via.placeholder.com/350x150",
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: coverFit ? BoxFit.cover : BoxFit.contain,
                          // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                        ),
                      ),
                    ),
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                    // placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  //Text('text $i', style: TextStyle(fontSize: 16.0),)
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: BoxDecoration(
                      gradient: storyGradient,
                    ),
                    // child: CachedNetworkImage(
                    //   imageUrl: "http://via.placeholder.com/350x150",
                    //   imageBuilder: (context, imageProvider) => Container(
                    //     decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //           image: imageProvider,
                    //           fit: coverFit ? BoxFit.cover : BoxFit.contain,
                    //           // colorFilter: ColorFilter.mode(Colors.red, BlendMode.colorBurn),
                    //       ),
                    //     ),
                    //   ),
                    //   placeholder: (context, url) => CircularProgressIndicator(),
                    //   errorWidget: (context, url, error) => Icon(Icons.error),
                    // ),
                    //Text('text $i', style: TextStyle(fontSize: 16.0),)
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imagesMap.entries.map((entry) {
                      log("entry = $entry");
                      log("img key = ${mapEntry.key}");
                      return Container(
                        width: 12.0,
                        height: 12.0,
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(mapEntry.key == entry.key ? 0.9 : 0.4),
                          // color: (Theme.of(context).brightness == Brightness.dark
                          //     ? Colors.white
                          //     : Colors.black)
                          //     .withOpacity(mapEntry.key == entry.key ? 0.9 : 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }

  void showPostOnMap(bool darkMode, double lat, double lng) {
    log("showPostOnMap()");

    CameraPosition _postLocation = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.4746,
    );
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MapScreen(key: const PageStorageKey<String>('MapScreen'), darkMode: darkMode, forPostDetails: true, postLocation: _postLocation),
        ),);

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
