import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_app/providers/login_provider.dart';
import 'package:social_app/resources/auth_methods.dart';
import 'package:social_app/screens/login_screen.dart';
import 'package:social_app/widgets/loading_dialog.dart';
import 'package:social_app/widgets/text_field_input.dart';
import 'package:social_app/widgets/text_field_widget.dart';
import 'package:social_app/utils/utils.dart';
import 'package:social_app/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with SingleTickerProviderStateMixin {
  // int _counter = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late BuildContext dialogContext;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    animationController.dispose();
    // animationController2.dispose();
  }

  // void _incrementCounter() {
  //   setState(() {
  //     // This call to setState tells the Flutter framework that something has
  //     // changed in this State, which causes it to rerun the build method below
  //     // so that the display can reflect the updated values. If we changed
  //     // _counter without calling setState(), then the build method would not be
  //     // called again, and so nothing would appear to happen.
  //     _counter++;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LoginProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Login Screen"),
      // ),
      body: SafeArea(
        child: Container(
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
                const Text(
                  'Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'Roboto-Regular',
                  ),
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
                              child: TextFieldWidget(
                                hintText: 'Email',
                                textInputType: TextInputType.emailAddress,
                                textEditingController: _emailController,
                                prefixIconData: Icons.mail_outlined,
                                darkBackground: false,
                              ),
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            SlideTransition(
                              position: animation,
                              child: TextFieldWidget(
                                hintText: 'Password',
                                textInputType: TextInputType.text,
                                textEditingController: _passwordController,
                                isPass: model.isVisible ? false : true,
                                prefixIconData: Icons.lock_outlined,
                                suffixIconData: model.isVisible ? Icons.visibility : Icons.visibility_off,
                                darkBackground: false,
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
                                        style:
                                        TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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
                      // Positioned(
                      //   // bottom: -27,
                      //   bottom: 0,
                      //   right: 1,
                      //   left: 1,
                      //   child: Center(
                      //     child: Container(
                      //       width: 200,
                      //       height: 54,
                      //       // color: Colors.blue,
                      //       // decoration: BoxDecoration(
                      //       //   borderRadius: BorderRadius.circular(25),
                      //       //   color: Colors.purple,
                      //       //   // gradient: const LinearGradient(
                      //       //   //     colors: [
                      //       //   //       Colors.blue,
                      //       //   //       Colors.deepPurple,
                      //       //   //     ],
                      //       //   //     stops: [
                      //       //   //       0.0,
                      //       //   //       100.0
                      //       //   //     ],
                      //       //   //     begin: FractionalOffset.centerLeft,
                      //       //   //     end: FractionalOffset.centerRight,
                      //       //   //     tileMode: TileMode.repeated),
                      //       // ),
                      //
                      //       child: InkWell(
                      //         borderRadius: BorderRadius.circular(25),
                      //         onTap: () {
                      //           showSnackBar(
                      //               msg: "Login... Will be implemented soon!", context: context, duration: 2000);
                      //           // signOutUser();
                      //         },
                      //         child: Ink(
                      //           height: 45,
                      //           // color: Colors.blue,
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(25),
                      //             color: Colors.blue,
                      //             //   gradient: const LinearGradient(
                      //             //       colors: [
                      //             //         Colors.blue,
                      //             //         Colors.deepPurple,
                      //             //       ],
                      //             //       stops: [
                      //             //         0.0,
                      //             //         100.0
                      //             //       ],
                      //             //       begin: FractionalOffset.centerLeft,
                      //             //       end: FractionalOffset.centerRight,
                      //             //       tileMode: TileMode.repeated),
                      //           ),
                      //           child: const Center(
                      //             child: Text(
                      //               "Login",
                      //               textAlign: TextAlign.center,
                      //               style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 18,
                      //                 // fontFamily: 'Roboto-Regular',
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      // ----------- Black Bottom Area Behind Login -----------
                      Positioned(
                        // bottom: -27,
                        bottom: -1,
                        right: 0,
                        left: 0,
                        child: Ink(
                          width: 200,
                          height: 27,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
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
                                // showSnackBar(
                                // msg: "Login... Will be implemented soon!", context: context, duration: 2000);
                                signOutUser();
                              },
                              child: Ink(
                                height: 45,
                                // color: Colors.blue,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.blue,
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


              ],
            ),
          ),
        ),
      ),
    );

  }

  //========================================================================================================

  // Set the initial position to something that will be offscreen for sure
  Tween<Offset> tween = Tween<Offset>(
    begin: Offset(10000.0, 0.0),
    end: Offset(0.0, 0.0),
  );
  late Animation<Offset> animation;
  late AnimationController animationController;

  // late Animation<Offset> animation2;
  // late AnimationController animationController2;

  GlobalKey _widgetKey = GlobalKey();

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

  void signOutUser() async {
    await AuthMethods().signOut();
    showSnackBar(msg: "Sign Out Success!", context: context, duration: 500);
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
            (route) => false);
  }

// @override
// void dispose() {
//   // Don't forget to dispose the animation controller on class destruction
//   animationController.dispose();
//   super.dispose();
// }

// @override
// Widget build(BuildContext context) {
//   return Stack(
//     alignment: Alignment.center,
//     fit: StackFit.loose,
//     children: <Widget>[
//       SlideTransition(
//         position: animation,
//         child: CircleAvatar(
//           key: _widgetKey,
//           backgroundImage: NetworkImage(
//             'https://pbs.twimg.com/media/DpeOMc3XgAIMyx_.jpg',
//           ),
//           radius: 50.0,
//         ),
//       ),
//     ],
//   );
// }
}
