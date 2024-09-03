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

      // Retrieve user type from Firebase Realtime Database
      DatabaseReference userRef =
          _firebaseDatabase.ref().child('users/${credential.user!.uid}');
      DataSnapshot snapshot = (await userRef.once()) as DataSnapshot;

      if (!snapshot.exists) {
        // If not found in users, check the drivers collection
        userRef = _firebaseDatabase.ref().child('drivers/${credential.user!.uid}');
        snapshot = (await userRef.once()) as DataSnapshot;
      }

      Map<String, dynamic> userData = Map<String, dynamic>.from(snapshot.value as Map);
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

  Future<void> switchUserType(BuildContext context) async {
    String userId = _auth.currentUser!.uid;
    DatabaseReference userRef;

    // Check which collection the user belongs to and switch accordingly
    if (userInfo!.userType == 'normal') {
      userRef = _firebaseDatabase.ref().child('users/$userId');
    } else {
      userRef = _firebaseDatabase.ref().child('drivers/$userId');
    }

    // Toggle between normal and driver
    String newUserType = userInfo!.userType == 'normal' ? 'driver' : 'normal';

    await userRef.update({
      'userType': newUserType,
    });

    // Move the user to the new collection if switching types
    if (newUserType == 'driver') {
      DatabaseReference newRef = _firebaseDatabase.ref().child('drivers/$userId');
      await newRef.set(userInfo!.toMap()); // Move data to drivers collection
      await userRef.remove(); // Remove data from users collection
    } else {
      DatabaseReference newRef = _firebaseDatabase.ref().child('users/$userId');
      await newRef.set(userInfo!.toMap()); // Move data to users collection
      await userRef.remove(); // Remove data from drivers collection
    }

    // Update the local userInfo variable
    userInfo!.userType = newUserType;

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
