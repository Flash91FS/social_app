
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_app/screens/add_post_screen.dart';
import 'package:social_app/screens/home_screen_layout.dart';
import 'package:social_app/screens/old_profile_screen.dart';
import 'package:social_app/screens/feed_screen.dart';
import 'package:social_app/screens/profile_screen.dart';

List<Widget> homeScreenItems = [
  // const FeedScreen(),
  // const SearchScreen(),
  // const AddPostScreen(),
  // const Text('notifications'),
  // ProfileScreen(
  //   uid: FirebaseAuth.instance.currentUser!.uid,
  // ),


  // TestProfileScreen(
  //   uid: FirebaseAuth.instance.currentUser!.uid,),
  const FeedScreen(),
  const AddPostScreen(),
  // const HomeScreenLayout(title: "Home screen"),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];