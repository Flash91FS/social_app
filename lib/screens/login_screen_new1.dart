import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_app/apis/api_helper.dart';
import 'package:social_app/models/httpresponse.dart';
import 'package:social_app/providers/login_prefs_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/screens/home_screen_layout.dart';
import 'package:social_app/screens/mobile_screen_layout.dart';
import 'package:social_app/screens/signup_screen.dart';
import 'package:social_app/screens/signup_screen_new1.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/global_variable.dart';
import 'package:social_app/utils/login_prefs.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/loading_dialog.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/widgets/text_field_widget.dart';

const String TAG = "FS - LoginScreenNew1 - ";

class LoginScreenNew1 extends StatefulWidget {
  const LoginScreenNew1({Key? key}) : super(key: key);

  @override
  _LoginScreenNew1State createState() => _LoginScreenNew1State();
}

class _LoginScreenNew1State extends State<LoginScreenNew1> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late BuildContext dialogContext;
  GlobalKey _widgetKey = GlobalKey();
  GlobalKey _widgetKeyForLogo = GlobalKey();

  // Set the initial position to something that will be offscreen for sure
  Tween<Offset> tween = Tween<Offset>(
    begin: Offset(10000.0, 0.0),
    end: Offset(0.0, 0.0),
  );
  Tween<Offset> tween2 = Tween<Offset>(
    begin: Offset(10000.0, 0.0),
    end: Offset(0.0, 0.0),
  );
  Tween<Offset> tween3 = Tween<Offset>(
    begin: Offset(0.0, 10000.0),
    end: Offset(0.0, 0.0),
  );
  late Animation<Offset> animation;
  late Animation<Offset> animation2;
  late Animation<Offset> animation3;
  late AnimationController animationController;
  late AnimationController animationController2;
  late AnimationController animationController3;

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    animationController.dispose();
    animationController2.dispose();
    animationController3.dispose();
    super.dispose();
  }

  void initAndAnimateEmailField() {
    // initialize animation controller and the animation itself
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = tween.animate(animationController);

    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      // Get the screen size
      final Size screenSize = MediaQuery.of(context).size;
      // Get render box of the widget
      final RenderBox widgetRenderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
      // Get widget's size
      final Size widgetSize = widgetRenderBox.size;

      // Calculate the dy offset.
      // We divide the screen height by 2 because the initial position of the widget is centered.
      // Ceil the value, so we get a position that is a bit lower the bottom edge of the screen.
      // final double offset = (screenSize.height / 2 / widgetSize.height).ceilToDouble();
      final double offset22 = (screenSize.width / 2 / widgetSize.width).ceilToDouble();

      // Re-set the tween and animation
      tween = Tween<Offset>(
        // begin: Offset(0.0, offset),
        begin: Offset(offset22, 0.0),
        end: const Offset(0.0, 0.0),
      );
      animation = tween.animate(animationController);
      // animation2 = tween.animate(animationController2);

      // Call set state to re-render the widget with the new position.
      setState(() {
        // Animate it.
        animationController.forward();
        // animationController2.forward();
      });
    });
  }

  void initAndAnimatePassField() {
    animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation2 = tween2.animate(animationController2);

    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) {
        log("$TAG Already unmounted i.e. Dispose called");
        return;
      }
      // Get the screen size
      final Size screenSize = MediaQuery.of(context).size;
      // Get render box of the widget
      final RenderBox widgetRenderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
      // Get widget's size
      final Size widgetSize = widgetRenderBox.size;

      // Calculate the dy offset.
      // We divide the screen height by 2 because the initial position of the widget is centered.
      // Ceil the value, so we get a position that is a bit lower the bottom edge of the screen.
      // final double offset = (screenSize.height / 2 / widgetSize.height).ceilToDouble();
      final double offset22 = (screenSize.width / 2 / widgetSize.width).ceilToDouble();

      // Re-set the tween and animation
      tween2 = Tween<Offset>(
        // begin: Offset(0.0, offset),
        begin: Offset(offset22, 0.0),
        end: const Offset(0.0, 0.0),
      );
      // animation = tween.animate(animationController);
      animation2 = tween2.animate(animationController2);

      // Call set state to re-render the widget with the new position.
      setState(() {
        // Animate it.
        // animationController.forward();
        animationController2.forward();
      });
    });
  }

  void initAndAnimateLogo() {
    animationController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation3 = tween3.animate(animationController3);

    try {
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) {
          log("$TAG Already unmounted i.e. Dispose called");
          return;
        }
        // Get the screen size
        final Size screenSize = MediaQuery.of(context).size;
        // Get render box of the widget
        final RenderBox widgetRenderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
        // Get widget's size
        final Size widgetSize = widgetRenderBox.size;

        // Calculate the dy offset.
        // We divide the screen height by 2 because the initial position of the widget is centered.
        // Ceil the value, so we get a position that is a bit lower the bottom edge of the screen.
        final double offset = (screenSize.height / 2 / widgetSize.height).ceilToDouble();
        // final double offset22 = (screenSize.width / 2 / widgetSize.width).ceilToDouble();
        log("offset = $offset");

        // Re-set the tween and animation
        tween3 = Tween<Offset>(
          begin: Offset(0.0, 2.0),
          // begin: Offset(0.0, offset),
          // begin: Offset(offset22, 0.0),
          end: const Offset(0.0, 0.0),
        );
        // animation = tween.animate(animationController);
        animation3 = tween3.animate(animationController3);

        // Call set state to re-render the widget with the new position.
        setState(() {
          // Animate it.
          // animationController.forward();
          animationController3.forward();
        });
      });
    } catch (e) {
      log("Error = ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    initAndAnimateEmailField();
    initAndAnimatePassField();
    initAndAnimateLogo();
  }

  void loginUserViaFirebase() async {
    log('$TAG loginUserViaFirebase():');
    // set loading to true
    // setState(() {
    //   _isLoading = true;
    // });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return LoadingDialog();
        });

    String res = await AuthMethods().loginUser(email: _emailController.text.trim(), password: _passwordController.text);
    log("$TAG res  == $res");
    if (res == 'success') {
      log("$TAG success ---------------------------");
      try {
        Navigator.pop(dialogContext);
        showSnackBar(msg: res, context: context, duration: 1000);
      } on Exception catch (exception) {
        // only executed if error is of type Exception
        log("$TAG exception = ${exception.toString()}");
      } catch (error) {
        // executed for errors of all types other than Exception
        log("$TAG error = ${error.toString()}");
      }

      Future.delayed(const Duration(milliseconds: 600), () {
        log("$TAG calling navigateToHomeScreen() 600");
        navigateToHomeScreen();
        // setState(() {
        //   fiveSecondsPassed = true;
        // });
      });
    } else {
      try {
        Navigator.pop(dialogContext);
        showSnackBar(msg: res, context: context, duration: 2500);
      } on Exception catch (exception) {
        // only executed if error is of type Exception
        log("$TAG exception 2 = ${exception.toString()}");
      } catch (error) {
        // executed for errors of all types other than Exception
        log("$TAG error 2 = ${error.toString()}");
      }
    }
  }

  void loginUserViaServer() async {
    log('$TAG loginUserViaServer():');
    // set loading to true
    // setState(() {
    //   _isLoading = true;
    // });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return LoadingDialog();
        });

    HTTPResponse<Map<String, dynamic>> response = await APIHelper.makeLoginRequest(email: _emailController.text.trim(), password: _passwordController.text);
    // String res = await AuthMethods().loginUser(email: _emailController.text.trim(), password: _passwordController.text);
    if (response.isSuccessful && response.data != null && response.data!.containsKey("data")) {
      Map<String, dynamic> responseData = response.data!;
      log("$TAG success --------------------------- responseData = ${responseData}");
      bool loginSuccess = false;
      try {
        Navigator.pop(dialogContext);
        showSnackBar(msg: response.data!["status_message"], context: context, duration: 1000);
        List data = responseData["data"];
        if(data.isNotEmpty){
          Map loginData = data[0];
          if(loginData.isNotEmpty && loginData.containsKey("id")
              && loginData.containsKey("name") && loginData.containsKey("email")
              && loginData.containsKey("username")){
            Map<String, dynamic> userDetails = {
              "isLoggedIn": true,
              "id": "${loginData['id']}",
              "name": loginData["name"],
              "email": loginData["email"],
              "username": loginData["username"],
            };
            loginSuccess = true;
            final LoginPrefsProvider loginPrefsProvider = Provider.of<LoginPrefsProvider>(context, listen: false);
            loginPrefsProvider.setUserDetails(userDetails, true);
          }
        }
      } on Exception catch (exception) {
        // only executed if error is of type Exception
        log("$TAG exception = ${exception.toString()}");
      } catch (error) {
        // executed for errors of all types other than Exception
        log("$TAG error = ${error.toString()}");
      }

      if(loginSuccess){
        log("$TAG login = true --------------------------- Go to HomeScreen");
        Future.delayed(const Duration(milliseconds: 200), () {
          log("$TAG calling navigateToHomeScreen() 200");
          navigateToHomeScreen();
          // setState(() {
          //   fiveSecondsPassed = true;
          // });
        });
      }else{
        log("$TAG login = false --------------------------- No need to go to HomeScreen");
      }
    } else {
      try {
        Navigator.pop(dialogContext);
        String message = response.message;
        if (!response.isSuccessful){
          message = response.message;
        } else if (response.data != null && response.data!.containsKey("status_message")) {
          message = response.data!["status_message"];
          //todo make message something like, login unsuccessful, make sure email and password is valid
        }
        showSnackBar(msg: message, context: context, duration: 2500);
      } on Exception catch (exception) {
        // only executed if error is of type Exception
        log("$TAG exception 2 = ${exception.toString()}");
      } catch (error) {
        // executed for errors of all types other than Exception
        log("$TAG error 2 = ${error.toString()}");
      }
    }
  }

  void navigateToHomeScreen() {
    log("$TAG navigateToHomeScreen");
    try {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MobileScreenLayout(title: "Home screen"),
          ),
              (route) => false);
    } on Exception catch (exception) {
      // only executed if error is of type Exception
      log("$TAG exception 3 = ${exception.toString()}");
    } catch (error) {
      // executed for errors of all types other than Exception
      log("$TAG error 3 = ${error.toString()}");
    }
  }

  void navigateToSignUpScreen() {
    log("$TAG navigateToSignUpScreen");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignupScreenNew1(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('$TAG build():');
    final model = Provider.of<LoginProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,

      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Login Screen"),
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Ink(
                // color: Colors.blue[800],
                color: appBlueColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              // color: Colors.grey,
              width: double.infinity,
              child: Center(
                // Center is a layout widget. It takes a single child and positions it
                // in the middle of the parent.
                child: Column(
                  key: _widgetKey,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(),
                      flex: 1,
                    ),
                    // SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 64,),

                    SlideTransition(
                      position: animation3,
                      child: Container(
                        // color: Colors.blue,
                          width: 160,
                          child: Image.asset(
                            'assets/images/spot_text_3.png',
                          )),
                      // const Text(
                      //   'SPOT',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 50,
                      //     fontWeight: FontWeight.bold,
                      //     // fontFamily: 'Roboto-Regular',
                      //   ),
                      // ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),

                    Ink(
                      // color: Colors.red,
                      decoration: const BoxDecoration(
                        // borderRadius: BorderRadius.circular(25),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        color: Colors.white,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            // padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Container(
                              // padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              width: double.infinity,
                              // decoration: BoxDecoration(
                              //   borderRadius: BorderRadius.circular(25),
                              //   color: Color(0xFFFFFFFF),
                              //
                              // ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                const SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                                    ),
                                    Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        // fontFamily: 'Roboto-Regular',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                SlideTransition(
                                  position: animation,
                                  child: TextFieldInput(
                                    hintText: 'Email',
                                    textInputType: TextInputType.emailAddress,
                                    textEditingController: _emailController,
                                    // prefixIconData: Icons.mail_outlined,
                                    darkBackground: false,
                                    rounded: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                SlideTransition(
                                  position: animation2,
                                  child: TextFieldInput(
                                    hintText: 'Password',
                                    textInputType: TextInputType.text,
                                    textEditingController: _passwordController,
                                    isPass: model.isVisible ? false : true,
                                    // prefixIconData: Icons.lock_outlined,
                                    suffixIconData: model.isVisible ? Icons.visibility : Icons.visibility_off,
                                    darkBackground: false,
                                    rounded: true,
                                  ),
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          showSnackBar(
                                              msg: "Forgot Password.. Will be implemented soon!",
                                              context: context,
                                              duration: 2000);
                                        },
                                        child: Container(
                                          child: const Text(
                                            "Forgot Password?",
                                            style: TextStyle(
                                                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 60,
                                ),
                                const SizedBox(
                                  height: 27,
                                ),
                              ]),
                            ),
                          ),

                          // ----------- Black Bottom Area Behind Login -----------
                          Positioned(
                            // bottom: -27,
                            bottom: -1,
                            right: 0,
                            left: 0,
                            child: Ink(
                              width: 200,
                              height: 27,
                              color: Colors.black,
                              // decoration: const BoxDecoration(
                              //   // borderRadius: BorderRadius.circular(25),
                              //   // borderRadius: BorderRadius.only(
                              //   //   bottomLeft: Radius.circular(25),
                              //   //   bottomRight: Radius.circular(25),
                              //   // ),
                              //   color: Colors.black,
                              // ),
                            ),
                          ),

                          // ----------- Right Corner -----------
                          Positioned(
                            // bottom: -27,
                            bottom: 25,
                            right: 0,
                            left: null,
                            width: 25,
                            height: 25,
                            child: Container(
                              width: 25,
                              height: 25,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            // bottom: -27,
                            bottom: 26,
                            right: 0,
                            left: null,
                            width: 50,
                            height: 50,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // ----------- Left Corner -----------
                          Positioned(
                            // bottom: -27,
                            bottom: 25,
                            right: null,
                            left: 0,
                            width: 25,
                            height: 25,
                            child: Container(
                              width: 25,
                              height: 25,
                              color: Colors.black,
                            ),
                          ),
                          Positioned(
                            // bottom: -27,
                            bottom: 26,
                            right: null,
                            left: 0,
                            width: 50,
                            height: 50,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                            ),
                          ),

                          // ----------- Login Button -----------
                          Positioned(
                            // bottom: -27,
                            bottom: 0,
                            right: 1,
                            left: 1,
                            child: Center(
                              child: SlideTransition(
                                position: animation3,
                                child: Container(
                                  width: 200,
                                  height: 54,
                                  // color: Colors.blue,
                                  // decoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(25),
                                  //   color: Colors.purple,
                                  //   // gradient: const LinearGradient(
                                  //   //     colors: [
                                  //   //       Colors.blue,
                                  //   //       Colors.deepPurple,
                                  //   //     ],
                                  //   //     stops: [
                                  //   //       0.0,
                                  //   //       100.0
                                  //   //     ],
                                  //   //     begin: FractionalOffset.centerLeft,
                                  //   //     end: FractionalOffset.centerRight,
                                  //   //     tileMode: TileMode.repeated),
                                  // ),

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(25),
                                    onTap: () {
                                      // _showSnackBar("Login... Will be implemented soon!");
                                      FocusScope.of(context).unfocus();
                                      log('Login clicked');
                                      bool error = false;
                                      String errorMsg = "Oops! Something went wrong.";
                                      if (_emailController.text.trim().isEmpty) {
                                        errorMsg = "Please enter a valid email address";
                                        error = true;
                                      } else if (_passwordController.text.trim().isEmpty) {
                                        errorMsg = "Incorrect Password";
                                        error = true;
                                      }

                                      log('Error: $error');
                                      log('ErrorMsg: $errorMsg');
                                      if (!error) {
                                        log('Checking email validity');
                                        bool emailValid = RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(_emailController.text.trim());
                                        if (emailValid) {
                                          FocusScope.of(context).unfocus();

                                          // Fetch user against email.
                                          // if found // user-id, send login request to api
                                          // if not, signup on firebase, on success send login api
                                          // authHandler.handleSignInEmail(
                                          //     userNameController.text.trim(), passwordController.text.trim(), context).then((User? user) {

                                          // signInRequest(_passwordController.text.trim(), _passwordController.text.trim());
                                          if(attachedToFirebase){
                                            loginUserViaFirebase();
                                          }else{
                                            loginUserViaServer();
                                          }
                                          // }).catchError((e){
                                          //       if(e.message == "The email address is already in use by another account."){
                                          //         showAlertDialog(context, e.toString());
                                          //       }else{
                                          //         signInRequest(userNameController.text.trim(), passwordController.text.trim(), false);
                                          //       }
                                          //     });
                                        } else {
                                          showSnackBar(
                                              msg: "Please enter a valid email address",
                                              context: context,
                                              duration: 2000);
                                        }
                                      } else {
                                        showSnackBar(msg: errorMsg, context: context, duration: 2000);
                                      }

                                      // if (_emailController.text.trim().isNotEmpty) {
                                      //   if (_passwordController.text.trim().isNotEmpty) {
                                      //     bool emailValid =
                                      //     RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      //         .hasMatch(_emailController.text.trim());
                                      //     if (emailValid) {
                                      //       showDialog(
                                      //           context: context,
                                      //           barrierDismissible: false,
                                      //           builder: (BuildContext context) {
                                      //             dialogContext = context;
                                      //             return LoadingDialog();
                                      //           });
                                      //
                                      //       // Fetch user against email.
                                      //       // if found // user-id, send login request to api
                                      //       // if not, signup on firebase, on success send login api
                                      //       // authHandler.handleSignInEmail(
                                      //       //     userNameController.text.trim(), passwordController.text.trim(), context).then((User? user) {
                                      //
                                      //       signInRequest(userNameController.text.trim(), passwordController.text.trim());
                                      //
                                      //       // }).catchError((e){
                                      //       //       if(e.message == "The email address is already in use by another account."){
                                      //       //         showAlertDialog(context, e.toString());
                                      //       //       }else{
                                      //       //         signInRequest(userNameController.text.trim(), passwordController.text.trim(), false);
                                      //       //       }
                                      //       //     });
                                      //     } else {
                                      //       setErrorMessage("Wrong username");
                                      //     }
                                      //   } else {
                                      //     setErrorMessage("Wrong password");
                                      //   }
                                      // } else {
                                      //   setErrorMessage("Wrong username");
                                      // }
                                    },
                                    child: Ink(
                                      height: 45,
                                      // color: Colors.blue,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        // color: Colors.blue[800],
                                        color: appBlueColor,
                                        //   gradient: const LinearGradient(
                                        //       colors: [
                                        //         Colors.blue,
                                        //         Colors.deepPurple,
                                        //       ],
                                        //       stops: [
                                        //         0.0,
                                        //         100.0
                                        //       ],
                                        //       begin: FractionalOffset.centerLeft,
                                        //       end: FractionalOffset.centerRight,
                                        //       tileMode: TileMode.repeated),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Login",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            // fontFamily: 'Roboto-Regular',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // const SizedBox(
                    //   height: 44,
                    // ),
                    // //Login button
                    // Container(
                    //   width: 200,
                    //   // color: Colors.blue,
                    //   padding: const EdgeInsets.all(10),
                    //   child: InkWell(
                    //     borderRadius: BorderRadius.circular(25),
                    //     onTap: () {
                    //       showSnackBar(msg: "Login... Will be implemented soon!", context: context, duration: 2000);
                    //     },
                    //     child: Ink(
                    //       height: 45,
                    //       // color: Colors.blue,
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(25),
                    //         // color: Colors.purple,
                    //         gradient: const LinearGradient(
                    //             colors: [
                    //               Colors.blue,
                    //               Colors.deepPurple,
                    //             ],
                    //             stops: [
                    //               0.0,
                    //               100.0
                    //             ],
                    //             begin: FractionalOffset.centerLeft,
                    //             end: FractionalOffset.centerRight,
                    //             tileMode: TileMode.repeated),
                    //       ),
                    //       child: const Center(
                    //         child: Text(
                    //           "Login",
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 18,
                    //             // fontFamily: 'Roboto-Regular',
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(
                      height: 4,
                    ),

                    //Login button
                    // Ink(//color: Colors.red,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(25),
                    //     color: Colors.red,
                    //   ),
                    //   child: Stack(
                    //     clipBehavior: Clip.none,
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    //         width: double.infinity,
                    //         height: 200,
                    //         // color: Colors.blue,
                    //         // padding: const EdgeInsets.all(10),
                    //         child: const Center(
                    //           child: Text(
                    //             "Login",
                    //             textAlign: TextAlign.center,
                    //             style: TextStyle(
                    //               color: Colors.white,
                    //               fontSize: 18,
                    //               // fontFamily: 'Roboto-Regular',
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //       Positioned(
                    //         bottom: -27,
                    //         right:1,left:1,
                    //         child: Center(
                    //           child: Container(
                    //             width: 200,
                    //             // color: Colors.blue,
                    //             padding: const EdgeInsets.all(10),
                    //             child: InkWell(
                    //               borderRadius: BorderRadius.circular(25),
                    //               onTap: () {
                    //                 showSnackBar(msg: "Login... Will be implemented soon!", context: context, duration: 2000);
                    //               },
                    //               child: Ink(
                    //                 height: 45,
                    //                 width: 200,
                    //                 // color: Colors.blue,
                    //
                    //                 decoration: BoxDecoration(
                    //                   borderRadius: BorderRadius.circular(25),
                    //                   color: Colors.blue,
                    //                   // gradient: const LinearGradient(
                    //                   //     colors: [
                    //                   //       Colors.blue,
                    //                   //       Colors.deepPurple,
                    //                   //     ],
                    //                   //     stops: [
                    //                   //       0.0,
                    //                   //       100.0
                    //                   //     ],
                    //                   //     begin: FractionalOffset.centerLeft,
                    //                   //     end: FractionalOffset.centerRight,
                    //                   //     tileMode: TileMode.repeated),
                    //                 ),
                    //                 child: const Center(
                    //                   child: Text(
                    //                     "Login",
                    //                     textAlign: TextAlign.center,
                    //                     style: TextStyle(
                    //                       color: Colors.white,
                    //                       fontSize: 18,
                    //                       // fontFamily: 'Roboto-Regular',
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    Flexible(
                      child: Container(),
                      flex: 1,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        GestureDetector(
                            onTap: () {
                              navigateToSignUpScreen();
                            },
                            child: Container(
                              child: const Text(
                                "Sign up.",
                                style: TextStyle(color: appBlueColor, fontWeight: FontWeight.bold),
                                // style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 18),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
