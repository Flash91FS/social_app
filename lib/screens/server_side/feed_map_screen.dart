import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:social_app/models/feed.dart';
import 'package:social_app/models/likes.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/home_page_provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/login_prefs_provider.dart';
import 'package:social_app/screens/firebase_side/post_details_screen.dart';
import 'package:social_app/screens/server_side/add_feed_screen.dart';
import 'package:social_app/screens/server_side/feed_details_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

import '../../main.dart';


const String TAG = "FS - FeedMapScreen - ";

class FeedMapScreen extends StatefulWidget {
  final bool darkMode;

  const FeedMapScreen({Key? key, required this.darkMode}) : super(key: key);

  @override
  State<FeedMapScreen> createState() => FeedMapScreenState();
}

class FeedMapScreenState extends State<FeedMapScreen> {
  // Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  late GoogleMapController _controller;
  bool isMapCreated = false;

  bool canGetLoc = false;

  List<Marker> _markersList = [];
  List<Feed> feedList = [];
  // List dataMapList = [];
  // QuerySnapshot? snap;
  var zoomLevel = 14.0;
  var zoomChangePoint = 11.0;
  bool above11 = true;
  bool fiveSecondsPassed = false;

  // bool _serviceEnabled = false;
  // PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData = null;
  Map<String, dynamic> userDetails = {};

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     // tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
  //
  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  // }

  // Future<void> _enableLocService() async {
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     log("$TAG _serviceEnabled = $_serviceEnabled");
  //     if (!_serviceEnabled) {
  //       canGetLoc = false;
  //       log("$TAG canGetLoc = $canGetLoc");
  //       if (mounted) {
  //         setState(() {});
  //       }
  //       return;
  //     } else {
  //       canGetLoc = await _checkPermissions();
  //       log("$TAG canGetLoc = $canGetLoc");
  //       if (mounted) {
  //         setState(() {});
  //       }
  //       return;
  //     }
  //   } else {
  //     canGetLoc = await _checkPermissions();
  //     log("$TAG canGetLoc = $canGetLoc");
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     return;
  //   }
  //   // return _serviceEnabled;
  // }
  //
  // Future<bool> _checkPermissions() async {
  //   log("$TAG _checkPermissions called");
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       log("$TAG _checkPermissions PermissionStatus not granted");
  //       return false;
  //     }
  //   }
  //   log("$TAG _checkPermissions PermissionStatus granted getting loc");
  //   _locationData = await location.getLocation();
  //   log("$TAG _locationData = $_locationData");
  //   // if (!mounted) {
  //   //   log("$TAG Already unmounted i.e. Dispose called");
  //   //   return false;
  //   // }
  //   return true;
  //   // setState(() {});
  // }

  //
  // String? _darkMapStyle;
  //
  // Future _loadMapStyles() async {
  //   _darkMapStyle = await rootBundle.loadString('assets/nightmode.json');
  // }

  changeMapMode() {
    log("$TAG changeMapMode():");
    if (darkMapStyle != null) {
      log("$TAG changeMapMode(): _darkMapStyle not NULL");
      // _controller.setMapStyle(darkMapStyle);
      setMapStyle(darkMapStyle!);
    } else {
      log("$TAG changeMapMode(): _darkMapStyle == NULL");
      getJsonFile("assets/nightmode.json").then(setMapStyle);
    }
    // if (ConfigBloc().darkModeOn) {
    //   getJsonFile("assets/nightmode.json").then(setMapStyle);
    // } else {
    //   getJsonFile("assets/daymode.json").then(setMapStyle);
    // }
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    log("$TAG setMapStyle():");
    try {
      //todo set dark map style
      // _controller.setMapStyle(mapStyle);
    } catch (e) {
      log(e.toString());
    }
  }

