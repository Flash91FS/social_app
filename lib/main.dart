import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/comments_provider.dart';
import 'package:social_app/providers/dark_theme_provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/home_page_provider.dart';
import 'package:social_app/providers/login_prefs_provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/default_not_allowed_screen.dart';
import 'package:social_app/screens/login_screen_new1.dart';
import 'package:social_app/screens/splash_screen.dart';
import 'package:social_app/screens/test_chewie_demo.dart';
import 'package:social_app/screens/home_screen_layout.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/mobile_screen_layout.dart';
import 'package:social_app/screens/onboarding_screen.dart';
import 'package:social_app/screens/profile_pic_screen.dart';
import 'package:social_app/screens/signup_screen.dart';
import 'package:social_app/screens/test_home_page.dart';
import 'package:social_app/screens/test_screen_2.dart';
import 'package:social_app/testing/csv_example.dart';
import 'package:social_app/testing/my_list.dart';
import 'package:social_app/testing/video_list.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/login_prefs.dart';
import 'package:social_app/utils/my_styles.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - main - ";

BitmapDescriptor? mapIconBig;
BitmapDescriptor? mapIconSmall;

BitmapDescriptor? mapIconAtmBig;
BitmapDescriptor? mapIconAtmSmall;

BitmapDescriptor? mapIconBrawlBig;
BitmapDescriptor? mapIconBrawlSmall;

BitmapDescriptor? mapIconDoctorBig;
BitmapDescriptor? mapIconDoctorSmall;

BitmapDescriptor? mapIconFireBig;
BitmapDescriptor? mapIconFireSmall;

BitmapDescriptor? mapIconHospitalBig;
BitmapDescriptor? mapIconHospitalSmall;

BitmapDescriptor? mapIconInfoBig;
BitmapDescriptor? mapIconInfoSmall;

BitmapDescriptor? mapIconJobBig;
BitmapDescriptor? mapIconJobSmall;

BitmapDescriptor? mapIconPartyBig;
BitmapDescriptor? mapIconPartySmall;

BitmapDescriptor? mapIconPharmacyBig;
BitmapDescriptor? mapIconPharmacySmall;

BitmapDescriptor? mapIconTheftBig;
BitmapDescriptor? mapIconTheftSmall;

BitmapDescriptor? mapIconPoliceBig;
BitmapDescriptor? mapIconPoliceSmall;

BitmapDescriptor? mapIconAccidentBig;
BitmapDescriptor? mapIconAccidentSmall;

BitmapDescriptor? mapIconFindNumberPlateBig;
BitmapDescriptor? mapIconFindNumberPlateSmall;

BitmapDescriptor? mapIconSpeedLimitDetectorBig;
BitmapDescriptor? mapIconSpeedLimitDetectorSmall;
//-----------------
BitmapDescriptor? mapIconFindAtmBig;
BitmapDescriptor? mapIconFindAtmSmall;

BitmapDescriptor? mapIconFindDoctorBig;
BitmapDescriptor? mapIconFindDoctorSmall;

BitmapDescriptor? mapIconFindHospitalBig;
BitmapDescriptor? mapIconFindHospitalSmall;

BitmapDescriptor? mapIconFindPartyBig;
BitmapDescriptor? mapIconFindPartySmall;

BitmapDescriptor? mapIconFindBarberBig;
BitmapDescriptor? mapIconFindBarberSmall;

BitmapDescriptor? mapIconFindHealthExpertBig;
BitmapDescriptor? mapIconFindHealthExpertSmall;

BitmapDescriptor? mapIconFindPharmacyBig;
BitmapDescriptor? mapIconFindPharmacySmall;

BitmapDescriptor? mapIconFindFitnessBig;
BitmapDescriptor? mapIconFindFitnessSmall;

BitmapDescriptor? mapIconFindRestaurantBig;
BitmapDescriptor? mapIconFindRestaurantSmall;

BitmapDescriptor? mapIconFindTattooistBig;
BitmapDescriptor? mapIconFindTattooistSmall;

BitmapDescriptor? mapIconFindWomanBig;
BitmapDescriptor? mapIconFindWomanSmall;

