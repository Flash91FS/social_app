import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';

import 'add_post_screen.dart';

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
  //     log("_serviceEnabled = $_serviceEnabled");
  //     if (!_serviceEnabled) {
  //       canGetLoc = false;
  //       log("canGetLoc = $canGetLoc");
  //       if (mounted) {
  //         setState(() {});
  //       }
  //       return;
  //     } else {
  //       canGetLoc = await _checkPermissions();
  //       log("canGetLoc = $canGetLoc");
  //       if (mounted) {
  //         setState(() {});
  //       }
  //       return;
  //     }
  //   } else {
  //     canGetLoc = await _checkPermissions();
  //     log("canGetLoc = $canGetLoc");
  //     if (mounted) {
  //       setState(() {});
  //     }
  //     return;
  //   }
  //   // return _serviceEnabled;
  // }
  //
  // Future<bool> _checkPermissions() async {
  //   log("_checkPermissions called");
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       log("_checkPermissions PermissionStatus not granted");
  //       return false;
  //     }
  //   }
  //   log("_checkPermissions PermissionStatus granted getting loc");
  //   _locationData = await location.getLocation();
  //   log("_locationData = $_locationData");
  //   // if (!mounted) {
  //   //   log("Already unmounted i.e. Dispose called");
  //   //   return false;
  //   // }
  //   return true;
  //   // setState(() {});
  // }

  String? _darkMapStyle;
  Future _loadMapStyles() async {
    _darkMapStyle  = await rootBundle.loadString('assets/nightmode.json');
  }

  changeMapMode() {
    if(_darkMapStyle!=null){
      log("changeMapMode(): _darkMapStyle not NULL");
      _controller.setMapStyle(_darkMapStyle);
    }else {
      log("changeMapMode(): _darkMapStyle == NULL");
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
    if(locProvider.getLoc!=null){
      //open add spot screen
      Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddPostScreen(),
          ),);
    }else{
      String error = "Could not get user Location, Please make sure that your location service is enabled";
      if(!locProvider.isLocServiceEnabled){
        error = "Could not get user Location, Please make sure that your location service is enabled";
      }else if(!locProvider.isLocPermissionGranted){
        error = "Could not get user Location, Please make sure that you have granted permission to get your location";
      }
      showSnackBar(context: context, msg: error, duration: 3000);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
     _loadMapStyles();
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
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  void getData() async {
    final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    LocationData? loc = locProvider.getLoc;
    log("getData(): loc = $loc");
    _locationData ??= loc;
    canGetLoc = await locProvider.enableLocService();
    if(canGetLoc){
      loc ??= await locProvider.refreshLoc();
      _locationData = loc;
      // _locationData = await location.getLocation();
      log("getData(): _locationData = $_locationData");
      if (mounted) {
        log("getData(): mounted = $mounted");
        if (isMapCreated) {
          log("getData(): isMapCreated = $isMapCreated");
          animateToCurrentLoc();
        }
        setState(() {});
      }
    }
  }

  void animateToCurrentLoc() {
    _controller.animateCamera(CameraUpdate.newCameraPosition( CameraPosition(
      target: LatLng(_locationData!.latitude!, _locationData!.longitude!),
      zoom: 14.4746,
    ),),);
  }

  @override
  Widget build(BuildContext context) {
    // final LocationProvider locProvider = Provider.of<LocationProvider>(context, listen: false);
    // if (isMapCreated) {
    //   changeMapMode();
    // }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: true,
        title: const Text("Map"),
        // title: SvgPicture.asset(
        //   'assets/ic_instagram.svg',
        //   color: primaryColor,
        //   height: 32,
        // ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_location_alt_outlined,
              color: primaryColor,
            ),
            onPressed: () {
              openAddSpotScreen();
            },
          ),
        ],
      ),
      body: GoogleMap(
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
          changeMapMode();
          if(_locationData != null){
            animateToCurrentLoc();
          }
          setState(() {});
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }
}
