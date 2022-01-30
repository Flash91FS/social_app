import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/home_page_provider.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/feed_card.dart';
import 'package:social_app/widgets/post_card.dart';
import 'package:social_app/widgets/post_card_2.dart';
import 'package:social_app/widgets/post_card_light.dart';

import 'add_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ScrollController _scrollController = ScrollController();

  void openAddSpotScreen() {
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    if (locProvider.getLoc != null) {
      //open add spot screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AddPostScreen(),
        ),
      );
    } else {
      String error = "Please wait while your location is being fetched";
      log("openAddSpotScreen(): locProvider.isLocServiceEnabled = ${locProvider.isLocServiceEnabled}");
      log("openAddSpotScreen(): locProvider.isLocPermissionGranted = ${locProvider.isLocPermissionGranted}");
      if (!locProvider.isLocServiceEnabled) {
        error = "Could not get user Location, Please make sure that your location service is enabled";
      } else if (!locProvider.isLocPermissionGranted) {
        error = "Could not get user Location, Please make sure that you have granted permission to get your location";
      }
      showSnackBar(context: context, msg: error, duration: 3000);
    }
  }

  void getData() async {
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    LocationData? loc = locProvider.getLoc;
    log("getData(): loc = $loc");
    // _locationData ??= loc;
    bool canGetLoc = await locProvider.enableLocService();
    if (canGetLoc) {
      loc ??= await locProvider.refreshLoc();
      // _locationData = loc;
      // _locationData = await location.getLocation();
      // log("getData(): _locationData = $_locationData");
      // if (mounted) {
      //   log("getData(): mounted = $mounted");
      //   if (isMapCreated) {
      //     log("getData(): isMapCreated = $isMapCreated");
      //     animateToCurrentLoc();
      //   }
      //   setState(() {});
      // }
    }
  }

  void getFeedPosts() async {
    log("getFeedPosts() called ");
    //todo uncomment to connect to server
    // final HomePageProvider homeProvider = Provider.of<HomePageProvider>(context, listen: false);
    // homeProvider.setIsHomePageProcessing(true, notify: false);
    // HTTPResponse<List<Feed>> response =  await APIHelper.getPostsFeed();
    // if(response.isSuccessful){
    //   homeProvider.setFeedsList(response.data!);
    // }else{
    //   log("SHOW ERROR ");
    // }
    // homeProvider.setIsHomePageProcessing(false, notify: false);
    // // String respCodeStr = await APIHelper.getPostsFeed();
    // // log("getFeedPosts(): respCodeStr = $respCodeStr");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _enableLocService();
    _scrollController.addListener(() {
          if (_scrollController.hasClients) {
            if (_scrollController.offset ==
                _scrollController.position.maxScrollExtent) {
              // _getPosts();
              log("initState(): maxScrollExtent == _getPosts(); with Refresh = TRUE");
            }
          }
        });
    try {
      getData();
      getFeedPosts();
      log("initState(): getFeedPosts() called ---");
    } catch (e) {
      log("initState(): Error == ${e.toString()}");
    }
    // _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    log("build(): called ---");
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight,//
      appBar: AppBar(
        backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight,//
        centerTitle: true,
        title: Text("Feed", style: TextStyle(
           color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        // title: SvgPicture.asset(
        //   'assets/ic_instagram.svg',
        //   color: primaryColor,
        //   height: 32,
        // ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.camera_alt_outlined,
              color: darkMode ? iconColorLight : iconColorDark,
            ),
            onPressed: () {
              openAddSpotScreen();
            },
          ),
        ],
      ),
      // body: PostCard(),
      // Center(
      //   child: CircularProgressIndicator(),
      // ),
      //--------------------------------------------------------------
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              child: darkMode ? PostCard2(
                snap: snapshot.data!.docs[index].data(),
              ) : PostCardLight(
                snap: snapshot.data!.docs[index].data(),
              ),
            ),
          );
        },
      ),
      //--------------------------------------------------------------
      // body: Consumer<HomePageProvider>(
      //   builder: (_, provider, __) => provider.isHomePageProcessing
      //       ? const Center(
      //           child: CircularProgressIndicator(),
      //         )
      //       : provider.feedsListLength > 0
      //           ? ListView.builder(
      //               physics: const BouncingScrollPhysics(),
      //               controller: _scrollController,
      //               itemBuilder: (_, index) {
      //                 Feed feed = provider.getFeedByIndex(index);
      //
      //                 return FeedCard(
      //                   feed: feed,
      //                 );
      //                 // return ListTile(
      //                 //   title: Text(post.title!),
      //                 //   subtitle: Text(
      //                 //     post.description!,
      //                 //     maxLines: 2,
      //                 //     overflow: TextOverflow.ellipsis,
      //                 //   ),
      //                 // );
      //               },
      //               itemCount: provider.feedsListLength,
      //             )
      //           : const Center(
      //               child: Text('Nothing to show here!'),
      //             ),
      // ),
      //--------------------------------------------------------------
    );
  }
}
