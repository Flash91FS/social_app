import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/home_screen_layout.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/widgets/loading_dialog.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/widgets/text_field_widget.dart';

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Uint8List? _image;
  late BuildContext dialogContext;
  GlobalKey _widgetKey = GlobalKey();
  // Set the initial position to something that will be offscreen for sure
  Tween<Offset> tween = Tween<Offset>(
    begin: Offset(10000.0, 0.0),
    end: Offset(0.0, 0.0),
  );
  late Animation<Offset> animation;
  late AnimationController animationController;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    animationController.dispose();
  }

  @override
  void initState() {
    super.initState();

    // initialize animation controller and the animation itself
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    animation = tween.animate(animationController);
    // animationController2 = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 500),
    // );
    // animation2 = tween.animate(animationController2);

    Future<void>.delayed(const Duration(milliseconds: 200), () {
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

  Future<void> selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {

    final model = Provider.of<LoginProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Signup Screen"),
      // ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          // color: Colors.blue,
          width: double.infinity,
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Container(
              // color: Colors.red,
              child: Column(
                key: _widgetKey,
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(),
                    flex: 1,
                  ),
                  // SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 64,),
                  const SizedBox(
                    height: 18,
                  ),
                  const Text(
                    'Signup',
                    style: TextStyle(
                      // color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Roboto-Regular',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor: Colors.white,
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundImage: NetworkImage('https://i.stack.imgur.com/l60Hf.png'),
                              backgroundColor: Colors.white,
                            ),
                      Positioned(
                        bottom: -10,
                        left: 80,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 34,
                  ),

                  SlideTransition(
                    position: animation,
                    child: TextFieldWidget(
                      hintText: 'Full Name',
                      textInputType: TextInputType.text,
                      textEditingController: _bioController,
                      prefixIconData: Icons.account_circle_outlined,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // TextFieldInput(
                  //   hintText: 'Enter your username',
                  //   textInputType: TextInputType.text,
                  //   textEditingController: _usernameController,
                  // ),
                  SlideTransition(
                    position: animation,
                    child: TextFieldWidget(
                      hintText: 'Username',
                      textInputType: TextInputType.text,
                      textEditingController: _usernameController,
                      prefixIconData: Icons.account_circle_outlined,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  // TextFieldInput(
                  //   hintText: 'Enter your email',
                  //   textInputType: TextInputType.emailAddress,
                  //   textEditingController: _emailController,
                  // ),
                  SlideTransition(
                    position: animation,
                    child: TextFieldWidget(
                      hintText: 'Email',
                      textInputType: TextInputType.emailAddress,
                      textEditingController: _emailController,
                      prefixIconData: Icons.mail_outlined,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),

                  // TextFieldInput(
                  //   hintText: 'Enter your password',
                  //   textInputType: TextInputType.text,
                  //   textEditingController: _passwordController,
                  //   isPass: true,
                  // ),

                  SlideTransition(
                    position: animation,
                    child: TextFieldWidget(
                      hintText: 'Password',
                      textInputType: TextInputType.text,
                      textEditingController: _passwordController,
                      isPass: model.isVisible ? false : true,
                      prefixIconData: Icons.lock_outlined,
                      suffixIconData: model.isVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  SlideTransition(
                    position: animation,
                    child: TextFieldWidget(
                      hintText: 'Confirm Password',
                      textInputType: TextInputType.text,
                      textEditingController: _confirmPasswordController,
                      isPass: model.isVisible ? false : true,
                      prefixIconData: Icons.lock_outlined,
                      suffixIconData: model.isVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // TextFieldInput(
                  //   hintText: 'Enter your bio',
                  //   textInputType: TextInputType.text,
                  //   textEditingController: _bioController,
                  // ),
                  //
                  // const SizedBox(
                  //   height: 24,
                  // ),

                  //Login button
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        // _showSnackBar("Signup... Will be implemented soon!");
                        FocusScope.of(context).unfocus();
                        log('Sign Up clicked');
                        bool error = false;
                        String errorMsg = "Oops! Something went wrong.";
                        if (_usernameController.text.trim().isEmpty) {
                          errorMsg = "Username must not be empty";
                          error = true;
                          // log("Username must not be empty");
                        } else if (_emailController.text.trim().isEmpty) {
                          errorMsg = "Please enter a valid email address";
                          error = true;
                        } else if (_passwordController.text.trim().isEmpty) {
                          errorMsg = "Password must not be empty";
                          error = true;
                        } else if (_confirmPasswordController.text.trim().isEmpty || (_confirmPasswordController.text.trim() != _passwordController.text.trim())) {
                          errorMsg = "Passwords not matching";
                          error = true;
                        // } else if (_confirmPasswordController.text.trim() != _passwordController.text.trim()) {
                        //   errorMsg = "Passwords not matching";
                        //   error = true;
                        } else if (_bioController.text.trim().isEmpty) {
                          errorMsg = "Please enter your full name";
                          error = true;
                        } else if (_image == null) {
                          errorMsg = "Profile picture must be set";
                          error = true;
                        }

                        log('Error: $error');
                        log('ErrorMsg: $errorMsg');
                        if (!error) {
                          log('Checking email validity');
                          bool emailValid =
                              RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(_emailController.text.trim());
                          if (emailValid) {
                            FocusScope.of(context).unfocus();

                            // Fetch user against email.
                            // if found // user-id, send login request to api
                            // if not, signup on firebase, on success send login api
                            // authHandler.handleSignInEmail(
                            //     userNameController.text.trim(), passwordController.text.trim(), context).then((User? user) {

                            // signInRequest(_passwordController.text.trim(), _passwordController.text.trim());
                            signUpUser();
                            // }).catchError((e){
                            //       if(e.message == "The email address is already in use by another account."){
                            //         showAlertDialog(context, e.toString());
                            //       }else{
                            //         signInRequest(userNameController.text.trim(), passwordController.text.trim(), false);
                            //       }
                            //     });
                          } else {
                            showSnackBar(msg: "Please enter a valid email address", context: context, duration: 2000);
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
                          // color: Colors.purple,
                          gradient: const LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.deepPurple,
                              ],
                              stops: [
                                0.0,
                                100.0
                              ],
                              begin: FractionalOffset.centerLeft,
                              end: FractionalOffset.centerRight,
                              tileMode: TileMode.repeated),
                        ),
                        child: const Center(
                          child: Text(
                            "Signup",
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

                  Flexible(
                    child: Container(),
                    flex: 1,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: const Text("Already have an account? "),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      GestureDetector(
                          onTap: () {
                            // showSnackBar(msg:"Login.. Will be implemented soon!", context: context);
                            navigateToLogin();
                          },
                          child: Container(
                            child: const Text(
                              "Login.",
                              style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void signUpUser() async {
    log('signUpUser():');
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

    // signup user using our authmethodds
    String res = await AuthMethods().signUpUser(
        email: _emailController.text,
        pass: _passwordController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        imgFile: _image!);
    // if string returned is sucess, user has been created
    log("result: $res");
    if (res == "success") {
      // setState(() {
      //   _isLoading = false;
      // });
      // navigate to the home screen
      try {
        Navigator.pop(dialogContext);
        showSnackBar(msg: res, context: context, duration: 1500);
      } on Exception catch (exception) {
        // only executed if error is of type Exception
        Navigator.pop(dialogContext);
      } catch (error) {
        // executed for errors of all types other than Exception
        Navigator.pop(dialogContext);
      }

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomeScreenLayout(title: "Home screen"),
          ),
          (route) => false);
    } else {
      // setState(() {
      //   _isLoading = false;
      // });
      // show the error

      try {
        Navigator.pop(dialogContext);
        showSnackBar(msg: res, context: context, duration: 2500);
      } on Exception catch (exception) {
        // only executed if error is of type Exception
        Navigator.pop(dialogContext);
      } catch (error) {
        // executed for errors of all types other than Exception
        Navigator.pop(dialogContext);
      }
    }
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }
}
