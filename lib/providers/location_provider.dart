import 'package:flutter/widgets.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:location/location.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - LocationProvider - ";

class LocationProvider with ChangeNotifier {
  LocationData? _locationData;
  // final AuthMethods _authMethods = AuthMethods();
  Location location = Location();

  bool _locServiceEnabled = false;
  bool _locPermissionGranted = false;

  get isLocServiceEnabled => _locServiceEnabled;
  get isLocPermissionGranted => _locPermissionGranted;

  LocationData? get getLoc => _locationData;

  Future<LocationData> refreshLoc() async {
    log("$TAG refreshLoc() called");
    LocationData locationData = await location.getLocation();
    log("$TAG refreshLoc(): _locationData = $locationData");
    _locationData = locationData;
    return locationData;
    // notifyListeners();
  }

  Future<bool> enableLocService() async {
    bool canGetLoc = false;
    _locServiceEnabled = await location.serviceEnabled();
    if (!_locServiceEnabled) {
      _locServiceEnabled = await location.requestService();
      log("$TAG enableLocService(): _locServiceEnabled = $_locServiceEnabled");
      if (!_locServiceEnabled) {
        canGetLoc = false;
        log("$TAG enableLocService(): canGetLoc = $canGetLoc");
        // return;
      } else {
        canGetLoc = await _checkPermissions();
        log("$TAG enableLocService(): canGetLoc = $canGetLoc");
        // return;
      }
    } else {
      canGetLoc = await _checkPermissions();
      log("$TAG enableLocService(): canGetLoc = $canGetLoc");
      // return;
    }
    return canGetLoc;
  }

  Future<bool> _checkPermissions() async {
    log("$TAG _checkPermissions() called");
    PermissionStatus _permissionGranted = PermissionStatus.denied;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _locPermissionGranted = false;
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        log("$TAG _checkPermissions(): PermissionStatus not granted");
        _locPermissionGranted = false;
        return false;
      }
    }
    log("$TAG _checkPermissions PermissionStatus granted ");
    // _locationData = await location.getLocation();
    // log("_locationData = $_locationData");
    // if (!mounted) {
    //   log("Already unmounted i.e. Dispose called");
    //   return false;
    // }
    _locPermissionGranted = true;
    return true;
    // setState(() {});
  }
}