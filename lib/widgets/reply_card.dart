import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/firebase_side/replies_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - ReplyCard - ";

class ReplyCard extends StatefulWidget {
  final replySnap;
  // Comments? comment;
  final double verticalPadding;
  final bool darkMode;
  final postId;
  final commentId;
  final userID;

  ReplyCard(
      {Key? key,
        required this.replySnap,
        // this.comment = null,
        required this.darkMode,
        this.verticalPadding = 16,
        required this.postId,
        required this.commentId,
        required this.userID})
      : super(key: key);

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
  // int repliesLen = 0;
  // QuerySnapshot? repliesSnap;

  @override
  void initState() {
    super.initState();
    // fetchRepliesLength();
  }

  // fetchRepliesLength() async {
  //   log("$TAG fetchRepliesLength() postId = ${widget.postId}");
  //   if (widget.postId != null && widget.replySnap != null) {
  //     log("$TAG fetchRepliesLength() comment = ${widget.replySnap.data().toString()}");
  //     log("$TAG fetchRepliesLength() commentId = ${widget.replySnap.data()['commentId']}");
  //     log("$TAG fetchRepliesLength() name = ${widget.replySnap.data()['name']}");
  //     log("$TAG fetchRepliesLength() text = ${widget.replySnap.data()['text']}");
  //     try {
  //       // QuerySnapshot snap =
  //       repliesSnap = await FirebaseFirestore.instance
  //           .collection('posts')
  //           .doc(widget.postId)
  //           .collection('comments')
  //           .doc(widget.replySnap.data()['commentId'])
  //           .collection('replies')
  //           .get(); //.orderBy("datePublished", descending: true).get();
  //       repliesLen = repliesSnap!.docs.length;
  //     } catch (err) {
  //       log("fetchRepliesLength() : Exception : ${err.toString()}");
  //       // showSnackBar(
  //       //   context,
  //       //   err.toString(),
  //       // );
  //     }
  //     if (!mounted) {
  //       log("$TAG Already unmounted i.e. Dispose called");
  //       return;
  //     }
  //     log("$TAG fetchRepliesLength() repliesLen = ${repliesLen}");
  //     setState(() {});
  //   }
  // }


  void likeDislikeReply(String uid) {
    log("$TAG likeDislikeReply() userID = ${uid}");
    log("$TAG likeDislikeReply() postId = ${widget.postId}");
    log("$TAG likeDislikeReply() commentId = ${widget.commentId}");
    log("$TAG likeDislikeReply() replyId = ${widget.replySnap['replyId']}");
    if (widget.replySnap != null) {
      try {
        bool containsLikes = widget.replySnap.containsKey("likes");
        if(!containsLikes){
          widget.replySnap['likes'] = [];
        }
        // bool containsCommentId = widget.replySnap.containsKey("commentId");
        log("$TAG likeDislikeReply() containsLikes = ${containsLikes}");
        // log("$TAG likeDislikeReply() containsCommentId = ${containsCommentId}");
        List likesList = widget.replySnap.containsKey("likes") ? widget.replySnap['likes'] : [];
        log("$TAG likeDislikeReply() likesList = ${likesList}");
        if (likesList == null) {
          likesList = [];
        }
        if (uid != null && widget.postId != null) {
          FireStoreMethods().likeReply(
            widget.postId,
            widget.commentId,
            widget.replySnap['replyId'],
            uid,
            likesList,
          );
          if (likesList.contains("${uid}")) {
            // if the likes list contains the user uid, we need to remove it
            // log("$TAG likeDislikeReply() : BEFORE likesList : ${likesList}");
            log("$TAG likeDislikeReply() : BEFORE widget.replySnap['likes'] : ${widget.replySnap['likes']}");
            // likesList.remove("${uid}");
            widget.replySnap['likes'].remove("${uid}");
            // log("$TAG likeDislikeReply() : AFTER likesList : ${likesList}");
            log("$TAG likeDislikeReply() : AFTER widget.replySnap['likes'] : ${widget.replySnap['likes']}");


          } else {
            // else we need to add uid to the likes array
            // log("$TAG likeDislikeReply() : BEFORE likesList : ${likesList}");
            log("$TAG likeDislikeReply() : BEFORE widget.replySnap['likes'] : ${widget.replySnap['likes']}");
            // likesList.add("${uid}");
            widget.replySnap['likes'].add("${uid}");
            // log("$TAG likeDislikeReply() : AFTER likesList : ${likesList}");
            log("$TAG likeDislikeReply() : AFTER widget.replySnap['likes'] : ${widget.replySnap['likes']}");


          }

          if (!mounted) {
            log("$TAG Already unmounted i.e. Dispose called");
            return;
          }
          log("$TAG likeDislikeReply() : widget.replySnap['likes'] : ${widget.replySnap['likes']}");
          setState(() {
          });
        }
      } catch (e) {
        log("$TAG likeDislikeReply() : Exception : ${e.toString()}");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    log("$TAG build() darkMode = ${widget.darkMode}");

    return Container(
      color: widget.darkMode ? cardColorDark : cardColorLight,
      padding: EdgeInsets.symmetric(vertical: widget.verticalPadding, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              showUnsplashImage
                  ? unsplashImageURL
                  :
              // (widget.comment != null ? widget.comment!.user!.profile!.profile : widget.replySnap['profilePic']),
              (widget.replySnap['profilePic']),
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
                      style: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
                      children: [
                        TextSpan(
                            // text: (widget.comment != null ? widget.comment!.user!.name : widget.replySnap['name']),
                            text: (widget.replySnap['name']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        TextSpan(
                          // text: (widget.comment != null ? ' ${widget.comment!.comment}' : ' ${widget.replySnap['text']}'),
                          text: (' ${widget.replySnap['text']}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      // (widget.comment != null ? "12-12-2022" : DateFormat.yMMMd().format( widget.replySnap['datePublished'].toDate(),)),
                      (DateFormat.yMMMd().format( widget.replySnap['datePublished'].toDate(),)),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  widget.replySnap != null ? Row(
                    children: [
                      Padding(
                        // padding: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 2),
                        child: widget.replySnap.containsKey("likes")
                            ? Text(
                          "${widget.replySnap['likes'].length} Likes",
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
                      // const Padding(
                      //   // padding: const EdgeInsets.only(top: 4),
                      //   padding: EdgeInsets.fromLTRB(10, 5, 5, 2),
                      //   child: Text(
                      //     "Reply",
                      //     style: TextStyle(
                      //       fontSize: 12,
                      //       fontWeight: FontWeight.w700,
                      //       color: secondaryColor,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ) : Container(),

                  // (repliesLen > 0 && widget.replySnap != null) ? Container(
                  //   alignment: Alignment.center,
                  //   // padding: const EdgeInsets.only(top: 4),
                  //   padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                  //   child: GestureDetector(
                  //     onTap: (){
                  //       openRepliesScreen(repliesLen);
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
          widget.replySnap != null ? IconButton(
            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
            iconSize: 18,
            alignment: Alignment.topCenter,
            icon: (widget.replySnap.containsKey("likes") && widget.replySnap['likes'].contains(widget.userID))
                ? const Icon(
              Icons.favorite,
              color: Colors.red,
            )
                : Icon(
              Icons.favorite_border,
              color: widget.darkMode ? textColorDark : textColorLight,
            ),
            onPressed: () {
              likeDislikeReply(widget.userID);

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
}
