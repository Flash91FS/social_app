import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_app/screens/firebase_side/add_post_screen.dart';
import 'package:social_app/screens/firebase_side/all_posts_screen.dart';
import 'package:social_app/screens/home_screen_layout.dart';
import 'package:social_app/screens/old_profile_screen.dart';
import 'package:social_app/screens/profile_screen.dart';

List<Widget> homeScreenItems = [
  // const FeedScreen(),
  // const SearchScreen(),
  // AddPostScreen(),
  // const Text('notifications'),
  // ProfileScreen(
  //   uid: FirebaseAuth.instance.currentUser!.uid,
  // ),

  // TestProfileScreen(
  //   uid: FirebaseAuth.instance.currentUser!.uid,),
  AllPostsScreen(
    darkMode: darkModeGlobal,
  ),
  AddPostScreen(loc: null),
  // const HomeScreenLayout(title: "Home screen"),
  ProfileScreen(
    darkMode: darkModeGlobal,
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];

final Map<String, String> categoryMap = {
  "0": "Choose a Category",
  "1": "ATM",
  "2": "brawl",
  "3": "doctor",
  "4": "fire",
  "5": "hospital",
  "6": "info",
  "7": "job",
  "8": "party",
  "9": "pharmacy",
  "10": "theft",
  "11": "police",
  "12": "car accident",
  "13": "general news",
  "14": "speed limit detector",
  "15": "speed camera",
  "16": "looking for an ATM",
  "17": "looking for a doctor",
  "18": "looking for a hospital",
  "19": "looking for a party",
  "20": "looking for a hair stylist",
  "21": "looking for a health expert",
  "22": "Looking for a pharmacy ",
  "23": "looking for fitness club",
  "24": "looking for restaurant",
  "25": "looking for tattooist",
  "26": "looking for woman",
  "27": "Looking for…something",
};

final Map<String, String> categoryMap222 = {
  "1": "ATM",
  "2": "brawl",
  "3": "doctor",
  "4": "fire",
  "5": "hospital",
  "6": "info",
  "7": "job",
  "8": "party",
  "9": "pharmacy",
  "10": "theft",
  "11": "police",
  "12": "car accident",
  "13": "general news",
  "14": "speed limit detector",
  "15": "looking for a number plate",
  "16": "looking for an ATM",
  "17": "looking for a doctor",
  "18": "looking for a hospital",
  "19": "looking for a party",
  "20": "looking for a hair stylist",
  "21": "looking for a health expert",
  "22": "Looking for a pharmacy ",
  "23": "looking for fitness club",
  "24": "looking for restaurant",
  "25": "looking for tattooist",
  "26": "looking for woman",
  "27": "looking for man",
  "28": "looking for a car",
  "29": "Looking for…something",
};


bool darkModeGlobal = true;
bool coverFit = true;
bool showUnsplashImage = false; //to show unsplash Images instead of actual images from firebase
bool videoAddFeature = false;
bool showVideoFeature = false; //to show pic instead of videos
bool attachedToFirebase = true;
bool showMessagingScreen = true;
bool showProfileScreenAppBar = true;
// String unsplashImageURL = "https://images.unsplash.com/photo-1643478965578-8a27b722e956?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80";
String unsplashImageURL =
    "https://images.unsplash.com/photo-1640622842223-e1e39f4bf627?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1171&q=80";


// http://docs.evostream.com/sample_content/assets/bunny.mp4