BitmapDescriptor? mapIconFindManBig;
BitmapDescriptor? mapIconFindManSmall;

BitmapDescriptor? mapIconFindCarBig;
BitmapDescriptor? mapIconFindCarSmall;

BitmapDescriptor? mapIconFindSomethingBig;
BitmapDescriptor? mapIconFindSomethingSmall;

String? darkMapStyle;

String allowed = "1";
double postHeight = 300;
double fullScreenWidth = 500;
double videoHeight = 367;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  getAllowedStatusFromPrefs();
  getAllowedStatus();

  darkMapStyle = await loadMapStyles();
  // await loadMapIconsFromPNG();
  await loadAllMapIcons();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();
  LoginPrefsProvider loginPrefsProvider = LoginPrefsProvider();
  LoginPrefs loginPrefs = LoginPrefs();
  bool mDarkMode = false;
  Map<String, dynamic> userDetails = {};

  @override
  void initState() {
    super.initState();
    log("$TAG initState():");
    getCurrentAppTheme();
    getUserDetails();
    mDarkMode = updateThemeWithSystem();
    log("$TAG initState(): mDarkMode == $mDarkMode");
  }

  void getCurrentAppTheme() async {
    log("$TAG getCurrentAppTheme():");
    // themeChangeProvider.darkTheme =
    // await themeChangeProvider.darkThemePreference.getTheme();
    var brightness = SchedulerBinding.instance!.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    themeChangeProvider.darkTheme = isDarkMode;
  }

  void getUserDetails() async {
    log("$TAG getUserDetails():");
    userDetails = await loginPrefs.getUserLoginDetails();

    log("$TAG getUserDetails(): userDetails = ${userDetails}");
    loginPrefsProvider.setUserDetails(userDetails, false);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    log("$TAG build(): called ---");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => themeChangeProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LoginProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => loginPrefsProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => HomePageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommentsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Spot App',
        // theme: ThemeData(
        //   // This is the theme of your application.
        //   //
        //   // Try running your application with "flutter run". You'll see the
        //   // application has a blue toolbar. Then, without quitting the app, try
        //   // changing the primarySwatch below to Colors.green and then invoke
        //   // "hot reload" (press "r" in the console where you ran "flutter run",
        //   // or simply save your changes to "hot reload" in a Flutter IDE).
        //   // Notice that the counter didn't reset back to zero; the application
        //   // is not restarted.
        //   primarySwatch: Colors.blue,
        //   brightness: Brightness.dark
        // ),
        // theme: MyStyles.themeData(value.darkTheme, context),

        // theme: value.darkTheme ? ThemeData.dark().copyWith(
        //   scaffoldBackgroundColor: mobileBackgroundColor,//will mess with the drawer background color though
        // ) : ThemeData.light().copyWith(
        //   scaffoldBackgroundColor: mobileBackgroundColorLight,//will mess with the drawer background color though
        // ),

        theme: mDarkMode ? ThemeData.dark() : ThemeData.light(),
        // theme: ThemeData(),
        // darkTheme: ThemeData.dark(),
        // themeMode: ThemeMode.system,

        // home: SignupScreen(),// const MyHomePage(title: 'Social App Home Page'),

        //TODO allowed status Check here
        // home: HomeScreenLayout(title: "Home", allowed: allowed, userDetails: userDetails),//allowed != "5" ? getAllowedScreens() : getNotAllowedDefaultScreen(),
        // home: const ProfilePicScreen(showBackButton: false, showSkipButton: false,),
        home: SplashScreen(title: "Splash", allowed: allowed, userDetails: userDetails),
        // home:
        //   attachedToFirebase ?
        //   StreamBuilder(
        //     stream: FirebaseAuth.instance.authStateChanges(),
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.active) {
        //         log("$TAG snapshot.connectionState == ConnectionState.active");
        //         // Checking if the snapshot has any data or not
        //         if (snapshot.hasData) {
        //           log("$TAG snapshot.hasData");
        //           // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
        //           return const MobileScreenLayout(
        //             title: 'Home Page',
        //           );
        //           return HomePage();
        //           return const ChewieDemo();
        //           return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
        //           return const OnboardingScreen();
        //
        //           // bool darkMode = updateThemeWithSystem();
        //           // return FeedScreen(darkMode: darkMode);
        //         } else if (snapshot.hasError) {
        //           log("$TAG snapshot.hasError");
        //           return Center(
        //             child: Text('${snapshot.error}'),
        //           );
        //         }
        //       }
        //
        //       // means connection to future hasnt been made yet
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         log("$TAG snapshot.connectionState == ConnectionState.waiting");
        //         return const Center(
        //           child: CircularProgressIndicator(),
        //         );
        //       }
        //
        //       log("$TAG snapshot.connectionState == ${snapshot.connectionState}");
        //       // return const TestScreen(title: "Test");
        //       // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
        //       return const LoginScreen();
        //     },
        //   )
        //       :
        //   getLoginOrHomeScreenForUser(),


      ),
      // child: Consumer<DarkThemeProvider>(
      //   builder: (_, value, __) {
      //     // return MaterialApp(
      //     //   debugShowCheckedModeBanner: false,
      //     //   theme: MyStyles.themeData(themeChangeProvider.darkTheme, context),
      //     //   home: HomeScreenLayout(title: '',),
      //     //   // routes: <String, WidgetBuilder>{
      //     //   //   AGENDA: (BuildContext context) => AgendaScreen(),
      //     //   // },
      //     // );
      //
      //     return MaterialApp(
      //       title: 'Spot App',
      //       // theme: ThemeData(
      //       //   // This is the theme of your application.
      //       //   //
      //       //   // Try running your application with "flutter run". You'll see the
      //       //   // application has a blue toolbar. Then, without quitting the app, try
      //       //   // changing the primarySwatch below to Colors.green and then invoke
      //       //   // "hot reload" (press "r" in the console where you ran "flutter run",
      //       //   // or simply save your changes to "hot reload" in a Flutter IDE).
      //       //   // Notice that the counter didn't reset back to zero; the application
      //       //   // is not restarted.
      //       //   primarySwatch: Colors.blue,
      //       //   brightness: Brightness.dark
      //       // ),
      //       // theme: MyStyles.themeData(value.darkTheme, context),
      //
      //       // theme: value.darkTheme ? ThemeData.dark().copyWith(
      //       //   scaffoldBackgroundColor: mobileBackgroundColor,//will mess with the drawer background color though
      //       // ) : ThemeData.light().copyWith(
      //       //   scaffoldBackgroundColor: mobileBackgroundColorLight,//will mess with the drawer background color though
      //       // ),
      //
      //       theme: mDarkMode ? ThemeData.dark() : ThemeData.light(),
      //       // theme: ThemeData(),
      //       // darkTheme: ThemeData.dark(),
      //       // themeMode: ThemeMode.system,
      //
      //       // home: SignupScreen(),// const MyHomePage(title: 'Social App Home Page'),
      //       home: StreamBuilder(
      //         stream: FirebaseAuth.instance.authStateChanges(),
      //         builder: (context, snapshot) {
      //           if (snapshot.connectionState == ConnectionState.active) {
      //             // Checking if the snapshot has any data or not
      //             if (snapshot.hasData) {
      //               // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
      //               return const MobileScreenLayout(title: 'Home Page',);
      //               // return HomePage();
      //               // return const ChewieDemo();
      //               // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
      //               // return const OnboardingScreen();
      //             } else if (snapshot.hasError) {
      //               return Center(
      //                 child: Text('${snapshot.error}'),
      //               );
      //             }
      //           }
      //
      //           // means connection to future hasnt been made yet
      //           if (snapshot.connectionState == ConnectionState.waiting) {
      //             return const Center(
      //               child: CircularProgressIndicator(),
      //             );
      //           }
      //
      //           // return const TestScreen(title: "Test");
      //           // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
      //           return const LoginScreen();
      //         },
      //       ),
      //     );
      //   },
      // ),
    );
  }

  getLoginOrHomeScreenForUser() {
    log("$TAG getLoginOrHomeScreenForUser(): userDetails = ${userDetails}");
    log("$TAG getLoginOrHomeScreenForUser(): userDetails.isEmpty = ${userDetails.isEmpty}");
    if(userDetails.isEmpty){
      log("$TAG getLoginOrHomeScreenForUser(): show CircularProgressIndicator");
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if(userDetails.isNotEmpty && userDetails.containsKey("isLoggedIn") && userDetails["isLoggedIn"] == true){
      log("$TAG getLoginOrHomeScreenForUser(): show MobileScreenLayout");
      return const MobileScreenLayout(
        title: 'Home Page',
      );
    } else {
      log("$TAG getLoginOrHomeScreenForUser(): show LoginScreen");
      return const LoginScreenNew1();
    }
  }

  getAllowedScreens() {
    log("$TAG getAllowedScreens():");
    if (attachedToFirebase) {
      return
        StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              log("$TAG snapshot.connectionState == ConnectionState.active");
              // Checking if the snapshot has any data or not
              if (snapshot.hasData) {
                log("$TAG snapshot.hasData");
                // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                return const MobileScreenLayout(
                  title: 'Home Page',
                );
                return TestHomePage();
                return const ChewieDemo();
                return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
                return const OnboardingScreen();

                // bool darkMode = updateThemeWithSystem();
                // return FeedScreen(darkMode: darkMode);
              } else if (snapshot.hasError) {
                log("$TAG snapshot.hasError");
                return Center(
                  child: Text('${snapshot.error}'),
                );
              }
            }

            // means connection to future hasnt been made yet
            if (snapshot.connectionState == ConnectionState.waiting) {
              log("$TAG snapshot.connectionState == ConnectionState.waiting");
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            log("$TAG snapshot.connectionState == ${snapshot.connectionState}");
            // return const TestScreen(title: "Test");
            // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
            return const LoginScreenNew1();
          },
        );
    } else {
      return getLoginOrHomeScreenForUser();
    }
  }

  getNotAllowedDefaultScreen() {
    log("$TAG getNotAllowedDefaultScreen == DefaultNotAllowedScreen");
    return DefaultNotAllowedScreen();
  }

}
// spotkeystore
//pass: 123456
//alias: spot
//pass: 123456

