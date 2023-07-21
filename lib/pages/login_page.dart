import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:imaginify/api.dart';
import 'package:imaginify/my_global.dart';
import 'package:imaginify/pages/home_page.dart';
import 'package:imaginify/my_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _visible = !_visible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: SizedBox(
              width: 200,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1500),
                child: Image.asset('images/imaginify_logo.png'),
              ),
            ),
          ),
          const Spacer(),
          ClipPath(
            clipper: WaveClipperTwo(reverse: true),
            child: Container(
              height: (MediaQuery.of(context).size.height / 2) - 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [Color(0xffbdc3c7), Color(0xff2c3e50)],
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Sign In',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontFamily: 'RobotoLight'),
                      ),
                      SizedBox(height: 50),
                      FilledButton(
                        onPressed: () {
                          MyWidgets.showLoaderDialog(context);
                          API.signInWithGoogle(
                              callback: (UserCredential? credential) async {
                            Navigator.pop(context);
                            _goToHomePage(context, credential);
                          });
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.white),
                        child: SizedBox(
                          width: double.infinity,
                          height: 20,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: Image.asset(
                                  'images/google.webp',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              const Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (Platform.isIOS) ...[
                        FilledButton(
                          onPressed: () {
                            API.signInWithApple(
                                callback: (UserCredential? credential) {
                              _goToHomePage(context, credential);
                            });
                          },
                          style: FilledButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const SizedBox(
                            width: double.infinity,
                            height: 20,
                            child: Stack(
                              children: [
                                Positioned(
                                    left: 0,
                                    child: Icon(
                                      Icons.apple,
                                      size: 20,
                                      color: Colors.black,
                                    )),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sign in with Apple',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToHomePage(BuildContext context, UserCredential? credential) async {
    if (credential != null && credential.user != null) {
      await MyGlobal.prefs?.setBool('isLoggedInBefore', true);

      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }
}
