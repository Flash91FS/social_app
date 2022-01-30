import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart' as model;
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/message_card.dart';

const String TAG = "FS - MessageScreen - ";

class MessageScreen extends StatefulWidget {
  final uid;
  final name;
  final photoUrl;

  const MessageScreen({Key? key, required this.uid, required this.name, required this.photoUrl}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController commentEditingController = TextEditingController();
  bool isLoading = true;
  int chatLen = 0;

  // int unreadCount = 0;
  String chatID = "";

  void postMessage(String uid, String uName, String uPic) async {
    if (commentEditingController.text.isEmpty) {
      log("$TAG postMessage text.isEmpty");
      return;
    }
    log("$TAG postMessage posting message");
    try {
      bool error = false;

      var mDate = DateTime.now();

      String res = await FireStoreMethods().postLastMessage(
        uid: uid,
        uName: uName,
        uPic: uPic,
        chatId: chatID,
        text: commentEditingController.text,
        friendId: widget.uid,
        friendName: widget.name,
        friendProfilePic: widget.photoUrl,
        dateTime: mDate,
      );
      // String res = await FireStoreMethods().postComment(
      //   widget.postId,
      //   commentEditingController.text,
      //   uid,
      //   name,
      //   profilePic,
      // );

      if (res.contains('success:')) {
        showSnackBar(msg: res, context: context, duration: 1000);
        chatID = res.replaceAll("success:", "").trim();
        log("$TAG postMessage chatID = $chatID");
        error = false;

        String res2 =
            await FireStoreMethods().postChatMessage(chatID, mDate, commentEditingController.text, uid, uName, uPic);

        if (res2.contains('success')) {
          showSnackBar(msg: res2, context: context, duration: 1000);
          log("$TAG postMessage success");
          error = false;
        } else {
          showSnackBar(msg: "Could not post message, please try again", context: context, duration: 1000);
          log("$TAG postMessage res2 == $res2");
          error = true;
        }
      } else {
        showSnackBar(msg: "Could not post message, please try again", context: context, duration: 1000);
        log("$TAG postMessage res == $res");
        error = true;
      }
      if (!error) {
        setState(() {
          commentEditingController.text = "";
          if (chatLen == 0) {
            chatLen++;
          }
        });
      }
    } catch (err) {
      showSnackBar(msg: err.toString(), context: context, duration: 1500);
    }
  }

  Widget returnProfilePicWidgetIfAvailable(String? photoUrl, {double mRadius = 18}) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: mRadius,
        // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
        backgroundImage: NetworkImage(photoUrl),
        // backgroundColor: Colors.white,
      );
    } else {
      return CircleAvatar(
        radius: mRadius,
        backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
      );
    }
  }

  getData() async {
    log("$TAG getData called : UID =  ${widget.uid}");
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      var chatSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("chats")
          .where('friendId', isEqualTo: widget.uid)
          .get();
      log("$TAG got chatSnap");

      chatLen = chatSnap.docs.length;
      log("$TAG got chatSnap chatLen length = ${chatLen}");
      if (chatLen == 0) {
        // unreadCount = 0;
        chatID = "";
      } else {
        // get chatID and unread Count
        QueryDocumentSnapshot qSnap = chatSnap.docs.first;
        chatID = qSnap["chatId"];
        // unreadCount = qSnap["unreadCount"];
        log("$TAG got chatSnap chatID = ${chatID}");
      }

      // get post lENGTH
      // var postSnap = await FirebaseFirestore.instance
      //     .collection('posts')
      //     .where('uid', isEqualTo: widget.uid)
      //     .get();
      // log("$TAG got postSnap");
      //
      // log("$TAG postLen = $postLen");
      // userData = userSnap.data()!;
      // followers = userSnap.data()!['followers'].length;
      // following = userSnap.data()!['following'].length;
      // isFollowing = userSnap.data()!['followers'].contains(FirebaseAuth.instance.currentUser!.uid);
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log("$TAG Error: ${e.toString()}");
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      showSnackBar(msg: e.toString(), context: context, duration: 1500);
      // showSnackBar(
      //   context,
      //   e.toString(),
      // );
    }
    if (!mounted) {
      log("$TAG Already unmounted i.e. Dispose called");
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    log("$TAG initState called");
    for (var i = 0; i < 12; i++) {
      // int rem = i~/3; //gets quotient instead
      int rem = i % 3;
      log("remainder = $rem");
    }
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 3.0,
        backgroundColor: darkAppBarColor,
        title: Text(
          widget.name,
          // 'Message',
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: primaryColor,
            ),
            onPressed: () {
              // openAddSpotScreen();
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            //todo uncomment top row with Image, and remove appBar, only if client wants image to be added, otherwise no need
            // myAppBarWidget(),

            Expanded(
              //using Expanded so that the list will expand the remaining space inside the column
              // and we wouldn't have to give any height value to the List's parent
              child: chatLen == 0
                  ? Center(
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : Padding(
                              padding: const EdgeInsets.all(22.0),
                              child: Text("Start a conversation with ${widget.name}"),
                            ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      // color: Colors.purple,
                      // height: MediaQuery.of(context).size.height - 300,
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatID)
                            .collection('messages')
                            .orderBy('datePublished',descending: true)
                            .snapshots(),
                        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView.builder(
                            // physics: const BouncingScrollPhysics(),
                            reverse: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (ctx, index) => MessageCard(
                              snap: snapshot.data!.docs[index],
                              isSender:
                                  snapshot.data!.docs[index]["senderID"] == FirebaseAuth.instance.currentUser!.uid,
                            ),
                          );

                          // return ListView.builder(
                          //   physics: const BouncingScrollPhysics(),
                          //   itemCount: snapshot.data!.docs.length * 3,
                          //   itemBuilder: (ctx, index) => MessageCard(
                          //     snap: snapshot.data!.docs[(index % 3)],
                          //   ),
                          // );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      //-------------------------

      // Container(
      //
      //   color: Colors.purple,
      //   height: MediaQuery.of(context).size.height, // 200,
      //   child: StreamBuilder(
      //     stream: FirebaseFirestore.instance
      //         .collection('posts')
      //         .doc("08d556e0-779e-11ec-9a13-5f9e406608a6")
      //         .collection('comments')
      //         .snapshots(),
      //     builder: (context,
      //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
      //       if (snapshot.connectionState == ConnectionState.waiting) {
      //         return const Center(
      //           child: CircularProgressIndicator(),
      //         );
      //       }
      //
      //       return ListView.builder(
      //         physics: ClampingScrollPhysics(),
      //         itemCount: snapshot.data!.docs.length*3,
      //         itemBuilder: (ctx, index) => CommentCard(
      //           snap: snapshot.data!.docs[(index%3)],
      //         ),
      //       );
      //     },
      //   ),
      // ),

      //-------------------------
      // text input
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.grey[900],
          height: kToolbarHeight,
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              returnProfilePicWidgetIfAvailable(user.photoUrl),
              // CircleAvatar(
              //   backgroundImage: NetworkImage(user.photoUrl),
              //   radius: 18,
              // ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintText: 'Type your message',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => postMessage(
                  user.uid,
                  user.username,
                  user.photoUrl,
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

  Widget myAppBarWidget() {
    return Ink(
      height: 60,
      color: darkAppBarColor,
      // padding: EdgeInsets.fromLTRB(14, 0, 0, 0),
      child: Row(
        children: [
          //Back Icon
          InkWell(
            onTap: () {},
            child: Ink(
              // padding: EdgeInsets.all(14),
              padding: EdgeInsets.fromLTRB(14, 14, 0, 14),
              child: Icon(Icons.arrow_back_ios),
            ),
          ),
          //Friend Profile Pic
          returnProfilePicWidgetIfAvailable(widget.photoUrl, mRadius: 20),
          //Friend Name
          Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 0, 14),
            child: Text(
              widget.name,
              style:
                  // Theme.of(context)
                  //         .textTheme
                  //         .headline6!,
                  const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          //Spacing in between
          Flexible(
            child: Container(),
          ),
          //OverFlow Icon
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: primaryColor,
            ),
            onPressed: () {
              // openAddSpotScreen();
            },
          ),
        ],
      ),
    );
  }
}
