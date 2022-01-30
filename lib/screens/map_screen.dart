import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

import '../main.dart';
import 'add_post_screen.dart';

const String TAG = "FS - MapScreen - ";

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  // Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  late GoogleMapController _controller;
  bool isMapCreated = false;

  bool canGetLoc = false;

  List<Marker> _markersList = [];
  Map<String, dynamic> dataMap = {};
  QuerySnapshot? snap;
  BitmapDescriptor? mIcon;
  BitmapDescriptor? mIcon2;
  var zoomLevel = 14.0;
  var zoomChangePoint = 11.0;
  bool above11 = true;

  // bool _serviceEnabled = false;
  // PermissionStatus _permissionGranted = PermissionStatus.denied;
  LocationData? _locationData = null;

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
    try {
      _controller.setMapStyle(mapStyle);
    } catch (e) {
      log(e.toString());
    }
  }

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
    super.initState();
    // _enableLocService();
    try {
      getLocData();
      getPostsData();
    } catch (e) {
      log("$TAG initState(): Error == ${e.toString()}");
    }
    // _checkPermissions();
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
    try {
      // QuerySnapshot snap =
      snap = await FirebaseFirestore.instance.collection('posts').get();
      getMarkersFromDataSnap();
    } catch (err) {
      log("$TAG getPostsData(): Error == ${err.toString()}");
    }
  }

  void getMarkersFromDataSnap() async {
    log("$TAG getMarkersFromDataSnap(): called ");
    if (mIcon == null) {
      log("$TAG getMarkersFromDataSnap(): creating mIcon ........");
      if (Platform.isAndroid) {
        mIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_96.png');
      } else if (Platform.isIOS) {
        mIcon = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_48.png');
      }
    }

    if (mIcon2 == null) {
      log("$TAG getMarkersFromDataSnap(): creating mIcon2 ........");
      if (Platform.isAndroid) {
        mIcon2 = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_48.png');
      } else if (Platform.isIOS) {
        mIcon2 = await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_24.png');
      }
    }

    if (snap != null) {
      try {
        int length = snap!.docs.length;
        if (length > 0) {
          log("$TAG getMarkersFromDataSnap(): total length = $length");

          List<Marker> mList = [];
          for (var i = 0; i < length; i++) {
            QueryDocumentSnapshot docc = snap!.docs[i];
            // docc.data()['title'];
            dataMap = docc.data()! as Map<String, dynamic>;

            log("$TAG getMarkersFromDataSnap(): title = ${dataMap['title']}");
            log("$TAG getMarkersFromDataSnap(): desc = ${dataMap['description']}");
            log("$TAG getMarkersFromDataSnap(): lat : lng = ${dataMap['lat']} : ${dataMap['lng']}");
            String lat = dataMap['lat'];
            String lng = dataMap['lng'];
            if (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty) {
              try {
                double mLat = double.parse(lat);
                double mLng = double.parse(lng);
                Marker marker1 = Marker(
                  markerId: MarkerId(dataMap['postId'].toString()),
                  position: LatLng(mLat, mLng),
                  infoWindow: markerInfo(dataMap['title'].toString(), dataMap['description'].toString()),
                  icon: darkMode ? (zoomLevel > zoomChangePoint ? mIcon! : mIcon2!) : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                );
                mList.add(marker1);
              } catch (e) {
                log("$TAG getMarkersFromDataSnap(): Error = ${e.toString()}");
              }
            }
          }
          log("$TAG getMarkersFromDataSnap(): mList.length = ${mList.length}");
          if (mList.isNotEmpty) {
            _markersList.clear();
            _markersList.addAll(mList);

            log("$TAG getMarkersFromDataSnap(): mounted = $mounted");
            log("$TAG getMarkersFromDataSnap(): isMapCreated = $isMapCreated");
            if (mounted) {
              if (isMapCreated) {
                // animateToCurrentLoc();
              }
              setState(() {});
            }
          }
        }
      } catch (e) {
        log("$TAG getMarkersFromDataSnap(): Error == ${e.toString()}");
      }
    }
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
      getMarkersFromDataSnap();
      above11 = false;
    } else if (!above11 && zoomLevel > zoomChangePoint) {
      log("$TAG _onGeoChanged(): position: " + position.target.toString());
      log("$TAG _onGeoChanged(): zoom: " + position.zoom.toString());
      log("$TAG _onGeoChanged(): above11: $above11");
      getMarkersFromDataSnap();
      above11 = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build(): called ");
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
      body: GoogleMap(
        markers: Set<Marker>.of(_markersList),
        myLocationEnabled: canGetLoc,
        myLocationButtonEnabled: canGetLoc,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        // initialCameraPosition: _locationData != null
        //     ? CameraPosition(
        //         target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
        //         zoom: 14.4746,
        //       )
        //     : _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }
}
