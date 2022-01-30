import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/utils/colors.dart';

class MessageCard extends StatelessWidget {
  final snap;
  final bool isSender;
  final double verticalPadding;
  const MessageCard({Key? key, required this.snap, this.isSender = true, this.verticalPadding = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
      child: Column(
        children: [
          BubbleNormal(
            text: '${snap.data()['text']}',
            isSender: isSender,
            color: isSender?chatBubbleSenderColor:chatBubbleFriendColor,
            tail: true,
            textStyle: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),

          Container(
            alignment: isSender ?  Alignment.topRight:Alignment.topLeft,
            // color: Colors.purple,
                      padding: const EdgeInsets.fromLTRB(16,0,16,0),
                      child: Text(
                        DateFormat("MMM d, hh:mm a").format(//.yMMMd()
                          snap.data()['datePublished'].toDate(),
                        ),
                        style: const TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w400,),
                      ),
                    )
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   margin: const EdgeInsets.all(16),
          //   constraints: BoxConstraints(maxWidth: 140),
          //   decoration: BoxDecoration(
          //     color: isMe? Colors.grey[800]:Colors.blue[900],
          //     borderRadius:isMe?
          //     borderRadius.subtract():borderRadius.subtract()
          //   ),
          //   child: Text('${snap.data()['text']}', ),
          // )
        ],
      ),
      // child: Row(
      //   children: [
      //     // CircleAvatar(
      //     //   backgroundImage: NetworkImage(
      //     //     snap.data()['senderPic'],
      //     //   ),
      //     //   radius: 18,
      //     // ),
      //     Padding(
      //       padding: const EdgeInsets.only(left: 16),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           RichText(
      //             text: TextSpan(
      //               children: [
      //                 // TextSpan(
      //                 //     text: snap.data()['senderName'],
      //                 //     style: const TextStyle(fontWeight: FontWeight.bold,)
      //                 // ),
      //                 TextSpan(
      //                   text: ' ${snap.data()['text']}',
      //                 ),
      //               ],
      //             ),
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.only(top: 4),
      //             child: Text(
      //               DateFormat("MMM d, hh:mm a").format(//.yMMMd()
      //                 snap.data()['datePublished'].toDate(),
      //               ),
      //               style: const TextStyle(
      //                 fontSize: 12, fontWeight: FontWeight.w400,),
      //             ),
      //           )
      //         ],
      //       ),
      //     ),
      //     // todo uncomment to add Liking a comment feature
      //     // Container(
      //     //   padding: const EdgeInsets.all(8),
      //     //   child: const Icon(
      //     //     Icons.favorite,
      //     //     size: 16,
      //     //   ),
      //     // )
      //   ],
      // ),
    );
  }
}