  void openAddSpotScreen2() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddFeedScreen(loc: _locationData),
      ),
    );
  }
  void openAddSpotScreen() {
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    if (locProvider.getLoc != null) {
      //open add spot screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddFeedScreen(loc: _locationData),
        ),
      );
    } else {
      String error = "Could not get user Location, Please make sure that your location service is enabled";
      if (!locProvider.isLocServiceEnabled) {
        error = "Could not get user Location, Please make sure that your location service is enabled";
      } else if (!locProvider.isLocPermissionGranted) {
        error = "Could not get user Location, Please make sure that you have granted permission to get your location";
      }
      showSnackBar(context: context, msg: error, duration: 3000);
    }
  }



  InfoWindow markerInfo(String title, String desc) {
    return InfoWindow(
        title: title,
        snippet: desc,
        onTap: () {
          log("$TAG markerInfo window clicked");
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    // _loadMapStyles();
    log("$TAG initState():");
    final LoginPrefsProvider loginPrefsProvider = Provider.of<LoginPrefsProvider>(context, listen: false);
    userDetails = loginPrefsProvider.getUserDetailsMap;
    Future.delayed(const Duration(milliseconds: 5000), () {
      setState(() {
        log("$TAG initState(): fiveSecondsPassed = true");
        fiveSecondsPassed = true;
      });
    });

    log("$TAG initState(): super called");
    super.initState();
    // _enableLocService();
    try {
      log("$TAG initState(): calling methods");
      getLocData();
      // getPostsData();
    } catch (e) {
      log("$TAG initState(): Error == ${e.toString()}");
    }
    // _checkPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log("$TAG didChangeDependencies():");

    getPostsData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  void getLocData() async {
    log("$TAG getLocData(): called");
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    LocationData? loc = locProvider.getLoc;
    log("$TAG getLocData(): loc = $loc");
    if (_locationData == null && loc != null) {
      _locationData = loc;
    }
    canGetLoc = await locProvider.enableLocService();
    log("$TAG getLocData(): canGetLoc = $canGetLoc");
    if (canGetLoc) {
      loc ??= await locProvider.refreshLoc();
      _locationData = loc;
      // _locationData = await location.getLocation();
      log("$TAG getLocData(): _locationData = $_locationData");

      if (mounted) {
        log("$TAG getLocData(): mounted = $mounted");
        if (isMapCreated) {
          log("$TAG getLocData(): isMapCreated = $isMapCreated");
          animateToCurrentLoc();
        }
        setState(() {});
      }
    }
  }

  void getPostsData() async {
    log("$TAG getPostsData(): ");
    try {
      final HomePageProvider homeProvider = Provider.of<HomePageProvider>(context, listen: true);
      if(homeProvider.isHomePageProcessing){
        log("$TAG getPostsData(): homeProvider == PROCCESSING");
      }else{
        log("$TAG getPostsData(): homeProvider == GOT DATA");
        feedList = homeProvider.feedsList;
        if (mapIconBig == null || mapIconSmall == null){
          log("$TAG getDataMapListFromSnap(): mMapIcon == null || mMapIcon2 == null ");
          // await loadMapIconsFromPNG();
          mapIconBig = await loadMapIconsBigFromPNG("ic_general");
          mapIconSmall = await loadMapIconsSmallFromPNG("ic_general");
        }
        getMarkersFromDataMapList();
      }
      // // QuerySnapshot snap =
      // snap = await FirebaseFirestore.instance.collection('posts').get();
      // //     .then((QuerySnapshot querySnapshot) {
      // //   querySnapshot.docs.forEach((doc) async {
      // //     // print(doc["first_name"]);
      // //     try {
      // //       Map<String, dynamic> dataMap = doc.data() as Map<String, dynamic>;
      // //       log("$TAG getPostsData(): Title == ${dataMap['title']}");
      // //       String commentsCount = await fetchCommentLen(dataMap["postId"].toString());
      // //       dataMap["commentsCount"] = commentsCount;
      // //       log("$TAG getPostsData(): commentsCount = ${dataMap['commentsCount']}");
      // //     } catch (e) {
      // //       print(e);
      // //     }
      // //   });
      // //   log("$TAG getPostsData(): here -------------------------------");
      // // });
      // getDataMapListFromSnap();
    } catch (err) {
      log("$TAG getPostsData(): Error == ${err.toString()}");
    }
  }

  Future<String> fetchCommentLen(String postId) async {
    try {
      // QuerySnapshot snap =
      QuerySnapshot? commentsSnap =
      await FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').get();
      int commentLen = commentsSnap.docs.length;
      return "$commentLen";
    } catch (err) {
      log("$TAG fetchCommentLen(): Error == ${err.toString()}");
    }
    return "0";
  }

  // void getDataMapListFromSnap() async {
  //   log("$TAG getDataMapListFromSnap(): called ");
  //   if (mapIconBig == null || mapIconSmall == null){
  //     log("$TAG getDataMapListFromSnap(): mMapIcon == null || mMapIcon2 == null ");
  //     await loadMapIconsFromPNG();
  //   }
  //
  //   if (snap != null) {
  //     try {
  //       int length = snap!.docs.length;
  //       if (length > 0) {
  //         log("$TAG getDataMapListFromSnap(): total length = $length");
  //         log("$TAG getDataMapListFromSnap(): snap = $snap");
  //
  //         dataMapList = [];
  //         // List<Marker> mList = [];
  //         for (var i = 0; i < length; i++) {
  //           QueryDocumentSnapshot docc = snap!.docs[i];
  //           // List cList = docc.get("comments");
  //           // log("$TAG getDataMapListFromSnap(): cList = ${cList.length}");
  //           // docc.data()['title'];
  //
  //           Map<String, dynamic> dataMap = {};
  //           dataMap = docc.data()! as Map<String, dynamic>;
  //           // log("$TAG getDataMapListFromSnap(): dataMap = ${dataMap}");
  //           String commentsCount = await fetchCommentLen(dataMap["postId"].toString());
  //           dataMap["commentsCount"] = commentsCount;
  //           dataMap["commentsCount"] = commentsCount;
  //           // log("$TAG getDataMapListFromSnap(): username = ${dataMap['username']}");
  //           // log("$TAG getDataMapListFromSnap(): title = ${dataMap['title']}");
  //           // log("$TAG getDataMapListFromSnap(): desc = ${dataMap['description']}");
  //           // log("$TAG getDataMapListFromSnap(): commentsCount = ${dataMap['commentsCount']}");
  //           // log("$TAG getDataMapListFromSnap(): lat : lng = ${dataMap['lat']} : ${dataMap['lng']}");
  //
  //           dataMapList.add(dataMap);
  //           getMarkersFromDataMapList();
  //
  //           // String lat = dataMap['lat'];
  //           // String lng = dataMap['lng'];
  //           // if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
  //           //   try {
  //           //     double mLat = double.parse(lat);
  //           //     double mLng = double.parse(lng);
  //           //     Marker marker1 = Marker(
  //           //       onTap: () {
  //           //         log("$TAG Marker clicked: dataMap = $dataMap");
  //           //         showModalBottomSheet(
  //           //             context: context, isScrollControlled: true, builder: (context) => buildDetailsSheet(dataMap));
  //           //       },
  //           //       markerId: MarkerId(dataMap['postId'].toString()),
  //           //       position: LatLng(mLat, mLng),
  //           //       // infoWindow: markerInfo(dataMap['title'].toString(), dataMap['description'].toString()),
  //           //       // icon: widget.darkMode
  //           //       //     ? (zoomLevel > zoomChangePoint ? mMapIcon! : mMapIcon2!)
  //           //       //     : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //           //       //   icon: mMapIcon!,
  //           //         icon: !fiveSecondsPassed ? mMapIcon! : ((zoomLevel > zoomChangePoint) ? mMapIcon! : mMapIcon2!),
  //           //       // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //           //     );
  //           //     mList.add(marker1);
  //           //   } catch (e) {
  //           //     log("$TAG getMarkersFromDataSnap(): Error = ${e.toString()}");
  //           //   }
  //           // }
  //         }
  //         // log("$TAG getMarkersFromDataSnap(): mList.length = ${mList.length}");
  //         // if (mList.isNotEmpty) {
  //         //   _markersList.clear();
  //         //   _markersList.addAll(mList);
  //         //
  //         //   log("$TAG getMarkersFromDataSnap(): mounted = $mounted");
  //         //   log("$TAG getMarkersFromDataSnap(): isMapCreated = $isMapCreated");
  //         //   if (mounted) {
  //         //     if (isMapCreated) {
  //         //       // animateToCurrentLoc();
  //         //     }
  //         //     setState(() {});
  //         //   }
  //         // }
  //       }
  //     } catch (e) {
  //       log("$TAG getDataMapListFromSnap(): Error == ${e.toString()}");
  //     }
  //   } else {
  //     log("$TAG getDataMapListFromSnap(): snap == NULL");
  //   }
  // }


  bool getLikedStatus(Feed feed) {
    bool liked = false;
    if (feed.likes != null && feed.likes!.isNotEmpty) {
      for (var i = 0; i < feed.likes!.length; i++) {
        Likes likes = feed.likes![i];
        if (likes.user != null && likes.user!.id.toString() == userDetails["id"].toString()) {
          liked = true;
          break;
        }
      }
    }
    return liked;
  }

  void getMarkersFromDataMapList(){
    log("$TAG getMarkersFromDataMapList():");
    // log("$TAG getDataMapListFromSnap(): dataMapList.length == ${dataMapList.length}");
    log("$TAG getDataMapListFromSnap(): feedList.length == ${feedList.length}");
    // if(dataMapList.isNotEmpty){
    if(feedList.isNotEmpty){
      List<Marker> mList = [];
      // for(var i = 0; i < dataMapList.length; i++) {
      for(var i = 0; i < feedList.length; i++) {
        // Map<String, dynamic> dataMap = dataMapList[i];
        // String lat = dataMap['lat'];
        // String lng = dataMap['lng'];
        Feed feedMap = feedList[i];
        String? lat = feedMap.latitude;//dataMap['lat'];
        String? lng = feedMap.longitude;//dataMap['lng'];
        if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
          try {
            double mLat = double.parse(lat);
            double mLng = double.parse(lng);
            bool likedByUser = getLikedStatus(feedMap);
            Marker marker1 = Marker(
              onTap: () {
                log("$TAG Marker clicked: feedMap = $feedMap");
                showModalBottomSheet(
                    context: context, isScrollControlled: true, builder: (context) => buildDetailsSheet(feedMap, likedByUser));
              },
              // markerId: MarkerId(dataMap['postId'].toString()),
              markerId: MarkerId("${feedMap.id}"),
              position: LatLng(mLat, mLng),
              // infoWindow: markerInfo(dataMap['title'].toString(), dataMap['description'].toString()),
              // icon: widget.darkMode
              //     ? (zoomLevel > zoomChangePoint ? mMapIcon! : mMapIcon2!)
              //     : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              //   icon: mMapIcon!,
              icon: !fiveSecondsPassed ? mapIconBig! : ((zoomLevel > zoomChangePoint) ? mapIconBig! : mapIconSmall!),
              // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );
            mList.add(marker1);
          } catch (e) {
            log("$TAG getMarkersFromDataMapList(): Error = ${e.toString()}");
          }
        }
      }
      log("$TAG getMarkersFromDataMapList(): mList.length = ${mList.length}");
      if (mList.isNotEmpty) {
        _markersList.clear();
        _markersList.addAll(mList);

        log("$TAG getMarkersFromDataMapList(): mounted = $mounted");
        log("$TAG getMarkersFromDataMapList(): isMapCreated = $isMapCreated");
        if (mounted) {
          if (isMapCreated) {
            // animateToCurrentLoc();
          }
          setState(() {});
        }
      }
    }

  }

  Widget returnProfilePicWidgetIfAvailable(String? photoUrl) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(showUnsplashImage ? unsplashImageURL : photoUrl),
        // backgroundColor: Colors.white,
      );
    } else {
      return const CircleAvatar(
        radius: 18,
        backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
      );
    }
  }

  // Widget buildDetailsSheet(Map<String, dynamic> dataMap) {
  Widget buildDetailsSheet(Feed feed, bool likedByUser) {
    log("$TAG getMarkersFromDataSnap(): widget.darkMode == ${widget.darkMode}");
    int likesCount = 0;
    likesCount = feed.likesCount ?? 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: (Platform.isAndroid)
                  ? const EdgeInsets.fromLTRB(20, 15, 20, 20)
                  : const EdgeInsets.fromLTRB(20, 15, 20, 50), //todo make bottom padding to 50 for iOS later
              // color: Colors.grey[850],
              decoration: BoxDecoration(
                // border: Border.all(
                //   color: mobileBackgroundColor,
                // ),
                // borderRadius: BorderRadius.circular(_cardRadius),
                color: widget.darkMode ? cardColorDark : cardColorLight, // mobileBackgroundColor,
                // color: Colors.blue, // mobileBackgroundColor,
              ),
              child: Wrap(
                children: [
                  // HEADER SECTION OF THE POST
                  Container(
                    height: 46,
                    // color: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      // horizontal: 10,
                    ), //.copyWith(right: 0),
                    child: Row(
                      children: <Widget>[
                        // returnProfilePicWidgetIfAvailable(dataMap['profImage'].toString()),
                        returnProfilePicWidgetIfAvailable(feed.user!.profile!.profile.toString()),
                        // CircleAvatar(
                        //   radius: 16,
                        //   backgroundImage: NetworkImage(
                        //     showUnsplashImage ? unsplashImageURL : widget.snap['profImage'].toString(),
                        //   ),
                        // ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  // dataMap['username'].toString(),
                                  feed.user!.name.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: widget.darkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Overflow or Close icon in this case
                        Container(
                          height: 32,
                          width: 30,
                          // color: Colors.blue,
                          child: Center(
                            child: IconButton(
                              iconSize: 24.0,
                              padding: const EdgeInsets.all(4.0),
                              onPressed: () {
                                log("$TAG close icon clicked");
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.arrow_drop_down_circle_outlined,
                                color: widget.darkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

// DATE SECTION OF THE POST
                  Container(
                    // padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            // DateFormat.yMMMd().format(dataMap['datePublished'].toDate()),
                            DateFormat.yMMMd().format(DateTime.parse("${feed.createdAt!}")),
                            style: const TextStyle(
                              fontSize: 12,
                              color: secondaryColor,
                            ),
                          ),
                          // padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),

// DESCRIPTION SECTION OF THE POST
                  Container(
                    width: double.infinity,
                    // color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    // padding: const EdgeInsets.symmetric(vertical: 10),//horizontal: 8,
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      // "${dataMap['title'].toString()}",
                      '${feed.title}',
                      style: TextStyle(
                        // backgroundColor: Colors.purple,
                        fontWeight: FontWeight.bold,
                        color: widget.darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    // color: Colors.purple,
                    // padding: const EdgeInsets.symmetric(vertical: 10),//horizontal: 8,
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    child: Text(
                      // "${dataMap['description'].toString()}",
                      '${feed.description}',
                      style: TextStyle(
                        color: widget.darkMode ? Colors.white : Colors.black,
                        // backgroundColor: Colors.blue,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // IMAGE SECTION OF THE POST
                  const SizedBox(height:0.1),
                  // Container(
                  //   // color: Colors.grey[900],
                  //   height: MediaQuery.of(context).size.width * 0.66, //MediaQuery.of(context).size.height * 0.34,
                  //   width: MediaQuery.of(context).size.width,
                  //   // child: Image.network(
                  //   //   widget.snap['postUrl'].toString(),
                  //   //   fit: BoxFit.cover,
                  //   // ),
                  //   // child: Image.asset("assets/images/placeholder_img.png",),
                  //   child: FadeInImage.assetNetwork(
                  //       fit: coverFit ? BoxFit.cover : BoxFit.contain,
                  //       placeholder: "assets/images/placeholder_img.png",
                  //       image: showUnsplashImage ? unsplashImageURL : "${dataMap['postUrl']}"),
                  //
                  //   decoration: BoxDecoration(
                  //     // border: Border.all(
                  //     //   color: mobileBackgroundColor,
                  //     // ),
                  //     // borderRadius: BorderRadius.only(
                  //     //   topLeft: Radius.circular(_cardRadius),
                  //     //   topRight: Radius.circular(_cardRadius),
                  //     // ),
                  //     color: Colors.grey[900], // mobileBackgroundColor,
                  //   ),
                  // ),
                  const SizedBox(height:0.1),
                  // LIKE, COMMENT SECTION OF THE POST
                  Container(
                    height: 40,
                    // color: Colors.blue,
                    child: Row(
                      children: <Widget>[
                        Container(
                          // color: Colors.blue,
                          height: 28,
                          width: 40,
                          child: IconButton(
                            padding: const EdgeInsets.all(0.0),
                            icon:
                            // dataMap['likes'].contains("user!.uid")
                            likedByUser
                                ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                                : Icon(
                              Icons.favorite_border,
                              color: widget.darkMode ? Colors.white : Colors.black,
                            ),
                            onPressed: () {
                              // likeDislikePost();

                              // if (!mounted) {
                              //   log("$TAG Already unmounted i.e. Dispose called");
                              //   return;
                              // }
                              // setState(() {});
                            },
                          ),
                        ),
                        Container(
                          // color: Colors.red,
                          padding: const EdgeInsets.all(0.0),
                          // child: DefaultTextStyle(
                          //     style: Theme.of(context)
                          //         .textTheme
                          //         .subtitle2!
                          //         .copyWith(fontWeight: FontWeight.w800),
                          //     child: Text(
                          //       '${widget.snap['likes'].length} likes',
                          //       style: Theme.of(context).textTheme.bodyText2,
                          //     ),),
                          child: Text(
                            // '${dataMap['likes'].length} likes',
                            '${likesCount} likes',
                            style: TextStyle(fontWeight: FontWeight.bold,
                              color: widget.darkMode ? Colors.white : Colors.black,),
                          ),
                        ),

                        IconButton(
                          icon: Icon(
                            Icons.comment_outlined,
                            color: widget.darkMode ? Colors.white : Colors.black,
                          ),
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            log("$TAG comment icon pressed");
                            // openCommentsScreen(dataMap['postId'].toString());
                          },
                        ),
                        InkWell(
                            child: Container(
                              child: Text(
                                // '${dataMap['commentsCount']} comments',
                                '${feed.commentsCount} comments',
                                // '10 comments',
                                style: TextStyle(fontWeight: FontWeight.bold,
                                  color: widget.darkMode ? Colors.white : Colors.black,),
                              ),
                              // padding: const EdgeInsets.all(1.0),
                              padding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onTap: () {
                              log("$TAG comment icon pressed");
                              // openCommentsScreen(dataMap['postId'].toString());
                            }),
                        // IconButton(
                        //     icon: const Icon(
                        //       Icons.send,
                        //     ),
                        //     onPressed: () {}),
                        // Expanded(
                        //     child: Align(
                        //       alignment: Alignment.bottomRight,
                        //       child: IconButton(
                        //           icon: const Icon(Icons.bookmark_border), onPressed: () {}),
                        //     ))
                      ],
                    ),
                  ),
                  const SizedBox(height:0.1),
                  Padding(padding: EdgeInsets.all(10),
                    child: Center(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          openSpotDetailsScreen(feed);
                        },
                        child: Text(
                          "Click for more details",
                          style: TextStyle(
                            color: appBlueColorLight,
                            fontWeight: FontWeight.bold,
                            // backgroundColor: Colors.blue,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),)
                ],
              ),
            ),
            // Positioned(
            //   top: -20,
            //   right: 1,
            //   left: 1,
            //   child: Center(
            //     child: Stack(
            //       children: const [
            //         CircleAvatar(
            //           radius: 40,
            //           backgroundImage: AssetImage('assets/images/default_profile_pic.png'),
            //           backgroundColor: Colors.white,
            //         )
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  void openSpotDetailsScreen(Feed snap) {
    log("openSpotDetailsScreen()");
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FeedDetailsScreen(
        feed: snap,
        commentsSnap: null,// commentsSnap,
      ),
    ));
  }

  void animateToCurrentLoc() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
          zoom: zoomLevel, //13.4746,
        ),
      ),
    );
  }

  void _onGeoChanged(CameraPosition position) {
    zoomLevel = position.zoom;
    if (above11 && zoomLevel <= zoomChangePoint) {
      log("$TAG _onGeoChanged(): position: " + position.target.toString());
      log("$TAG _onGeoChanged(): zoom: " + position.zoom.toString());
      log("$TAG _onGeoChanged(): above11: $above11");
      getMarkersFromDataMapList();
      above11 = false;
    } else if (!above11 && zoomLevel > zoomChangePoint) {
      log("$TAG _onGeoChanged(): position: " + position.target.toString());
      log("$TAG _onGeoChanged(): zoom: " + position.zoom.toString());
      log("$TAG _onGeoChanged(): above11: $above11");
      getMarkersFromDataMapList();
      above11 = true;
    }
    // log("$TAG _onGeoChanged(): zoom: " + position.zoom.toString());
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build(): called ");
    final themeChange = Provider.of<DarkThemeProvider>(context);
    bool darkMode = themeChange.darkTheme;
    // final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    // if (isMapCreated) {
    //   changeMapMode();
    // }

    // final marker1 = Marker(
    //   markerId: MarkerId('Marker1'),
    //   position: LatLng(32.195476, 74.2023563),
    //   infoWindow: markerInfo('Business 1', "Some medium sized description...."),
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    // );
    //
    // final marker2 = Marker(
    //   markerId: MarkerId('Marker2'),
    //   position: LatLng(31.110484, 72.384598),
    //   infoWindow: markerInfo('Business 2', "Some medium sized description...."),
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    // );
    // _markersList.add(marker1);
    // _markersList.add(marker2);

    // List<Marker> _markersList = [,
    // ];

    return Scaffold(
      floatingActionButton: (canGetLoc && _locationData != null)
          ? FloatingActionButton.extended(
        onPressed: () {
          animateToCurrentLoc();
        },
        label: const Text('Re-center', style:TextStyle(color: Colors.white)),
        icon: const Icon(CupertinoIcons.location_north_fill, color: Colors.white),
        backgroundColor: appBlueColor,
      )
          : null,
      appBar: AppBar(
        backgroundColor: darkMode ? mobileBackgroundColor : mobileBackgroundColorLight,
        centerTitle: true,
        title: Text(
          "Map",
          style: TextStyle(
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
              Icons.add_location_alt_outlined,
              color: darkMode ? iconColorLight : iconColorDark,
            ),
            onPressed: () {
              openAddSpotScreen();
            },
          ),
        ],
      ),
      // body: SlidingUpPanel(
      //   panel: Center(
      //     child: Text("This is the sliding Widget",
      //       style: TextStyle(
      //         color: darkMode ? Colors.red : Colors.red,
      //       ),
      //     ),
      //   ),
      body: GoogleMap(
        markers: Set<Marker>.of(_markersList),
        myLocationEnabled: canGetLoc,
        myLocationButtonEnabled: (canGetLoc && _locationData == null),
        zoomControlsEnabled: false,
        // minMaxZoomPreference: MinMaxZoomPreference(2, 17),
        // minMaxZoomPreference: MinMaxZoomPreference(2, 16),
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        // initialCameraPosition: _locationData != null
        //     ? CameraPosition(
        //         target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
        //         zoom: 14.4746,
        //       )
        //     : _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          log("$TAG onMapCreated():");
          // _controller.complete(controller);
          _controller = controller;
          isMapCreated = true;
          if (darkMode) {
            changeMapMode();
          }
          if (_locationData != null) {
            log("$TAG onMapCreated(): _locationData != null");
            animateToCurrentLoc();
          } else {
            log("$TAG onMapCreated(): _locationData == NULL");
          }
          setState(() {});
        },
        onCameraMove: _onGeoChanged,
      ),
      // )
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

// Widget returnGoogleMap(bool darkMode){
//   log("$TAG returnGoogleMap(): darkMode = $darkMode");
//   return GoogleMap(
//     markers: Set<Marker>.of(_markersList),
//     myLocationEnabled: canGetLoc,
//     myLocationButtonEnabled: (canGetLoc && _locationData == null),
//     zoomControlsEnabled: false,
//     mapType: MapType.normal,
//     initialCameraPosition: _kGooglePlex,
//     // initialCameraPosition: _locationData != null
//     //     ? CameraPosition(
//     //         target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
//     //         zoom: 14.4746,
//     //       )
//     //     : _kGooglePlex,
//     onMapCreated: (GoogleMapController controller) {
//       log("$TAG onMapCreated():");
//       // _controller.complete(controller);
//       _controller = controller;
//       isMapCreated = true;
//       if (darkMode) {
//         changeMapMode();
//       }
//       if (_locationData != null) {
//         log("$TAG onMapCreated(): _locationData != null");
//         animateToCurrentLoc();
//       } else {
//         log("$TAG onMapCreated(): _locationData == NULL");
//       }
//       setState(() {});
//     },
//     onCameraMove: _onGeoChanged,
//   );
// }
}
