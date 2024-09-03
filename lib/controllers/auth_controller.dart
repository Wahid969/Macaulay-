import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/views/screens/bottomNavigation_Screens/main_page.dart';
import 'package:wahid_uber_app/models/user.dart'
    as userModel; // Adjust the path accordingly

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      DatabaseReference userRef =
          _firebaseDatabase.ref().child('users/${credential.user!.uid}');

      Map<String, dynamic> userMap = {
        'fullName': fullName,
        'email': email,
        'password': password,
      };

      await userRef.set(userMap);

      // Welcome message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Welcome aboard, $fullName! Your journey starts here!',
            style: GoogleFonts.montserrat(fontSize: 16.0),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the main page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-up error: $e");

      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚨 Oops! Something went wrong. Please try signing up again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 16.0),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<void> getCurrentUserInfo() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String userId = currentUser!.uid;
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users/$userId');

      try {
        final DatabaseEvent event = await userRef.once();
        final DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(snapshot.value as Map);
          userInfo = userModel.User.fromMap(userData);

          // Success message
          print('🌟 User data successfully retrieved: ${userInfo!.fullName}');
        } else {
          print('⚠️ No data available for this user.');
        }
      } catch (e) {
        print('❌ Error retrieving user data: $e');
      }
    } else {
      print('⚠️ No user is currently signed in.');
    }
  }

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Welcome back message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '👋 Welcome back! Let\'s get you where you need to go!',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 16.0),
          ),
          backgroundColor: Colors.blue,
        ),
      );

      // Navigate to the main page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-in error: $e");

      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚨 Uh-oh! There was a problem signing you in. Please check your credentials and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 16.0),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
