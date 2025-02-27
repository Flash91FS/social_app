import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ChewieVideoWidget extends StatefulWidget {

  final bool play;
  final String url;

  const ChewieVideoWidget({Key? key, required this.url, required this.play})
      : super(key: key);

  @override
  _ChewieVideoWidgetState createState() => _ChewieVideoWidgetState();
}


class _ChewieVideoWidgetState extends State<ChewieVideoWidget> {
  late VideoPlayerController videoPlayerController ;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    videoPlayerController = new VideoPlayerController.network(widget.url);

    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      //       Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
  } // This closing tag was missing

  @override
  void dispose() {
    videoPlayerController.dispose();
    //    widget.videoPlayerController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(

            child: Card(
              key: PageStorageKey(widget.url),
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Chewie(
                      key:  PageStorageKey(widget.url),
                      controller: ChewieController(
                        videoPlayerController: videoPlayerController,
                        aspectRatio: 16 / 9,
                        // Prepare the video to be played and display the first frame
                        autoInitialize: true,
                        looping: false,
                        autoPlay: false,
                        // Errors can occur for example when trying to play a video
                        // from a non-existent URL
                        errorBuilder: (context, errorMessage) {
                          return Center(
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        else {
          return const Center(
            child: CircularProgressIndicator(),);
        }
      },
    );
  }
}