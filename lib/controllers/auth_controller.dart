import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wahid_uber_app/driver/views/screens/driver_main_screen.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/views/screens/bottomNavigation_Screens/main_page.dart';
import 'package:wahid_uber_app/models/user.dart' as userModel;

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<void> signUpUsers({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
    String userType = 'normal', // Default user type
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Determine the correct collection based on the user type
      String collection = userType == 'driver' ? 'drivers' : 'users';

      // Reference the correct collection
      DatabaseReference userRef =
          _firebaseDatabase.ref().child('$collection/${credential.user!.uid}');

      Map<String, dynamic> userMap = {
        'id': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'phone': '', // Initialize as empty or handle separately
        'password': password,
        'token': '', // Initialize or handle token generation
        'userType': userType, // Store user type in the database
      };

      await userRef.set(userMap);

      // Set global current user info
      userInfo = userModel.User.fromMap(userMap);

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

      // Navigate to the appropriate main page based on user type
      _navigateToMainPage(context, userType);
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

  Future<void> signInUsers({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Determine the correct collection based on the user type
      DatabaseReference userRef =
          _firebaseDatabase.ref().child('users/${credential.user!.uid}');
      DataSnapshot snapshot = await userRef.get();

      if (!snapshot.exists) {
        // If not found in users, check the drivers collection
        userRef =
            _firebaseDatabase.ref().child('drivers/${credential.user!.uid}');
        snapshot = await userRef.get();
      }

      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        userInfo = userModel.User.fromMap(userData);
        String userType = userInfo!.userType;

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

        // Navigate to the appropriate main page based on user type
        _navigateToMainPage(context, userType);
      } else {
        throw Exception("User data not found");
      }
    } catch (e) {
      print("Sign-in error: $e");
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

  Future<void> switchUserType(BuildContext context) async {
    String userId = _auth.currentUser!.uid;
    DatabaseReference oldRef;
    DatabaseReference newRef;

    // Determine the current collection based on the user type
    if (userInfo!.userType == 'normal') {
      oldRef = _firebaseDatabase.ref().child('users/$userId');
      newRef = _firebaseDatabase.ref().child('drivers/$userId');
    } else {
      oldRef = _firebaseDatabase.ref().child('drivers/$userId');
      newRef = _firebaseDatabase.ref().child('users/$userId');
    }

    // Toggle between 'normal' and 'driver'
    String newUserType = userInfo!.userType == 'normal' ? 'driver' : 'normal';

    try {
      // Update the userType in the old collection
      await oldRef.update({'userType': newUserType});

      // Move the user to the new collection
      await newRef.set(userInfo!.toMap()); // Move data to the new collection
      await oldRef.remove(); // Remove data from the old collection

      // Fetch the updated data from the new collection
      DataSnapshot snapshot = await newRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        Map<String, dynamic> updatedUserData =
            Map<String, dynamic>.from(snapshot.value as Map);

        // Update the local userInfo object
        userInfo = userModel.User.fromMap(updatedUserData);

        // Display a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🚗 You are now in ${newUserType == 'driver' ? 'Driver' : 'User'} mode!',
              style: GoogleFonts.montserrat(fontSize: 16.0),
            ),
            backgroundColor: Colors.blue,
          ),
        );

        // Navigate to the appropriate main page
        _navigateToMainPage(context, newUserType);
      } else {
        throw Exception("User data not found after switch");
      }
    } catch (e) {
      print("Error switching user type: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚨 Error switching user type. Please try again.',
            style: GoogleFonts.montserrat(fontSize: 16.0),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToMainPage(BuildContext context, String userType) {
    if (userType == 'driver') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DriverMainScreen()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    }
  }
}