Future<void> getAllowedStatus() async {
  log("$TAG getAllowedStatus(): ");
  try {
    var allowedSnap = await FirebaseFirestore.instance
        .collection('appAllowed')
        .get();
    log("$TAG getAllowedStatus: allowedSnap");

    int allowedLen = allowedSnap.docs.length;
    log("$TAG getAllowedStatus: allowedSnap length = ${allowedLen}");
    String isAllowed = "1";
    if (allowedLen == 0) {
      // unreadCount = 0;
      isAllowed = "1";
    } else {
      // get isAllowed a
      QueryDocumentSnapshot qSnap = allowedSnap.docs.first;
      isAllowed = qSnap["isAllowed"];
      log("$TAG getAllowedStatus: allowedSnap: isAllowed = ${isAllowed}");
    }

    allowed = isAllowed;

    LoginPrefs loginPrefs = LoginPrefs();
    loginPrefs.setIsAllowed(isAllowed);

    // if (!mounted) {
    //   log("$TAG Already unmounted i.e. Dispose called");
    //   return;
    // }
    // setState(() {
    //   isLoading = false;
    // });
  } catch (e) {
    log("$TAG Error: ${e.toString()}");
    // if (!mounted) {
    //   log("$TAG Already unmounted i.e. Dispose called");
    //   return;
    // }
    // showSnackBar(msg: e.toString(), context: context, duration: 1500);
  }
}

