import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:imaginify/my_global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  static var auth = FirebaseAuth.instance;
  static var db = FirebaseFirestore.instance;

  static Future<bool> isLoggedIn() async {
    MyGlobal.prefs ??= await SharedPreferences.getInstance();

    final bool? isLoggedInBefore = MyGlobal.prefs?.getBool('isLoggedInBefore');

    if (isLoggedInBefore == null || isLoggedInBefore == false) {
      auth.signOut();
      return false;
    } else {
      if (auth.currentUser != null) {
        return true;
      }
    }
    return false;
  }

  static Future<UserCredential?> signInWithGoogle(
      {required Function callback}) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth == null) {
      callback(null);
      return null;
    }

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    callback(userCredential);

    return userCredential;
  }

  static Future<UserCredential> signInWithApple(
      {required Function callback}) async {
    final appleProvider = AppleAuthProvider();

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithProvider(appleProvider);
    callback(userCredential);

    return userCredential;
  }

  static Future<http.Response> generateImage(String prompt) {
    return http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${MyGlobal.openaiKey}'
      },
      body: jsonEncode(
          <String, Object>{'prompt': prompt, 'n': 1, 'size': "512x512"}),
    );
  }

  static Future<int> getUserCoins() async {
    final ds = await db.collection('users').doc(auth.currentUser!.uid).get();
    if (ds.exists) {
      final data = ds.data()!;
      final coins = data['coins'] as int;
      return coins;
    }
    return 0;
  }

  static Future increaseUserCoins(int coins) async {
    await db
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set({'coins': FieldValue.increment(coins)}, SetOptions(merge: true));
  }

  static Future decreaseUserCoins(int coins) async {
    await db
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set({'coins': FieldValue.increment(-coins)}, SetOptions(merge: true));
  }

  static Future<int> getUserData() async {
    final ds = await db.collection('users').doc(auth.currentUser!.uid).get();
    if (ds.exists) {
      final data = ds.data()!;
      final coins = data['coins'] as int;

      return coins;
    } else {
      // Map<String, dynamic> map = {};
      // map['coins'] = 10;
      // db.collection('users').doc(auth.currentUser!.uid).set(map);

      return 0;
    }
  }
}
