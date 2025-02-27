import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/screens/firebase_side/replies_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - CommentCard - ";

class CommentCard extends StatefulWidget {
  final Function buttonHandler;
  final snap;
  Comments? comment;
  final double verticalPadding;
  final bool darkMode;
  final postID;
  final userID;

  CommentCard(
      {Key? key,
      required this.snap,
      this.comment = null,
      required this.darkMode,
      this.verticalPadding = 16,
      required this.postID,
      required this.buttonHandler,
      required this.userID})
      : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  int repliesLen = 0;
  QuerySnapshot? repliesSnap;

  @override
  void initState() {
    super.initState();
    log("$TAG initState())");
    fetchRepliesLength();
  }

  fetchRepliesLength() async {
    log("$TAG fetchRepliesLength() postID = ${widget.postID}");
    if (widget.postID != null && widget.snap != null) {
      log("$TAG fetchRepliesLength() comment = ${widget.snap.data().toString()}");
      log("$TAG fetchRepliesLength() commentId = ${widget.snap.data()['commentId']}");
      log("$TAG fetchRepliesLength() name = ${widget.snap.data()['name']}");
      log("$TAG fetchRepliesLength() text = ${widget.snap.data()['text']}");
      try {
        // QuerySnapshot snap =
        repliesSnap = await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postID)
            .collection('comments')
            .doc(widget.snap.data()['commentId'])
            .collection('replies')
            .get(); //.orderBy("datePublished", descending: true).get();
        repliesLen = repliesSnap!.docs.length;
      } catch (err) {
        log("fetchRepliesLength() : Exception : ${err.toString()}");
        // showSnackBar(
        //   context,
        //   err.toString(),
        // );
      }
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      log("$TAG fetchRepliesLength() repliesLen = ${repliesLen}");
      setState(() {});
    }
  }

  void likeDislikeComment() {
    log("$TAG likeDislikeComment() userID = ${widget.userID}");
    log("$TAG likeDislikeComment() postID = ${widget.postID}");
    log("$TAG likeDislikeComment() commentId = ${widget.snap.data()['commentId']}");
    if (widget.snap != null) {
      try {
        bool containsLikes = widget.snap.data().containsKey("likes");
        if(!containsLikes){
          widget.snap.data()['likes'] = [];
        }
        // bool containsCommentId = widget.snap.data().containsKey("commentId");
        log("$TAG likeDislikeComment() containsLikes = ${containsLikes}");
        // log("$TAG likeDislikeComment() containsCommentId = ${containsCommentId}");
        List likesList = widget.snap.data().containsKey("likes") ? widget.snap.data()['likes'] : [];
        log("$TAG likeDislikeComment() likesList = ${likesList}");
        if (likesList == null) {
          likesList = [];
        }
        if (widget.userID != null && widget.postID != null) {
          FireStoreMethods().likeComment(
            widget.postID,
            widget.snap.data()['commentId'],
            widget.userID,
            likesList,
          );
          if (likesList.contains("${widget.userID}")) {
            // if the likes list contains the user uid, we need to remove it
            likesList.remove("${widget.userID}");
            // _firestore.collection('posts').doc(postId).update({
            //   'likes': FieldValue.arrayRemove([uid])
            // });
          } else {
            // else we need to add uid to the likes array
            likesList.add("${widget.userID}");
            // _firestore.collection('posts').doc(postId).update({
            //   'likes': FieldValue.arrayUnion([uid])
            // });
          }
        }
      } catch (e) {
        log("$TAG likeDislikeComment() : Exception : ${e.toString()}");
      }
    }
  }

  Future<void> openRepliesScreen(int repliesLen) async {
    log("openRepliesScreen()");
    final result = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => RepliesScreen(
        postId: widget.postID,
        commentId: widget.snap.data()['commentId'],
        commentSnap: widget.snap.data(),
        repliesLen: repliesLen,
      ),
    ));
    log("openRepliesScreen() result = $result");
    if(result){
      fetchRepliesLength();
      widget.buttonHandler("Hello Faizan");
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
                  : (widget.comment != null
                      ? widget.comment!.user!.profile!.profile
                      : widget.snap.data()['profilePic']),
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
                            text: (widget.comment != null ? widget.comment!.user!.name : widget.snap.data()['name']),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        TextSpan(
                          text: (widget.comment != null
                              ? ' ${widget.comment!.comment}'
                              : ' ${widget.snap.data()['text']}'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      (widget.comment != null
                          ? "12-12-2022"
                          : DateFormat.yMMMd().format(
                              widget.snap.data()['datePublished'].toDate(),
                            )),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                  widget.snap != null ? Row(
                    children: [
                      Padding(
                        // padding: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.fromLTRB(0, 5, 5, 2),
                        child: widget.snap.data().containsKey("likes")
                            ? Text(
                                "${widget.snap.data()['likes'].length} Likes",
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
                      Padding(
                        // padding: const EdgeInsets.only(top: 4),
                        padding: EdgeInsets.fromLTRB(10, 5, 5, 2),
                        child: GestureDetector(
                          onTap: (){
                            openRepliesScreen(repliesLen);
                          },
                          child: const Text(
                            "Reply",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ) : Container(),

                  (repliesLen > 0 && widget.snap != null) ? Container(
                    alignment: Alignment.center,
                    // padding: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                    child: GestureDetector(
                      onTap: (){
                        openRepliesScreen(repliesLen);
                      },
                      child: Text(
                        "View $repliesLen more replies",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ),
          ),
          // todo uncomment to add Liking a comment feature
          widget.snap != null ? IconButton(
            padding: const EdgeInsets.fromLTRB(0, 3, 0, 0),
            iconSize: 18,
            alignment: Alignment.topCenter,
            icon: (widget.snap.data().containsKey("likes") && widget.snap.data()['likes'].contains(widget.userID))
                ? const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  )
                : Icon(
                    Icons.favorite_border,
                    color: widget.darkMode ? textColorDark : textColorLight,
                  ),
            onPressed: () {
              likeDislikeComment();

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
