import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-up error: $e");
    }
  }

  static Future<void> getCurrentUserInfo() async {
    // Get the current user from FirebaseAuth
   currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Get the user ID from the current user
      String userId = currentUser!.uid;

      // Reference to the user node in the Firebase Realtime Database
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users/$userId');

      try {
        // Retrieve the data from the database
        final DatabaseEvent event = await userRef.once();
        final DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists) {
          // Convert snapshot value to a map and create a User instance
          Map<String, dynamic> userData =
              Map<String, dynamic>.from(snapshot.value as Map);
           userInfo = userModel.User.fromMap(userData);

          // Do something with the User instance, e.g., print it or use it in your app
          print('User data: ${userInfo!.fullName}');
        } else {
          print('No data available for user');
        }
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    } else {
      print('No user is currently signed in');
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

      // Optionally, navigate to a different screen or update the UI
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-in error: $e");
    }
  }
}
