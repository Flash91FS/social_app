import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/firebase_side/comments_screen.dart';
import 'package:social_app/screens/firebase_side/post_details_screen.dart';
import 'package:social_app/screens/firebase_side/post_video_details_screen.dart';
import 'package:social_app/screens/profile_screen.dart';
import 'package:social_app/screens/profile_screen_new1.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:social_app/models/user.dart' as model;
import 'package:social_app/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../main.dart';

const String TAG = "FS - VideoPostCard4 - ";

class VideoPostCard4 extends StatefulWidget {
  final snap;
  final darkMode;
  final bool play;

  const VideoPostCard4({
    Key? key,
    required this.snap,
    required bool this.darkMode,
    required this.play,
  }) : super(key: key);

  @override
  State<VideoPostCard4> createState() => _VideoPostCard4State();
}

class _VideoPostCard4State extends State<VideoPostCard4> {
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
  model.User? user = null;
  int commentLen = 0;

  QuerySnapshot? commentsSnap;

  fetchCommentLen() async {
    try {
      // QuerySnapshot snap =
      commentsSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .orderBy("datePublished", descending: true)
          .get();
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
    pauseVideoPlayer();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CommentsScreen(
        postId: postID,
      ),
    ));
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

  void openSpotDetailsScreen(snap) {
    log("openSpotDetailsScreen()");
    pauseVideoPlayer();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PostVideoDetailsScreen(
        snap: snap,
        commentsSnap: commentsSnap,
      ),
    ));
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
  void initState() {
    super.initState();
    log("$TAG initState()");
    initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    pauseVideoPlayer();
    disposeVideoPlayer();
    // _chewieController?.dispose();
    log("$TAG dispose()");
  }

  @override
  void didUpdateWidget(VideoPostCard4 oldWidget) {
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
    log("$TAG initializePlayer(): videoURL = ${widget.snap["videoURL"]}");
    // _videoPlayerController1 = VideoPlayerController.network(srcs[currPlayIndex]);
    _videoPlayerController1 = VideoPlayerController.network(widget.snap["videoURL"]);

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
    // double vidHeight = MediaQuery.of(context).size.height * 0.44;
    // log("$TAG vidHeight == $vidHeight");
    try {
      // final model.User
      user = Provider.of<UserProvider>(context).getUser;
    } catch (err) {
      log("$TAG Error == ${err.toString()}");
    }

    if (user != null) {
      return Container(
        padding: const EdgeInsets.all(2),
        // color: cardColorDark,
        color: widget.darkMode ? cardColorDark : cardColorLight,
        child: Wrap(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                log("Video tapped");
                openSpotDetailsScreen(widget.snap);
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
                        key: PageStorageKey(widget.snap["postId"]),
                        future: _initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && user != null) {
                            return Chewie(
                              key: PageStorageKey(widget.snap["postId"]),
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
                        ],
                      ),
                    ),
                  ),
                  widget.snap['uid'].toString() == user!.uid
                      ? IconButton(
                    onPressed: () {
                      log("$TAG overflow icon clicked");
                      //todo show dialog below
                    },
                    icon: Icon(Icons.more_vert,
                      color: widget.darkMode ? textColorDark : textColorLight,
                    ),
                  )
                      : Container(),
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
                      text: ' ${widget.snap['description']}',
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
                          color: widget.darkMode ? Colors.white : textColorLight,
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
    }
    return Container(
      padding: const EdgeInsets.all(2),
      color: cardColorDark,
      child: Wrap(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              log("Video tapped");
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Loading'),
                    ],
                  )),
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
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      unsplashImageURL,
                    ),
                  ),
                ),
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
                          },
                          child: Text(
                            'username',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    log("$TAG overflow icon clicked");
                  },
                  icon: const Icon(Icons.more_vert),
                ),
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
                style: const TextStyle(color: primaryColor),
                children: [
                  TextSpan(
                    text: 'description',
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
                  child: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    icon: Icon(
                      Icons.favorite_border,
                    ),
                    onPressed: () {
                      log("Like pressed");
                    },
                  ),
                ),
                InkWell(
                    child: Container(
                      // color: Colors.red,
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        '0 likes',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      log("Likes pressed");
                    }),
                IconButton(
                  icon: const Icon(
                    Icons.comment_outlined,
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    log("comment icon pressed");
                  },
                ),
                InkWell(
                    child: Container(
                      child: Text(
                        '0 comments',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onTap: () {
                      log("Comment text pressed");
                    }
                  // onTap: () => Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => CommentsScreen(
                  //       postId: widget.snap['postId'].toString(),
                  //     ),
                  //   ),
                  // ),
                ),
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
                Container(
                  width: double.infinity,
                  child: Text(
                    "12-12-2012",
                    style: const TextStyle(
                      fontSize: 12,
                      color: secondaryColor,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