Future<void> getAllowedStatusFromPrefs() async {
  log("$TAG getAllowedStatusFromPrefs(): ");
  try {
    LoginPrefs loginPrefs = LoginPrefs();
    String isAllowed = await loginPrefs.getIsAllowed();
    log("$TAG getAllowedStatusFromPrefs: allowedSnap: isAllowed = ${isAllowed}");
    allowed = isAllowed;
  } catch (e) {
    log("$TAG Error: ${e.toString()}");
    // if (!mounted) {
    //   log("$TAG Already unmounted i.e. Dispose called");
    //   return;
    // }
    // showSnackBar(msg: e.toString(), context: context, duration: 1500);
  }
}

Future<void> loadAllMapIcons() async {
  mapIconBig = await loadMapIconsBigFromPNG("ic_general");
  mapIconSmall = await loadMapIconsSmallFromPNG("ic_general");

  mapIconAtmBig = await loadMapIconsBigFromPNG("ic_atm");
  mapIconAtmSmall = await loadMapIconsSmallFromPNG("ic_atm");
  mapIconBrawlBig = await loadMapIconsBigFromPNG("ic_brawl");
  mapIconBrawlSmall = await loadMapIconsSmallFromPNG("ic_brawl");
  mapIconDoctorBig = await loadMapIconsBigFromPNG("ic_doctor");
  mapIconDoctorSmall = await loadMapIconsSmallFromPNG("ic_doctor");
  mapIconFireBig = await loadMapIconsBigFromPNG("ic_fire");
  mapIconFireSmall = await loadMapIconsSmallFromPNG("ic_fire");
  mapIconHospitalBig = await loadMapIconsBigFromPNG("ic_hospital");
  mapIconHospitalSmall = await loadMapIconsSmallFromPNG("ic_hospital");
  mapIconInfoBig = await loadMapIconsBigFromPNG("ic_info");
  mapIconInfoSmall = await loadMapIconsSmallFromPNG("ic_info");
  mapIconJobBig = await loadMapIconsBigFromPNG("ic_job");
  mapIconJobSmall = await loadMapIconsSmallFromPNG("ic_job");
  mapIconPartyBig = await loadMapIconsBigFromPNG("ic_party");
  mapIconPartySmall = await loadMapIconsSmallFromPNG("ic_party");
  mapIconPharmacyBig = await loadMapIconsBigFromPNG("ic_pharmacy");
  mapIconPharmacySmall = await loadMapIconsSmallFromPNG("ic_pharmacy");
  mapIconTheftBig = await loadMapIconsBigFromPNG("ic_theft");
  mapIconTheftSmall = await loadMapIconsSmallFromPNG("ic_theft");
  mapIconPoliceBig = await loadMapIconsBigFromPNG("ic_police");
  mapIconPoliceSmall = await loadMapIconsSmallFromPNG("ic_police");
  mapIconAccidentBig = await loadMapIconsBigFromPNG("ic_car_accident");
  mapIconAccidentSmall = await loadMapIconsSmallFromPNG("ic_car_accident");
  mapIconFindNumberPlateBig = await loadMapIconsBigFromPNG("ic_find_number_plate");
  mapIconFindNumberPlateSmall = await loadMapIconsSmallFromPNG("ic_find_number_plate");
  mapIconSpeedLimitDetectorBig = await loadMapIconsBigFromPNG("ic_speed_detector");
  mapIconSpeedLimitDetectorSmall = await loadMapIconsSmallFromPNG("ic_speed_detector");
  mapIconFindAtmBig = await loadMapIconsBigFromPNG("ic_find_atm");
  mapIconFindAtmSmall = await loadMapIconsSmallFromPNG("ic_find_atm");
  mapIconFindDoctorBig = await loadMapIconsBigFromPNG("ic_find_doctor");
  mapIconFindDoctorSmall = await loadMapIconsSmallFromPNG("ic_find_doctor");
  mapIconFindHospitalBig = await loadMapIconsBigFromPNG("ic_find_hospital");
  mapIconFindHospitalSmall = await loadMapIconsSmallFromPNG("ic_find_hospital");
  mapIconFindPartyBig = await loadMapIconsBigFromPNG("ic_find_party");
  mapIconFindPartySmall = await loadMapIconsSmallFromPNG("ic_find_party");
  mapIconFindBarberBig = await loadMapIconsBigFromPNG("ic_find_hair_stylist");
  mapIconFindBarberSmall = await loadMapIconsSmallFromPNG("ic_find_hair_stylist");
  mapIconFindHealthExpertBig = await loadMapIconsBigFromPNG("ic_find_health_expert");
  mapIconFindHealthExpertSmall = await loadMapIconsSmallFromPNG("ic_find_health_expert");
  mapIconFindPharmacyBig = await loadMapIconsBigFromPNG("ic_find_pharmacy");
  mapIconFindPharmacySmall = await loadMapIconsSmallFromPNG("ic_find_pharmacy");
  mapIconFindFitnessBig = await loadMapIconsBigFromPNG("ic_find_gym");
  mapIconFindFitnessSmall = await loadMapIconsSmallFromPNG("ic_find_gym");
  mapIconFindRestaurantBig = await loadMapIconsBigFromPNG("ic_find_restaurant");
  mapIconFindRestaurantSmall = await loadMapIconsSmallFromPNG("ic_find_restaurant");
  mapIconFindTattooistBig = await loadMapIconsBigFromPNG("ic_find_tattooist");
  mapIconFindTattooistSmall = await loadMapIconsSmallFromPNG("ic_find_tattooist");
  mapIconFindWomanBig = await loadMapIconsBigFromPNG("ic_find_woman");
  mapIconFindWomanSmall = await loadMapIconsSmallFromPNG("ic_find_woman");
  mapIconFindManBig = await loadMapIconsBigFromPNG("ic_find_man");
  mapIconFindManSmall = await loadMapIconsSmallFromPNG("ic_find_man");
  mapIconFindCarBig = await loadMapIconsBigFromPNG("ic_find_car");
  mapIconFindCarSmall = await loadMapIconsSmallFromPNG("ic_find_car");
  mapIconFindSomethingBig = await loadMapIconsBigFromPNG("ic_find_something");
  mapIconFindSomethingSmall = await loadMapIconsSmallFromPNG("ic_find_something");
}

