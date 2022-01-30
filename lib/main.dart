import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/location_provider.dart';
import 'package:social_app/providers/home_page_provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/home_screen_layout.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/screens/mobile_screen_layout.dart';
import 'package:social_app/screens/onboarding_screen.dart';
import 'package:social_app/screens/profile_pic_screen.dart';
import 'package:social_app/screens/signup_screen.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/utils.dart';

const String TAG = "FS - main - ";
String? darkMapStyle;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  darkMapStyle = await loadMapStyles();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider(),),
        ChangeNotifierProvider(create: (_) => LoginProvider(),),
        ChangeNotifierProvider(create: (_) => HomePageProvider(),),
        ChangeNotifierProvider(create: (_) => LocationProvider(),),
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
        theme: darkMode ? ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ) : ThemeData.light().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        // home: SignupScreen(),// const MyHomePage(title: 'Social App Home Page'),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                // Checking if the snapshot has any data or not
                if (snapshot.hasData) {
                  // if snapshot has data which means user is logged in then we check the width of screen and accordingly display the screen layout
                  return const MobileScreenLayout(title: 'Home Page',);
                  // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
                  // return const OnboardingScreen();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                }
              }

              // means connection to future hasnt been made yet
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // return const TestScreen(title: "Test");
              // return const ProfilePicScreen(showBackButton: false, showSkipButton: false,);
              return const LoginScreen();
            },
          ),
      ),
    );
  }
}
// spotkeystore
//pass: 123456
//alias: spot
//pass: 123456
