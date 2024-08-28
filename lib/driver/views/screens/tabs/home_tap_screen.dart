import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wahid_uber_app/controllers/location_controller.dart';
import 'package:wahid_uber_app/driver/views/screens/widgets/confirm_dialog.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/helpers/push_notificatio_service.dart';

class HomeTapScreen extends StatefulWidget {
  const HomeTapScreen({super.key});

  @override
  State<HomeTapScreen> createState() => _HomeTapScreenState();
}

class _HomeTapScreenState extends State<HomeTapScreen> {
  GoogleMapController? _mapController;
  final LocationSettings locationPostionSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4);

  final LocationController _locationController = LocationController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  String availabilyTitle = 'GO ONLINE';
  List<Color> availabilityColors = [
    const Color(0xFF102DE1),
    const Color(0xCC0D6EFF),
  ];
  bool isAvailable = false;

  Future<void> getCurrenDriverInfo() async {
  User? currentDriverUser = FirebaseAuth.instance.currentUser;

  if (currentDriverUser != null) {
    PushNotificationService pushNotificationService =
        PushNotificationService();

    await pushNotificationService.initialize(context);
    String token = await pushNotificationService.fetchToken(currentDriverUser);
    print('FCM Token: $token');
  } else {
    print('No user is currently signed in.');
  }
}

  @override
  void initState() {
    getCurrenDriverInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: const EdgeInsets.only(top: 135),
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          mapType: MapType.terrain,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;

            _controller.complete(controller);
            _locationController.setGoogleMapController(_mapController!);
            _locationController.getCurrentUserLocation(context);
          },
        ),
        Container(
          height: 125,
          width: double.infinity,
          color: Colors.black,
        ),
        Positioned(
          top: 60,
          right: 0,
          left: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                splashColor: Colors.pink,
                onTap: () {
                  showModalBottomSheet(
                    isDismissible: false,
                    context: context,
                    builder: (context) {
                      return ConfirmDialog(
                        title: (!isAvailable) ? 'GO ONLINE' : "GO OFFLINE",
                        subtitle: (!isAvailable)
                            ? "You are about to become available to receive trip requests."
                            : "You will stop receiving trip requests.",
                        onPressed: () {
                          Navigator.pop(context);

                          // Delaying setState until after the dialog is closed
                          Future.delayed(Duration.zero, () {
                            if (!isAvailable) {
                              goOnline();
                              getLoctionUpdates();
                              setState(() {
                                availabilityColors = [
                                  Colors.green,
                                  Colors.green.shade800,
                                ];
                                availabilyTitle = 'GO OFFLINE';
                                isAvailable = true;
                              });
                            } else {
                              goOffline();
                              setState(() {
                                availabilityColors = [
                                  const Color(0xFF102DE1),
                                  const Color(0xCC0D6EFF),
                                ];
                                availabilyTitle = 'GO ONLINE';
                                isAvailable = false;
                              });
                            }
                          });
                        },
                      );
                    },
                  );
                },
                child: Container(
                  width: 160,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      colors: availabilityColors,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      availabilyTitle,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.7,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void goOnline() async {
    if (currentDriverUser?.user == null ||
        _locationController.userCurrentPosition == null) {
      print('Error: currentDriverUser or userCurrentPosition is null');
      return;
    }

    Geofire.initialize('driverAvailable');
    Geofire.setLocation(
      currentDriverUser!.user!.uid,
      _locationController.userCurrentPosition!.latitude,
      _locationController.userCurrentPosition!.longitude,
    );

    requestRef = FirebaseDatabase.instance
        .ref()
        .child('drivers/${currentDriverUser!.user!.uid}/newtrip');

    await requestRef!.set('waiting');
    requestRef!.onValue.listen((event) {});
  }

  void goOffline() async {
    if (currentDriverUser?.user == null) {
      print('Error: currentDriverUser is null');
      return;
    }

    Geofire.removeLocation(currentDriverUser!.user!.uid);

    // Ensuring the request reference is removed on disconnect
    requestRef!.onDisconnect().remove();

    await requestRef!.remove();
    requestRef!.onValue.listen((event) {});
  }

  void getLoctionUpdates() {
    if (currentDriverUser?.user == null ||
        _locationController.userCurrentPosition == null) {
      print('Error: currentDriverUser or userCurrentPosition is null');
      return;
    }

    homeTapStream =
        Geolocator.getPositionStream(locationSettings: locationPostionSettings)
            .listen((Position position) {
      _locationController.userCurrentPosition = position;

      if (_mapController == null) {
        print('Error: _mapController is null');
        return;
      }

      Geofire.setLocation(
        currentDriverUser!.user!.uid,
        position.latitude,
        position.longitude,
      );

      LatLng latLng = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition = CameraPosition(target: latLng, zoom: 15);
      _mapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      print('Current Position: ${position.latitude}, ${position.longitude}');
    });
  }
}