BitmapDescriptor getIconForCategory(String categoryID, bool big) {
  log("$TAG getIconForCategory(): ");
  switch (categoryID) {
    case "1":
      return big ? mapIconAtmBig! : mapIconAtmSmall!;
      break;
    case "2":
      return big ? mapIconBrawlBig! : mapIconBrawlSmall!;
      break;
    case "3":
      return big ? mapIconDoctorBig! : mapIconDoctorSmall!;
      break;
    case "4":
      return big ? mapIconFireBig! : mapIconFireSmall!;
      break;
    case "5":
      return big ? mapIconHospitalBig! : mapIconHospitalSmall!;
      break;
    case "6":
      return big ? mapIconInfoBig! : mapIconInfoSmall!;
      break;
    case "7":
      return big ? mapIconJobBig! : mapIconJobSmall!;
      break;
    case "8":
      return big ? mapIconPartyBig! : mapIconPartySmall!;
      break;
    case "9":
      return big ? mapIconPharmacyBig! : mapIconPharmacySmall!;
      break;
    case "10":
      return big ? mapIconTheftBig! : mapIconTheftSmall!;
      break;
    case "11":
      return big ? mapIconPoliceBig! : mapIconPoliceSmall!;
      break;
    case "12":
      return big ? mapIconAccidentBig! : mapIconAccidentSmall!;
      break;
    case "13":
      return big ? mapIconBig! : mapIconSmall!;
      break;
    case "14":
      return big ? mapIconSpeedLimitDetectorBig! : mapIconSpeedLimitDetectorSmall!;
      break;
    case "15":
      return big ? mapIconFindNumberPlateBig! : mapIconFindNumberPlateSmall!;
      break;
    case "16":
      return big ? mapIconFindAtmBig! : mapIconFindAtmSmall!;
      break;
    case "17":
      return big ? mapIconFindDoctorBig! : mapIconFindDoctorSmall!;
      break;
    case "18":
      return big ? mapIconFindHospitalBig! : mapIconFindHospitalSmall!;
      break;
    case "19":
      return big ? mapIconFindPartyBig! : mapIconFindPartySmall!;
      break;
    case "20":
      return big ? mapIconFindBarberBig! : mapIconFindBarberSmall!;
      break;
    case "21":
      return big ? mapIconFindHealthExpertBig! : mapIconFindHealthExpertSmall!;
      break;
    case "22":
      return big ? mapIconFindPharmacyBig! : mapIconFindPharmacySmall!;
      break;
    case "23":
      return big ? mapIconFindFitnessBig! : mapIconFindFitnessSmall!;
      break;
    case "24":
      return big ? mapIconFindRestaurantBig! : mapIconFindRestaurantSmall!;
      break;
    case "25":
      return big ? mapIconFindTattooistBig! : mapIconFindTattooistSmall!;
      break;
    case "26":
      return big ? mapIconFindWomanBig! : mapIconFindWomanSmall!;
      break;
    case "27":
      return big ? mapIconFindManBig! : mapIconFindManSmall!;
      break;
    case "28":
      return big ? mapIconFindCarBig! : mapIconFindCarSmall!;
      break;
    case "29":
      return big ? mapIconFindSomethingBig! : mapIconFindSomethingSmall!;
      break;

    default:
      return big ? mapIconBig! : mapIconSmall!;
      break;
  }
}

