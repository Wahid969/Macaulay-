import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotification {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  Future<String?> generateToken() async {
    String? token = await firebaseMessaging.getToken();

    DatabaseReference driverRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('token');

    driverRef.set(token);

    firebaseMessaging.subscribeToTopic('drivers');
    firebaseMessaging.subscribeToTopic('users');
    return token;
  }

  startListeningLocation(BuildContext context) async {
    // Handle the case when the app was terminated and is opened by a notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      String tripID = messageRemote!.data['tripID'];

      retriveTripRequestInfo(tripID, context);
    });

    // Handle the case when the app was foreground and is opened by a notification

    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      String tripID = messageRemote!.data['tripID'];
      retriveTripRequestInfo(tripID, context);
    });
    // Handle the case when the app was background and is opened by a notification

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      String tripID = messageRemote!.data['tripID'];
      retriveTripRequestInfo(tripID, context);
    });
  }

  retriveTripRequestInfo(String tripID, context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const Center(
          child: CircleAvatar(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    DatabaseReference tripRequestRef =
        FirebaseDatabase.instance.ref().child('tripRequest');

    tripRequestRef.once().then((datasnapshot) {
      Navigator.pop(context);
      //play notification sound

      double.parse(
          (datasnapshot.snapshot.value! as Map)['pickupLocation']['latitude']);
      double.parse(
          (datasnapshot.snapshot.value! as Map)['pickupLocation']['longitude']);

      //destination
      double.parse((datasnapshot.snapshot.value! as Map)['destinationLocation']
          ['latitude']);
      double.parse((datasnapshot.snapshot.value! as Map)['destinationLocation']
          ['longitude']);

      //address

      (datasnapshot.snapshot.value! as Map)['pickupAddress'];

      (datasnapshot.snapshot.value! as Map)['destinationAddress'];
      (datasnapshot.snapshot.value! as Map)['fullName'];
    });
  }
}
