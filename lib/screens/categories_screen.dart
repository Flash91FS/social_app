import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/resources/firestore_methods.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/catagory_card.dart';
import 'package:social_app/widgets/comment_card.dart';
import 'package:provider/provider.dart';

const String TAG = "FS - CategoriesScreen - ";

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  CategoriesScreenState createState() => CategoriesScreenState();
}

class CategoriesScreenState extends State<CategoriesScreen> {
  // Widget returnProfilePicWidgetIfAvailable(String? photoUrl) {
  //   if (photoUrl != null && photoUrl.isNotEmpty) {
  //     return CircleAvatar(
  //       radius: 18,
  //       // backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
  //       backgroundImage: NetworkImage(showUnsplashImage ? unsplashImageURL : photoUrl),
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
    final User user = Provider.of<UserProvider>(context).getUser;
    // final themeChange = Provider.of<DarkThemeProvider>(context);
    // bool darkMode = themeChange.darkTheme;
    bool darkMode = updateThemeWithSystem();
    DarkThemeProvider _darkThemeProvider = Provider.of(context);
    _darkThemeProvider.setSysDarkTheme(darkMode);
    log("$TAG build(): darkMode == ${darkMode}");

    return Scaffold(
        backgroundColor: darkMode ? cardColorDark : cardColorLight,
        appBar: AppBar(
          iconTheme: IconThemeData(color: darkMode ? Colors.white : Colors.black),
          backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight, //
          title: Text(
            'Catagories',
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: false,
        ),
        body: ListView.builder(
          itemCount: categoryMap222.length,
          itemBuilder: (context, index) {
            String key = categoryMap222.keys.elementAt(index);
            return GestureDetector(
              onTap: () {
                log("$TAG List item Clicked KEY == ${key}");
                log("$TAG List item Clicked VALUE == ${categoryMap222[key]}");
                Navigator.pop(context, key);
              },
              child: CatagoryCard(
                darkMode: darkMode,
                id: key,
                category: "${categoryMap222[key]}",
              ),
            );
            // return new Column(
            //   children: <Widget>[
            //     new ListTile(
            //       title: new Text("$key"),
            //       subtitle: new Text("${values[key]}"),
            //     ),
            //     new Divider(
            //       height: 2.0,
            //     ),
            //   ],
            // );
          },
          // itemBuilder: (ctx, index) => GestureDetector(
          //   onTap: (){
          //     log("$TAG List item Clicked == ${categoryMap222[index]}");
          //   },
          //   child: CatagoryCard(
          //     darkMode: darkMode,
          //   ),
          // ),
        )
        // body: StreamBuilder(
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
        //       itemBuilder: (ctx, index) => CatagoryCard(
        //         darkMode: darkMode,
        //       ),
        //     );
        //   },
        // ),
        );
  }
}