Future<void> loadMapIconsFromPNG() async {
  if (mapIconBig == null) {
    log("$TAG loadMapIconsFromPNG(): creating mIcon ........");
    if (Platform.isAndroid) {
      log("$TAG loadMapIconsFromPNG(): creating mIcon ........ Android --- ic_general_96");
      mapIconBig = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(96, 96)), 'assets/map_icons/ic_general_96.png');
      // const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_96.png');
    } else if (Platform.isIOS) {
      log("$TAG loadMapIconsFromPNG(): creating mIcon ........ iOS --- ic_general_48");
      mapIconBig = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(24, 24)), 'assets/map_icons/ic_general_48.png');
      // const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_48.png');
    } else {
      log("$TAG loadMapIconsFromPNG(): creating mIcon ........ Unknown --- ic_general_144");
      mapIconBig = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(96, 96)), 'assets/map_icons/ic_general_144.png');
      // const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_96.png');
    }
  }

  if (mapIconSmall == null) {
    log("$TAG loadMapIconsFromPNG(): creating mIcon2 ........");
    if (Platform.isAndroid) {
      log("$TAG loadMapIconsFromPNG(): creating mIcon2 ........ Android --- ic_general_48");
      mapIconSmall = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)), 'assets/map_icons/ic_general_48.png');
      // const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_48.png');
    } else if (Platform.isIOS) {
      log("$TAG loadMapIconsFromPNG(): creating mIcon2 ........ iOS --- ic_general_28");
      mapIconSmall = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(12, 12)), 'assets/map_icons/ic_general_28.png');
      // const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_24.png');
    } else {
      log("$TAG loadMapIconsFromPNG(): creating mIcon2 ........ Unknown --- ic_general_36");
      mapIconSmall = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48, 48)), 'assets/map_icons/ic_general_36.png');
      // const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_48.png');
    }
  }
}

