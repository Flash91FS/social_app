import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/models/likes.dart';
import 'package:social_app/providers/login_prefs_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/profile_screen_new1.dart';
import 'package:social_app/screens/server_side/feed_comments_screen.dart';
import 'package:social_app/screens/server_side/feed_details_screen.dart';
import 'package:social_app/screens/server_side/feed_video_details_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:video_player/video_player.dart';
// import 'package:social_app/models/user.dart' as model;
import 'package:social_app/models/feed.dart' as model;
import 'package:social_app/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';

const String TAG = "FS - FeedVideoCard4 - ";

class FeedVideoCard4 extends StatefulWidget {
  // final snap;
  final darkMode;
  final bool play;
  final model.Feed feed;

  const FeedVideoCard4({
    Key? key,
    // required this.snap,
    required this.feed,
    required bool this.darkMode,
    required this.play,
  }) : super(key: key);

  @override
  State<FeedVideoCard4> createState() => _FeedVideoCard4State();
}

class _FeedVideoCard4State extends State<FeedVideoCard4> {
  late VideoPlayerController _videoPlayerController1;
  late Future<void> _initializeVideoPlayerFuture;

  // ChewieController? _chewieController;

  // List<String> srcs = [
  //   "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
  //   "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4",
  //       "http://docs.evostream.com/sample_content/assets/bunny.mp4",
  //   "http://docs.evostream.com/sample_content/assets/bun33s.mp4"
  //       "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
  // ];
  int currPlayIndex = 0;
  // model.User? user = null;
  Map<String, dynamic> userDetails = {};
  bool likedByUser = false;
  int likesCount = 0;
  // int commentLen = 0;
  //
  // QuerySnapshot? commentsSnap;
  //
  // fetchCommentLen() async {
  //   try {
  //     // QuerySnapshot snap =
  //     commentsSnap = await FirebaseFirestore.instance
  //         .collection('posts')
  //         .doc(widget.snap['postId'])
  //         .collection('comments')
  //         .orderBy("datePublished", descending: true)
  //         .get();
  //     commentLen = commentsSnap!.docs.length;
  //   } catch (err) {
  //     // showSnackBar(
  //     //   context,
  //     //   err.toString(),
  //     // );
  //   }
  //   if (!mounted) {
  //     log("$TAG Already unmounted i.e. Dispose called");
  //     return;
  //   }
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    log("$TAG initState()");
    initializePlayer();
    final LoginPrefsProvider loginPrefsProvider = Provider.of<LoginPrefsProvider>(context, listen: false);
    userDetails = loginPrefsProvider.getUserDetailsMap;
    likedByUser = getLikedStatus();
    likesCount = widget.feed.likesCount ?? 0;
  }

  @override
  void dispose() {
    super.dispose();
    pauseVideoPlayer();
    disposeVideoPlayer();
    // _chewieController?.dispose();
    log("$TAG dispose()");
  }

  bool getLikedStatus() {
    bool liked = false;
    if (widget.feed.likes != null && widget.feed.likes!.isNotEmpty) {
      for (var i = 0; i < widget.feed.likes!.length; i++) {
        Likes likes = widget.feed.likes![i];
        if (likes.user != null && likes.user!.id.toString() == userDetails["id"].toString()) {
          liked = true;
          break;
        }
      }
    }
    return liked;
  }

  deleteFeed(String postId) async {
    // try {
    //   await FireStoreMethods().deleteFeed(postId);
    // } catch (err) {
    //   showSnackBar(
    //     context,
    //     err.toString(),
    //   );
    // }
  }

  void likeDislikePost() async {
    log("$TAG likeDislikePost()");
    // anythingChanged = true;
    likedByUser = !likedByUser;
    if (likedByUser) {
      likesCount = likesCount + 1;
    } else {
      likesCount = likesCount - 1;
      if (likesCount < 0) {
        likesCount = 0;
      }
    }
    try {
      HTTPResponse<Map<String, dynamic>> response = await APIHelper.postLikeDislike(
          uid: "${userDetails['id']}", postID: "${widget.feed.id}", status: likedByUser ? "1" : "0");
      // HTTPResponse<Map<String, dynamic>> response = await APIHelper.postLikeDislike(
      //     uid: user!.uid, postID:"${widget.feed.id}", status: "1");
      if (response.isSuccessful && response.data != null) {
        Map<String, dynamic> mResponseMap = response.data!;
        log("$TAG -- likeDislikePost() mResponseMap = ${mResponseMap}");
        // if (map["status_code"] == "200" && map["status_message"] == "Comment Added Successfully.") {
        //   setState(() {
        //     commentEditingController.text = "";
        //   });
        //   showSnackBar(msg:"Comment Added Successfully.", context: context, duration: 1500);
        //   fetchCommentLen(false);
        // }
      }
    } catch (err) {
      showSnackBar(msg: err.toString(), context: context, duration: 1500);
    }

    try {
      getFeedPosts(context);
    } catch (err) {
      log("$TAG -- likeDislikePost(): Error: ${err.toString()}");
    }
    // FireStoreMethods().likePost(
    //   widget.snap['postId'].toString(),
    //   user!.uid,
    //   widget.snap['likes'],
    // );
    // if (widget.snap['likes'].contains(user!.uid)) {
    //   // if the likes list contains the user uid, we need to remove it
    //   widget.snap['likes'].remove(user!.uid);
    //   // _firestore.collection('posts').doc(postId).update({
    //   //   'likes': FieldValue.arrayRemove([uid])
    //   // });
    // } else {
    //   // else we need to add uid to the likes array
    //   widget.snap['likes'].add(user!.uid);
    //   // _firestore.collection('posts').doc(postId).update({
    //   //   'likes': FieldValue.arrayUnion([uid])
    //   // });
    // }
  }

  void openCommentsScreen(model.Feed feed) {
    log("$TAG openCommentsScreen()");
    pauseVideoPlayer();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FeedCommentsScreen(
        feed: feed,
        gotComments: true,
      ),
    ));
  }

  void openSpotDetailsScreen(snap) async {
    log("$TAG openSpotDetailsScreen()");
    pauseVideoPlayer();
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FeedVideoDetailsScreen(
        feed: snap,
        commentsSnap: null,
      ),
    ));
    log("$TAG openSpotDetailsScreen() result == $result");
    // if(result){
    //   getFeedPosts();
    // }
  }

  void openUserProfileScreen(String uid) {
    log("openUserProfileScreen()");
    pauseVideoPlayer();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          ProfileScreenNew1(
            darkMode: widget.darkMode,
            uid: uid,
            showBackButton: true,
          ),
    ));
  }

  void pauseVideoPlayer(){
    log("$TAG pauseVideo()");
    try {
      _videoPlayerController1.pause();
    } catch (e) {
      log("$TAG pauseVideo() ERROR == ${e.toString()}");
    }
  }

  void disposeVideoPlayer(){
    log("$TAG disposeVideoPlayer()");
    try {
      _videoPlayerController1.dispose();
    } catch (e) {
      log("$TAG disposeVideoPlayer() ERROR == ${e.toString()}");
    }
  }

  @override
  void didUpdateWidget(FeedVideoCard4 oldWidget) {
    log("$TAG didUpdateWidget()");
    log("$TAG didUpdateWidget() oldWidget.play == ${oldWidget.play}");
    log("$TAG didUpdateWidget() widget.play == ${widget.play}");
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _videoPlayerController1.play();
        // _videoPlayerController1.setLooping(true);
      } else {
        _videoPlayerController1.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> initializePlayer() async {
    // log("$TAG initializePlayer(): videoURL = ${widget.snap["videoURL"]}");
    log("$TAG initializePlayer(): videoURL = ${widget.feed.video!.video}");
    // _videoPlayerController1 = VideoPlayerController.network(srcs[currPlayIndex]);

    _videoPlayerController1 = VideoPlayerController.network(widget.feed.video!.video!);
    // _videoPlayerController1 = VideoPlayerController.network(widget.snap["videoURL"]);

    _initializeVideoPlayerFuture = _videoPlayerController1.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      _videoPlayerController1.play();
      _videoPlayerController1.addListener(() {

      });
      // _videoPlayerController1.setLooping(true);
    }
    // await Future.wait([
    //   _videoPlayerController1.initialize(),
    // ]);
    // _createChewieController();
    // setState(() {});
  }

  // void _createChewieController() {
  //
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController1,
  //     autoPlay: false,
  //     looping: false,
  //
  //     // Try playing around with some of these other options:
  //
  //     showControls: false,
  //     // materialProgressColors: ChewieProgressColors(
  //     //   playedColor: Colors.red,
  //     //   handleColor: Colors.blue,
  //     //   backgroundColor: Colors.grey,
  //     //   bufferedColor: Colors.lightGreen,
  //     // ),
  //     placeholder: Container(
  //       color: Colors.grey,
  //     ),
  //     autoInitialize: true,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // try {
    //   // final model.User
    //   user = Provider.of<UserProvider>(context).getUser;
    // } catch (err) {
    //   log("$TAG Error == ${err.toString()}");
    // }

    return Container(
      padding: const EdgeInsets.all(2),
      // color: cardColorDark,
      color: widget.darkMode ? cardColorDark : cardColorLight,
      child: Wrap(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              log("$TAG Video tapped");
              openSpotDetailsScreen(widget.feed);
              // if(_videoPlayerController1.value.isPlaying){
              //   _videoPlayerController1.pause();
              // }else{
              //   _videoPlayerController1.play();
              // }
            },
            child: Container(
              height: videoHeight, //MediaQuery.of(context).size.height * 0.44,
              color: Colors.black,
              // padding: const EdgeInsets.all(10),
              child: Center(
                  child: FutureBuilder(
                      // key: PageStorageKey(widget.snap["postId"]),
                      key: PageStorageKey("${widget.feed.id}"),
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) { //  && user != null
                          return Chewie(
                            key: PageStorageKey("${widget.feed.id}"),
                            // key: PageStorageKey(widget.snap["postId"]),
                            controller: ChewieController(
                              videoPlayerController: _videoPlayerController1,
                              autoPlay: false,
                              looping: false,
                              // Try playing around with some of these other options:

                              showControls: false,
                              // showControls: true,
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
                //     : Column(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     CircularProgressIndicator(),
                //     SizedBox(height: 20),
                //     Text('Loading'),
                //   ],
                // ),
              ),
            ),
          ),

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
                InkWell(
                  onTap: () {
                    log("$TAG profImage pressed");
                    //todo uncomment to show profile of the user whose image is clicked
                    // log("$TAG uid: ${widget.snap['uid']}");
                    // log("$TAG username: ${widget.snap['username']}");
                    // openUserProfileScreen(widget.snap['uid']);
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      // showUnsplashImage ? unsplashImageURL : widget.snap['profImage'].toString(),
                      widget.feed.user!.profile!.profile.toString(),
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
                        InkWell(
                          onTap: () {
                            log("$TAG Username pressed");
                            //todo uncomment to show profile of the user whose image is clicked
                            // log("$TAG uid: ${widget.snap['uid']}");
                            // log("$TAG username: ${widget.snap['username']}");
                            // openUserProfileScreen(widget.snap['uid']);
                          },
                          child: Text(
                            // widget.snap['username'].toString(),
                            widget.feed.user!.name.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.darkMode ? textColorDark : textColorLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //todo uncomment to show OverFlow icon for delete Post feature for user
                // widget.snap['uid'].toString() == user!.uid
                //     ? IconButton(
                //   onPressed: () {
                //     log("$TAG overflow icon clicked");
                //     //todo show dialog below
                //   },
                //   icon: Icon(Icons.more_vert,
                //     color: widget.darkMode ? textColorDark : textColorLight,
                //   ),
                // )
                //     : Container(),
              ],
            ),
          ),

          // DESC, LIKE, COMMENT SECTION OF THE POST

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            // padding: const EdgeInsets.only(
            //   top: 8,
            // ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: widget.darkMode ? textColorDark : textColorLight),
                children: [
                  TextSpan(
                    // text: ' ${widget.snap['description']}',
                    text: ' ${widget.feed.description}',
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 30,
            child: Row(
              children: <Widget>[
                Container(
                  // color: Colors.blue,
                  height: 28,
                  width: 40,
                  child: LikeAnimation(
                    isAnimating: false, // widget.snap['likes'].contains(user!.uid),
                    smallLike: true,
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      icon:
                      // widget.snap['likes'].contains(user!.uid)
                      likedByUser
                          ? const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      )
                          : Icon(
                        Icons.favorite_border,
                        color: widget.darkMode ? Colors.white : textColorLight,
                      ),
                      onPressed: () {
                        // FireStoreMethods().likePost(
                        //   widget.snap['postId'].toString(),
                        //   user!.uid,
                        //   widget.snap['likes'],
                        // );
                        likeDislikePost();

                        if (!mounted) {
                          log("$TAG Already unmounted i.e. Dispose called");
                          return;
                        }
                        setState(() {});
                      }
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
                        // '${widget.snap['likes'].length} likes',
                        '${likesCount} likes',
                        style: TextStyle(fontWeight: FontWeight.bold,
                          color: widget.darkMode ? textColorDark : textColorLight,
                        ),
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
                    // openCommentsScreen(widget.snap['postId'].toString());
                    openCommentsScreen(widget.feed);
                  },
                ),
                InkWell(
                    child: Container(
                      child: Text(
                        // '$commentLen comments',
                        '${widget.feed.commentsCount} comments',
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
                      // openCommentsScreen(widget.snap['postId'].toString());
                      openCommentsScreen(widget.feed);
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
                //       color: (darkMode ? iconColorLight : iconColorDark) ,//Colors.white,
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
                    DateFormat.yMMMd().format(DateTime.parse("${widget.feed.createdAt!}")),
                    // DateFormat.yMMMd().format(widget.snap['datePublished'].toDate()),
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
          // // HEADER SECTION OF THE POST
          // Container(
          //   height: 46,
          //   // color: Colors.blue,
          //   padding: const EdgeInsets.symmetric(
          //     vertical: 4,
          //     horizontal: 10,
          //   ).copyWith(right: 0),
          //   child: Row(
          //     children: <Widget>[
          //       InkWell(
          //         onTap: () {
          //           log("$TAG profImage pressed");
          //         },
          //         child: CircleAvatar(
          //           radius: 16,
          //           backgroundImage: NetworkImage(
          //             unsplashImageURL,
          //           ),
          //         ),
          //       ),
          //       Expanded(
          //         child: Padding(
          //           padding: const EdgeInsets.only(
          //             left: 8,
          //           ),
          //           child: Column(
          //             mainAxisSize: MainAxisSize.min,
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: <Widget>[
          //               InkWell(
          //                 onTap: () {
          //                   log("$TAG Username pressed");
          //                 },
          //                 child: Text(
          //                   'username',
          //                   style: const TextStyle(
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {
          //           log("$TAG overflow icon clicked");
          //         },
          //         icon: const Icon(Icons.more_vert),
          //       ),
          //     ],
          //   ),
          // ),
          //
          // // DESC, LIKE, COMMENT SECTION OF THE POST
          //
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.symmetric(horizontal: 8),
          //   // padding: const EdgeInsets.only(
          //   //   top: 8,
          //   // ),
          //   child: RichText(
          //     text: TextSpan(
          //       style: const TextStyle(color: primaryColor),
          //       children: [
          //         TextSpan(
          //           text: 'some description',
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // Container(
          //   height: 30,
          //   child: Row(
          //     children: <Widget>[
          //       Container(
          //         // color: Colors.blue,
          //         height: 28,
          //         width: 40,
          //         child: IconButton(
          //           padding: const EdgeInsets.all(0.0),
          //           icon: Icon(
          //             Icons.favorite_border,
          //           ),
          //           onPressed: () {
          //             log("Like pressed");
          //           },
          //         ),
          //       ),
          //       InkWell(
          //           child: Container(
          //             // color: Colors.red,
          //             padding: const EdgeInsets.all(0.0),
          //             child: Text(
          //               '20 likes',
          //               style: const TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //           ),
          //           onTap: () {
          //             log("Likes pressed");
          //           }),
          //       IconButton(
          //         icon: const Icon(
          //           Icons.comment_outlined,
          //         ),
          //         padding: const EdgeInsets.all(0.0),
          //         onPressed: () {
          //           log("comment icon pressed");
          //         },
          //       ),
          //       InkWell(
          //           child: Container(
          //             child: Text(
          //               '11 comments',
          //               style: const TextStyle(fontWeight: FontWeight.bold),
          //             ),
          //             padding: const EdgeInsets.symmetric(vertical: 0),
          //           ),
          //           onTap: () {
          //             log("Comment text pressed");
          //           }
          //           // onTap: () => Navigator.of(context).push(
          //           //   MaterialPageRoute(
          //           //     builder: (context) => CommentsScreen(
          //           //       postId: widget.snap['postId'].toString(),
          //           //     ),
          //           //   ),
          //           // ),
          //           ),
          //     ],
          //   ),
          // ),
          // //DESCRIPTION AND NUMBER OF COMMENTS
          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 12),
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: <Widget>[
          //       Container(
          //         width: double.infinity,
          //         child: Text(
          //           "12-12-2012",
          //           style: const TextStyle(
          //             fontSize: 12,
          //             color: secondaryColor,
          //           ),
          //         ),
          //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
    // if (user != null) {
    // }
    // return Container(
    //   padding: const EdgeInsets.all(2),
    //   color: cardColorDark,
    //   child: Wrap(
    //     children: <Widget>[
    //       GestureDetector(
    //         onTap: () {
    //           log("Video tapped");
    //           // if(_videoPlayerController1.value.isPlaying){
    //           //   _videoPlayerController1.pause();
    //           // }else{
    //           //   _videoPlayerController1.play();
    //           // }
    //         },
    //         child: Container(
    //           height: MediaQuery.of(context).size.height * 0.44,
    //           color: Colors.black,
    //           // padding: const EdgeInsets.all(10),
    //           child: Center(
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: const [
    //                   CircularProgressIndicator(),
    //                   SizedBox(height: 20),
    //                   Text('Loading'),
    //                 ],
    //               )),
    //         ),
    //       ),
    //
    //       // HEADER SECTION OF THE POST
    //       Container(
    //         height: 46,
    //         // color: Colors.blue,
    //         padding: const EdgeInsets.symmetric(
    //           vertical: 4,
    //           horizontal: 10,
    //         ).copyWith(right: 0),
    //         child: Row(
    //           children: <Widget>[
    //             InkWell(
    //               onTap: () {
    //                 log("$TAG profImage pressed");
    //               },
    //               child: CircleAvatar(
    //                 radius: 16,
    //                 backgroundImage: NetworkImage(
    //                   unsplashImageURL,
    //                 ),
    //               ),
    //             ),
    //             Expanded(
    //               child: Padding(
    //                 padding: const EdgeInsets.only(
    //                   left: 8,
    //                 ),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: <Widget>[
    //                     InkWell(
    //                       onTap: () {
    //                         log("$TAG Username pressed");
    //                       },
    //                       child: Text(
    //                         'username',
    //                         style: const TextStyle(
    //                           fontWeight: FontWeight.bold,
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //             IconButton(
    //               onPressed: () {
    //                 log("$TAG overflow icon clicked");
    //               },
    //               icon: const Icon(Icons.more_vert),
    //             ),
    //           ],
    //         ),
    //       ),
    //
    //       // DESC, LIKE, COMMENT SECTION OF THE POST
    //
    //       Container(
    //         width: double.infinity,
    //         padding: const EdgeInsets.symmetric(horizontal: 8),
    //         // padding: const EdgeInsets.only(
    //         //   top: 8,
    //         // ),
    //         child: RichText(
    //           text: TextSpan(
    //             style: const TextStyle(color: primaryColor),
    //             children: [
    //               TextSpan(
    //                 text: 'description',
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       Container(
    //         height: 30,
    //         child: Row(
    //           children: <Widget>[
    //             Container(
    //               // color: Colors.blue,
    //               height: 28,
    //               width: 40,
    //               child: IconButton(
    //                 padding: const EdgeInsets.all(0.0),
    //                 icon: Icon(
    //                   Icons.favorite_border,
    //                 ),
    //                 onPressed: () {
    //                   log("Like pressed");
    //                 },
    //               ),
    //             ),
    //             InkWell(
    //                 child: Container(
    //                   // color: Colors.red,
    //                   padding: const EdgeInsets.all(0.0),
    //                   child: Text(
    //                     '0 likes',
    //                     style: const TextStyle(fontWeight: FontWeight.bold),
    //                   ),
    //                 ),
    //                 onTap: () {
    //                   log("Likes pressed");
    //                 }),
    //             IconButton(
    //               icon: const Icon(
    //                 Icons.comment_outlined,
    //               ),
    //               padding: const EdgeInsets.all(0.0),
    //               onPressed: () {
    //                 log("comment icon pressed");
    //               },
    //             ),
    //             InkWell(
    //                 child: Container(
    //                   child: Text(
    //                     '0 comments',
    //                     style: const TextStyle(fontWeight: FontWeight.bold),
    //                   ),
    //                   padding: const EdgeInsets.symmetric(vertical: 0),
    //                 ),
    //                 onTap: () {
    //                   log("Comment text pressed");
    //                 }
    //               // onTap: () => Navigator.of(context).push(
    //               //   MaterialPageRoute(
    //               //     builder: (context) => CommentsScreen(
    //               //       postId: widget.snap['postId'].toString(),
    //               //     ),
    //               //   ),
    //               // ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       //DESCRIPTION AND NUMBER OF COMMENTS
    //       Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 12),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //             Container(
    //               width: double.infinity,
    //               child: Text(
    //                 "12-12-2012",
    //                 style: const TextStyle(
    //                   fontSize: 12,
    //                   color: secondaryColor,
    //                 ),
    //               ),
    //               padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
