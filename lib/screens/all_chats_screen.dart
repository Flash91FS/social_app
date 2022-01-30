import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:provider/provider.dart';
import 'package:social_app/widgets/last_chat_card.dart';

const String TAG = "FS - AllChatsScreen - ";

class AllChatsScreen extends StatefulWidget {
  // final postId;
  const AllChatsScreen({Key? key}) : super(key: key);

  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  final TextEditingController commentEditingController = TextEditingController();
  bool isLoading = false;
  int chatLen = 0;

  @override
  void initState() {
    super.initState();
    log("$TAG initState called");
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    log("$TAG dispose called");
  }


  getData() async {
    log("$TAG getData() called");
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
          .get();
      log("$TAG got chatSnap");

      chatLen = chatSnap.docs.length;
      log("$TAG got chatSnap chatLen length = ${chatLen}");
      // if (chatLen == 0) {
      //   // unreadCount = 0;
      //   chatID = "";
      // } else {
      //   // get chatID and unread Count
      //   QueryDocumentSnapshot qSnap = chatSnap.docs.first;
      //   chatID = qSnap["chatId"];
      //   // unreadCount = qSnap["unreadCount"];
      //   log("$TAG got chatSnap chatID = ${chatID}");
      // }

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

  // Widget returnProfilePicWidgetIfAvailable(String? photoUrl) {
  //   if (photoUrl != null && photoUrl.isNotEmpty) {
  //     return CircleAvatar(
  //       radius: 18,
  //       // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
  //       backgroundImage: NetworkImage(photoUrl),
  //       // backgroundColor: Colors.white,
  //     );
  //   } else {
  //     return const CircleAvatar(
  //       radius: 18,
  //       backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkAppBarColor,
        title: const Text(
          'Chats',
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            //using Expanded so that the list will expand the remaining space inside the column
            // and we wouldn't have to give any height value to the List's parent
            child: chatLen == 0
                ? Center(
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Padding(
                            padding: EdgeInsets.all(22.0),
                            child: Text("You have no conversations so far"),
                          ),
                  )
                : Container(
                    // color: Colors.purple,
                    // height: MediaQuery.of(context).size.height - 300,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("chats")
                          .snapshots(),
                      builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.builder(
                          // physics: const BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) => LastChatCard(
                            snap: snapshot.data!.docs[index],
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

      // StreamBuilder(
      //   stream: FirebaseFirestore.instance
      //       .collection('posts')
      //       .doc(widget.postId)
      //       .collection('comments')
      //       .snapshots(),
      //   builder: (context,
      //       AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //
      //     return ListView.builder(
      //       itemCount: snapshot.data!.docs.length,
      //       itemBuilder: (ctx, index) => CommentCard(
      //         snap: snapshot.data!.docs[index],
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
