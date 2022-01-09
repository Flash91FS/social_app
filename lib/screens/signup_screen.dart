import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_app/utils/colors.dart';
import 'package:social_app/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text("Signup Screen"),
      // ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          // color: Colors.blue,
          width: double.infinity,
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Container(
              // color: Colors.red,
              child: Column(
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
                  const SizedBox(height: 64,),
                  const Text(
                    'Signup',
                    style: TextStyle(
                      // color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      // fontFamily: 'Roboto-Regular',
                    ),
                  ),
                  const SizedBox(height: 34,),
                  Stack(children:[
                    const CircleAvatar(radius: 64,
                      backgroundImage: NetworkImage(
                          'https://i.stack.imgur.com/l60Hf.png'),
                      backgroundColor: Colors.white,),
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
                  const SizedBox(height: 34,),
                  TextFieldInput(
                    hintText: 'Enter your username',
                    textInputType: TextInputType.text,
                    textEditingController: _usernameController,
                  ),
                  const SizedBox(height: 24,),
                  TextFieldInput(
                    hintText: 'Enter your email',
                    textInputType: TextInputType.emailAddress,
                    textEditingController: _emailController,
                  ),
                  const SizedBox(height: 24,),
                  TextFieldInput(
                    hintText: 'Enter your password',
                    textInputType: TextInputType.text,
                    textEditingController: _passwordController,
                    isPass: true,
                  ),

                  const SizedBox(height: 24,),
                  TextFieldInput(
                    hintText: 'Enter your bio',
                    textInputType: TextInputType.text,
                    textEditingController: _bioController,
                  ),
                  const SizedBox(height: 24,),

                  //Login button
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () {
                        _showSnackBar("Signup... Will be implemented soon!");
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
                    mainAxisAlignment:MainAxisAlignment.center,
                    children: [
                      Container(child: const Text("Already have an account? "), padding: const EdgeInsets.symmetric(vertical: 18),),
                      GestureDetector( onTap: () {
                        _showSnackBar("Login.. Will be implemented soon!");
                      },
                          child: Container(child: const Text("Login.", style: TextStyle( color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),), padding: EdgeInsets.symmetric(vertical: 18),)),
                    ],),
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

  void _showSnackBar(String s) {
    const Duration _snackBarDisplayDuration = Duration(milliseconds: 500);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s),
        duration: _snackBarDisplayDuration,
      ),
    );
  }

  void selectImage() {
  }
}
