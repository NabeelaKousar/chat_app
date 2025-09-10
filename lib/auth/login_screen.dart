import 'dart:developer';
import 'package:chat_app/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';

// For getting screen size
late Size mq;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  // Handle button click
  _handleGoogleBtnClick() async {
    Dialogs.showProgressBar(context);
      Navigator.pop(context);

    try {
      UserCredential user = await _signInWithGoogle();

      log("User Email: ${user.user?.email}");
      log("User Name: ${user.user?.displayName}");
      log("Additional Info: ${user.additionalUserInfo?.profile}");
       if ( await APIs.userExists()){
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (_) =>  HomeScreen()),
         );
       }
       else{
         APIs.createUser().then((value)=>{});
       }



    } catch (e) {
      log('Google Sign-In Failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed. Please try again.')),
      );
    }
  }


  // Google sign-in method
  Future<UserCredential> _signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Sign-in cancelled by user');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await APIs.auth.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Chatting App'),
      ),
      body: Stack(
        children: [
          // Logo animation
          AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 3),
            child: Image.asset('images/chat.png', height: 100, width: 100),
          ),

          // Google sign-in button
          Positioned(
            bottom: mq.height * .15,
            left: mq.height * .04,
            width: mq.width * .9,
            height: mq.height * .08,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                shape: const StadiumBorder(),
                elevation: 6,
              ),
              onPressed: _handleGoogleBtnClick,
              icon: Image.asset('images/google.png', height: mq.height * .04),
              label: const Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(text: ' Sign In with'),
                    TextSpan(
                      text: ' Google',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
