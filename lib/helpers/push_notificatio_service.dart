import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wahid_uber_app/driver/models/trip_details.dart';
import 'package:wahid_uber_app/driver/views/screens/widgets/noficationDialog_widget.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  Future<void> initialize(BuildContext context) async {
    NotificationSettings settings = await fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');

      if (message.notification != null) {
        RemoteNotification notification = message.notification!;
        print('Message Title: ${notification.title}');
        print('Message Body: ${notification.body}');
      }

      if (message.data.isNotEmpty) {
        print('Message Data: ${message.data}');
        String? riderID = message.data['rideId']; // Adjust the key as needed
        if (riderID != null) {
          fetchRideInfo(context, riderID);
        } else {
          print('Rider ID is null');
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      if (message.data.isNotEmpty) {
        String? riderID = message.data['rideId'];
        if (riderID != null) {
          fetchRideInfo(context, riderID);
        } else {
          print('Rider ID is null');
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
    if (message.data.isNotEmpty) {
      String? riderID = message.data['rideId'];
      if (riderID != null) {
        print('Rider ID from background: $riderID');
      } else {
        print('Rider ID is null in background message');
      }
    }
  }

  Future<String> fetchToken(User currentDriverUser) async {
    String? token = await fcm.getToken();
    if (token != null) {
      DatabaseReference tokenRef = FirebaseDatabase.instance
          .ref()
          .child('drivers/${currentDriverUser.uid}/token');

      await tokenRef.set(token); // Use await to ensure the token is set
      await fcm.subscribeToTopic('alldrivers');
      await fcm.subscribeToTopic('allusers');
      return token;
    } else {
      throw Exception("Failed to fetch FCM token");
    }
  }

  void fetchRideInfo(BuildContext context, String rideID) async {
    DatabaseReference rideRef =
        FirebaseDatabase.instance.ref().child('rideRequest/$rideID');

    await rideRef.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        print('Ride info: ${snapshot.value}');
        var rideData = snapshot.value as Map<dynamic, dynamic>;

        try {
          double pickupLat =
              double.parse(rideData['location']['latitude'].toString());
          double pickupLng =
              double.parse(rideData['location']['longitude'].toString());
          String pickUpAddress = rideData['pickUpAddress'] ?? 'Unknown Address';
          double destinationLat =
              double.parse(rideData['destination']['latitude'].toString());
          double destinationLng =
              double.parse(rideData['destination']['longitude'].toString());
          String destinationAddress =
              rideData['destinationAddress'] ?? 'Unknown Address';
          String paymentMethod =
              rideData['payment'] ?? 'Unknown Payment Method';

          TripDetails tripDetails = TripDetails();
          tripDetails.rideID = rideID;
          tripDetails.pickupAddress = pickUpAddress;
          tripDetails.destinationAdddress = destinationAddress;
          tripDetails.pickup = LatLng(pickupLat, pickupLng);
          tripDetails.destination = LatLng(destinationLat, destinationLng);
          tripDetails.paymentMethod = paymentMethod;

          // Show the custom dialog with the ride details
          showRideDetailsDialog(context, tripDetails);
        } catch (e) {
          print('Error parsing ride data: $e');
        }
      } else {
        print('No data available for this ride ID');
      }
    }).catchError((error) {
      print('Failed to retrieve ride info: $error');
    });
  }

  void showRideDetailsDialog(BuildContext context, TripDetails tripDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NoficationdialogWidget(tripDetails: tripDetails);
      },
    );
  }
}
