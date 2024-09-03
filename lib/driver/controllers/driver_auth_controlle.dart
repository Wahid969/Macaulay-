import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wahid_uber_app/driver/views/auth/vehicle_details_screen.dart';
import 'package:wahid_uber_app/driver/views/screens/driver_main_screen.dart';
import 'package:wahid_uber_app/global_variables.dart';

class DriverAuthController {
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
          _firebaseDatabase.ref().child('drivers/${credential.user!.uid}');

      Map<String, dynamic> userMap = {
        'fullName': fullName,
        'email': email,
        'password': password,
      };

      await userRef.set(userMap);

      currentDriverUser = credential;

      // Success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚗 Welcome, $fullName! Let\'s get your vehicle details set up!',
            style: TextStyle(fontSize: 16.0),
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the Vehicle Details screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const VehicleDetailsScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-up error: $e");

      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚨 Oops! Something went wrong during sign-up. Please try again.',
            style: TextStyle(fontSize: 16.0),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void updateProfile({
    required String carColor,
    required String carModel,
    required String vehicleNumber,
    required BuildContext context,
  }) async {
    String id = currentDriverUser!.user!.uid;

    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child('drivers/$id/vehicle_info');

    Map<String, String> map = {
      'carColor': carColor,
      'carModel': carModel,
      'vehicleNumber': vehicleNumber,
    };

    await driverRef.set(map);

    // Success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚙 Your vehicle information has been updated! Ready to hit the road?',
          style: TextStyle(fontSize: 16.0),
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to the Driver Main Screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => DriverMainScreen()),
      (route) => false,
    );
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

      // Set the currentDriverUser after login
      currentDriverUser = credential;

      // Welcome back message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '👋 Welcome back, driver! Let\'s get you on the road!',
            style: TextStyle(fontSize: 16.0),
          ),
          backgroundColor: Colors.blue,
        ),
      );

      // Navigate to the Driver Main Screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => DriverMainScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Sign-in error: $e");

      // Error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🚨 Uh-oh! There was a problem signing you in. Please check your credentials and try again.',
            style: TextStyle(fontSize: 16.0),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
