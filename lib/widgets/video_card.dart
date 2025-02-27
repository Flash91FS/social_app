import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:video_player/video_player.dart';


const String TAG = "FS - VideoCard - ";
class VideoCard extends StatefulWidget {
  // const VideoCard({
  //   Key? key,
  //   required this.context,
  //   required ChewieController? chewieController,
  // }) : _chewieController = chewieController, super(key: key);
  //
  // final BuildContext context;
  // final ChewieController? _chewieController;

  const VideoCard({
    Key? key,
  }) : super(key: key);

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _videoPlayerController1;
  ChewieController? _chewieController;

  List<String> srcs = [
    "https://assets.mixkit.co/videos/preview/mixkit-daytime-city-traffic-aerial-view-56-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4"
  ];
  int currPlayIndex = 0;

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
    _chewieController?.dispose();
    log("$TAG dispose()");
  }
  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.network(srcs[currPlayIndex]);
    await Future.wait([
      _videoPlayerController1.initialize(),
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,

      // Try playing around with some of these other options:

      showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      placeholder: Container(
        color: Colors.grey,
      ),
      autoInitialize: true,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          color: Colors.red,
          child: Wrap(
            children: <Widget>[
              GestureDetector(
                onTap: (){
                  log("Video tapped");
                  // if(_videoPlayerController1.value.isPlaying){
                  //   _videoPlayerController1.pause();
                  // }else{
                  //   _videoPlayerController1.play();
                  // }
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  color: Colors.blue,
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: _chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized
                        ? Chewie(
                      controller: _chewieController!,
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
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
                        text: 'some description',
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
                            '20 likes',
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
                            '11 comments',
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




              // TextButton(
              //   onPressed: () {
              //     _chewieController?.enterFullScreen();
              //   },
              //   child: const Text('Fullscreen'),
              // ),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: TextButton(
              //         onPressed: () {
              //           setState(() {
              //             _videoPlayerController1.pause();
              //             _videoPlayerController1.seekTo(Duration.zero);
              //             _createChewieController();
              //           });
              //         },
              //         child: const Padding(
              //           padding: EdgeInsets.symmetric(vertical: 16.0),
              //           child: Text("Landscape Video"),
              //         ),
              //       ),
              //     ),
              //     // Expanded(
              //     //   child: TextButton(
              //     //     onPressed: () {
              //     //       setState(() {
              //     //         _videoPlayerController2.pause();
              //     //         _videoPlayerController2.seekTo(Duration.zero);
              //     //         _chewieController = _chewieController!.copyWith(
              //     //           videoPlayerController: _videoPlayerController2,
              //     //           autoPlay: true,
              //     //           looping: true,
              //     //           /* subtitle: Subtitles([
              //     //               Subtitle(
              //     //                 index: 0,
              //     //                 start: Duration.zero,
              //     //                 end: const Duration(seconds: 10),
              //     //                 text: 'Hello from subtitles',
              //     //               ),
              //     //               Subtitle(
              //     //                 index: 0,
              //     //                 start: const Duration(seconds: 10),
              //     //                 end: const Duration(seconds: 20),
              //     //                 text: 'Whats up? :)',
              //     //               ),
              //     //             ]),
              //     //             subtitleBuilder: (context, subtitle) => Container(
              //     //               padding: const EdgeInsets.all(10.0),
              //     //               child: Text(
              //     //                 subtitle,
              //     //                 style: const TextStyle(color: Colors.white),
              //     //               ),
              //     //             ), */
              //     //         );
              //     //       });
              //     //     },
              //     //     child: const Padding(
              //     //       padding: EdgeInsets.symmetric(vertical: 16.0),
              //     //       child: Text("Portrait Video"),
              //     //     ),
              //     //   ),
              //     // )
              //   ],
              // ),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: TextButton(
              //         onPressed: () {
              //           setState(() {
              //             _platform = TargetPlatform.android;
              //           });
              //         },
              //         child: const Padding(
              //           padding: EdgeInsets.symmetric(vertical: 16.0),
              //           child: Text("Android controls"),
              //         ),
              //       ),
              //     ),
              //     Expanded(
              //       child: TextButton(
              //         onPressed: () {
              //           setState(() {
              //             _platform = TargetPlatform.iOS;
              //           });
              //         },
              //         child: const Padding(
              //           padding: EdgeInsets.symmetric(vertical: 16.0),
              //           child: Text("iOS controls"),
              //         ),
              //       ),
              //     )
              //   ],
              // ),
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: TextButton(
              //         onPressed: () {
              //           setState(() {
              //             _platform = TargetPlatform.windows;
              //           });
              //         },
              //         child: const Padding(
              //           padding: EdgeInsets.symmetric(vertical: 16.0),
              //           child: Text("Desktop controls"),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ],
    );
  }
}