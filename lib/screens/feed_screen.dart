import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/post_card.dart';

import 'add_post_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _enableLocService();
    try {
      getData();
    } catch (e) {
      log("initState(): Error == ${e.toString()}");
    }
    // _checkPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: const Text("Home"),
        // title: SvgPicture.asset(
        //   'assets/ic_instagram.svg',
        //   color: primaryColor,
        //   height: 32,
        // ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.camera_alt_outlined,
              color: primaryColor,
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (ctx, index) => Container(
              margin: EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 0,
              ),
              child: PostCard(
                snap: snapshot.data!.docs[index].data(),
              ),
            ),
          );
        },
      ),
    );
  }
}
