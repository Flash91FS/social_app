import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/resources/firestore_methods.dart';
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

const String TAG = "FS - VideoPostCard3 - ";

class VideoPostCard3 extends StatefulWidget {
  final snap;

  const VideoPostCard3({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<VideoPostCard3> createState() => _VideoPostCard3State();
}

class _VideoPostCard3State extends State<VideoPostCard3> {
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

  @override
  void initState() {
    super.initState();
    log("$TAG initState()");
    initializePlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController1.dispose();
    // _chewieController?.dispose();
    log("$TAG dispose()");
  }

  Future<void> initializePlayer() async {
    // _videoPlayerController1 = VideoPlayerController.network(srcs[currPlayIndex]);
    _videoPlayerController1 = VideoPlayerController.network(widget.snap["videoURL"]);

    _initializeVideoPlayerFuture = _videoPlayerController1.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
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
    try {
      // final model.User
      user = Provider.of<UserProvider>(context).getUser;
    } catch (err) {
      log("$TAG Error == ${err.toString()}");
    }

    if (user != null) {
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

                                // showControls: false,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
                          icon: const Icon(Icons.more_vert),
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
                  style: const TextStyle(color: primaryColor),
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
                            : const Icon(
                                Icons.favorite_border,
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        log("$TAG Likes pressed");
                      }),

                  IconButton(
                    icon: const Icon(
                      Icons.comment_outlined,
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

  void openUserProfileScreen(snap) {}

  void openCommentsScreen(String string) {}
}
