import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social_app/screens/message_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';

class LastChatCard extends StatelessWidget {
  final snap;
  final double verticalPadding;
  final bool darkMode;
  const LastChatCard({Key? key, required this.snap, required this.darkMode, this.verticalPadding = 5}) : super(key: key);


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
        backgroundImage: const AssetImage('assets/images/default_profile_pic.png'),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    final msg = snap.data()['datePublished'].toDate();
    final today = DateTime.now();
    String suffex = "min";
    var difference = today.difference(msg).inMinutes;
    if(difference>59){
      difference = today.difference(msg).inHours;
      suffex = "hr";
      if(difference>23){
        difference = today.difference(msg).inDays;
        suffex = "days";
      }
    }

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MessageScreen(
            uid: snap.data()['friendId'],
            name: snap.data()['friendName'],
            photoUrl: snap.data()['friendPic'],
          ),
        ));
      },
      child: Wrap(
        children: [
          Container(
            color: darkMode ? cardColorDark : cardColorLight,
            padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: 16),
            child: Row(
              children: [
                returnProfilePicWidgetIfAvailable(snap.data()['friendPic'], mRadius: 26),
                // CircleAvatar(
                //   backgroundImage: NetworkImage(
                //     snap.data()['friendPic'],
                //   ),
                //   radius: 18,
                // ),
                Expanded(
                  child: Container(
                    // color: Colors.blue,
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            snap.data()['friendName'],
                            style: TextStyle(fontWeight: FontWeight.w500, color: darkMode ? Colors.white : Colors.black,
                            fontSize: 16),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          '${snap.data()['text']}',
                            maxLines:2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                        ),
                        //DATE Section
                        // Padding(
                        //   padding: const EdgeInsets.only(top: 4),
                        //   child: Text(
                        //     DateFormat.yMMMd().format(
                        //       snap.data()['datePublished'].toDate(),
                        //     ),
                        //     style: const TextStyle(
                        //       fontSize: 12, fontWeight: FontWeight.w400,),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "${difference} ${suffex}",
                    // "${difference} ${suffex} ago",
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w400, color: darkMode ? Colors.white : Colors.black,),
                  ),
                )
              ],
            ),
          ),
          Divider(
            thickness: 1,
          color: chatBubbleFriendColor),
        ],
      ),
    );
  }
}