Future<BitmapDescriptor> loadMapIconsBigFromPNG(String iconName) async {
  BitmapDescriptor? mMapIconBig;
  log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........");
  if (Platform.isAndroid) {
    log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........ Android --- ${iconName}_96");
    mMapIconBig = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(96, 96)), 'assets/map_icons/${iconName}_96.png');
    // const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_96.png');
  } else if (Platform.isIOS) {
    log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........ iOS --- ${iconName}_48");
    mMapIconBig = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(24, 24)), 'assets/map_icons/${iconName}_48.png');
    // const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_48.png');
  } else {
    log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........ Unknown --- ${iconName}_144");
    mMapIconBig = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(96, 96)), 'assets/map_icons/${iconName}_144.png');
    // const ImageConfiguration(size: Size(24, 24)), 'assets/images/location_marker_96.png');
  }
  return mMapIconBig;
}

Future<BitmapDescriptor> loadMapIconsSmallFromPNG(String iconName) async {
  BitmapDescriptor? mMapIconSmall;
  log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........");
  if (Platform.isAndroid) {
    log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........ Android --- ${iconName}_48");
    mMapIconSmall = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/map_icons/${iconName}_48.png');
    // const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_48.png');
  } else if (Platform.isIOS) {
    log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........ iOS --- ${iconName}_28");
    mMapIconSmall = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(12, 12)), 'assets/map_icons/${iconName}_28.png');
    // const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_24.png');
  } else {
    log("$TAG loadMapIconsFromPNG(): creating mMapIconSmall ........ Unknown --- ${iconName}_36");
    mMapIconSmall = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)), 'assets/map_icons/${iconName}_36.png');
    // const ImageConfiguration(size: Size(12, 12)), 'assets/images/location_marker_48.png');
  }
  return mMapIconSmall;
}
