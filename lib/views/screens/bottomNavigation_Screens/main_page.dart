import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wahid_uber_app/controllers/Places_controller.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:wahid_uber_app/controllers/auth_controller.dart';
import 'package:wahid_uber_app/controllers/push_notification_controller.dart';
import 'package:wahid_uber_app/driver/controllers/manage_driver_methods.dart';
import 'package:wahid_uber_app/driver/views/screens/driver_main_screen.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/models/direction.dart';
import 'package:wahid_uber_app/models/nearbydriver.dart';
import 'package:wahid_uber_app/provider/app_data.dart';
import 'package:wahid_uber_app/views/screens/bottomNavigation_Screens/info_dialog.dart';
import 'package:wahid_uber_app/views/screens/inner_screens/search_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _googleMapController =
      Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GoogleMapController? _controllerGoogleMap;
  Position? currentPosition;
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
      currentPosition = position;

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: positionLatLng, zoom: 15);

      _controllerGoogleMap
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      await _initializeGeoFireListener();
      await PlacesController.findCordinateAddress(position, context);
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  List<LatLng> polylineCoordinates = [];
  double searchDetailSheet = (Platform.isAndroid) ? 300 : 275;
  double rideDetailSheet = 0;
  final Set<Polyline> _polyLines = {};
  final Set<Marker> _markers = {};
  final Set<Circle> _circle = {};
  bool drawerCanOpen = true;
  double requestSheetHeight = 0;
  String appState = 'normal';
  final List<String> keysRetrieved = []; // or Set<String> if you prefer

  List<NearByDriver>? availableNearByDriverList = [];

  double bottomPadding = 0;

  Direction? tripDirectionDetails;

  DatabaseReference? rideRef;

  bool nearByDriverKeyLoaded = false;

  void showDetailsheet() async {
    await getDirection();
    setState(() {
      searchDetailSheet = 0;
      rideDetailSheet = (Platform.isAndroid) ? 300 : 200;
      bottomPadding = (Platform.isAndroid) ? 240 : 290;
      drawerCanOpen = false;
    });
  }

  //show requesting sheet

  BitmapDescriptor? nearByCarIcon;
  void createMarker() {
    if (nearByCarIcon == null) {
      BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(
                size: Size(2, 2),
              ),
              'assets/icons/car_android.png')
          .then((icon) {
        setState(() {
          nearByCarIcon = icon;
          print("Marker icon created successfully"); // Debugging line
        });
      }).catchError((error) {
        print("Error loading marker icon: $error");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // AuthController.getCurrentUserInfo();
    _getCurrentLocation();
  }

  void _addDriverToMap(Map<String, dynamic> driverEvent) {
    NearByDriver nearByDriver = NearByDriver(
      uidDriver: driverEvent['key'],
      latitude: driverEvent['latitude'],
      longitude: driverEvent['longitude'],
    );

    ManageDriverMethods.updateOnlineNearbyDriverLocation(nearByDriver);
    ManageDriverMethods.nearByDriverList.add(nearByDriver);

    if (nearByDriverKeyLoaded) {
      _updateMarkersOnMap();
    }
  }

  void _removeDriverFromMap(String driverKey) {
    ManageDriverMethods.removeDriverFromList(driverKey);
    _updateMarkersOnMap();
  }

  void _updateDriverLocation(Map<String, dynamic> driverEvent) {
    NearByDriver nearByDriver = NearByDriver(
      uidDriver: driverEvent['key'],
      latitude: driverEvent['latitude'],
      longitude: driverEvent['longitude'],
    );

    ManageDriverMethods.updateOnlineNearbyDriverLocation(nearByDriver);
    _updateMarkersOnMap();
  }

  void _updateMarkersOnMap() {
    setState(() {
      _markers.clear();
      for (var nearByDriver in ManageDriverMethods.nearByDriverList) {
        LatLng driverPosition =
            LatLng(nearByDriver.latitude!, nearByDriver.longitude!);
        Marker driverMarker = Marker(
          markerId: MarkerId(nearByDriver.uidDriver!),
          icon:
              nearByCarIcon ?? BitmapDescriptor.defaultMarker, // Fallback icon
          position: driverPosition,
        );
        _markers.add(driverMarker);
      }
    });
  }

  Future<void> _initializeGeoFireListener() async {
    if (currentPosition == null) return;

    Geofire.initialize('onlineDrivers');
    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 80)!
        .listen((driverEvent) {
      if (driverEvent != null) {
        var onlineDriverChild = driverEvent['callBack'];
        // Casting the driverEvent map to the expected type
        Map<String, dynamic> driverEventData =
            Map<String, dynamic>.from(driverEvent);

        switch (onlineDriverChild) {
          case Geofire.onKeyEntered:
            _addDriverToMap(driverEventData);
            break;
          case Geofire.onKeyExited:
            _removeDriverFromMap(driverEventData['key']);
            break;
          case Geofire.onKeyMoved:
            _updateDriverLocation(driverEventData);
            break;
          case Geofire.onGeoQueryReady:
            nearByDriverKeyLoaded = true;
            break;
        }
      }
    });
  }

  void showRequestingSheet() {
    setState(() {
      rideDetailSheet = 0;
      requestSheetHeight = (Platform.isAndroid) ? 195 : 220;
      bottomPadding = (Platform.isAndroid) ? 200 : 190;
      drawerCanOpen = true;
    });

    createTripRequest();
  }

  DatabaseReference? tripRef;

  //create Ride Request
  createTripRequest() {
    tripRef = FirebaseDatabase.instance.ref().child('tripRequest').push();

    var pickupLocation =
        Provider.of<AppData>(context, listen: false).addressModel;
    var destinationLocation =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    Map pickupCoordinateMap = {
      'latitude': pickupLocation!.latitude.toString(),
      'longitude': pickupLocation.longitude.toString(),
    };

    Map destinationCoordinateMap = {
      'latitude': destinationLocation!.latitude.toString(),
      'longitude': destinationLocation.longitude.toString(),
    };
    Map driverCoordinate = {
      'latitude': "",
      'longitude': "",
    };
    Map dataMap = {
      'dateTime': DateTime.now().toString(),
      'fullName': userInfo!.fullName,
      'email': userInfo!.email,
      'userID': userInfo!.id,
      'pickupLocation': pickupCoordinateMap,
      'destinationLocation': destinationCoordinateMap,
      'pickupAddress': pickupLocation.placeName,
      'destinationAddress': destinationLocation.placeName,
      'tripID': tripRef!.key,
      'driverID': "wating",
      'driverLocation': driverCoordinate,
      'carDetails': '',
      'driverName': '',
      'driverPhone': '',
      'fareAmount': '',
      'status': 'new',
    };

    tripRef!.set(dataMap);
  }

  noDriverAvailable() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const InfoDialog();
        });
  }

  searchDriver() {
    if (availableNearByDriverList!.isEmpty) {
      resetApp();
      noDriverAvailable();
    } else {
      var currentDriver = availableNearByDriverList![0];
      //send notification to this current driver

      sendNotification(currentDriver);

      availableNearByDriverList!.removeAt(0);
    }
  }

  sendNotification(NearByDriver currentDriver) {
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentDriver.uidDriver.toString())
        .child('newTripStatus');

    currentDriverRef.set(tripRef!.key);

    //get current driver token
    DatabaseReference tokenRef = FirebaseDatabase.instance
        .ref()
        .child('drivers')
        .child(currentDriver.uidDriver.toString())
        .child('token');

    tokenRef.once().then((dataSnapshot) {
      if (dataSnapshot.snapshot.value != null) {
        String token = dataSnapshot.snapshot.value.toString();

        //send notification
        PushNotificationController.sendNotificationToSelectedDriver(
            token, context, tripRef!.key.toString());
      } else {
        return;
      }
    });
  }

  final AuthController _authController = AuthController();
  bool isDriverMode =
      userInfo?.userType == 'driver'; // Initial mode based on current user type

  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 160,
                color: Colors.white,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/user.png',
                        height: 60,
                        width: 60,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              userInfo != null
                                  ? userInfo!.fullName.toUpperCase()
                                  : "User",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'View Profile',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                color: Color(0xFFe2e2e2),
                thickness: 1.0,
                height: 1.0,
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                leading: const Icon(
                  OMIcons.creditCard,
                ),
                title: Text(
                  'Payments',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  OMIcons.history,
                ),
                title: Text(
                  'History',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  OMIcons.contactSupport,
                ),
                title: Text(
                  'Support',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  OMIcons.info,
                ),
                title: Text(
                  'About',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  isDriverMode ? OMIcons.driveEta : OMIcons.person,
                ),
                title: Text(
                  isDriverMode
                      ? 'Switch to User Mode'
                      : 'Switch to Driver Mode',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  // Call the switchUserType method from AuthController
                  await _authController.switchUserType(context);

                  // Update the mode in the UI
                  setState(() {
                    isDriverMode = !isDriverMode;
                  });

                  // Show feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isDriverMode
                            ? 'Switched to Driver Mode'
                            : 'Switched to User Mode',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // The map layer
          GoogleMap(
            markers: _markers,
            circles: _circle,
            polylines: _polyLines,
            padding: EdgeInsets.only(bottom: bottomPadding),
            initialCameraPosition: _kGooglePlex,
            mapType: MapType.terrain,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController mapController) {
              _controllerGoogleMap = mapController;
              _googleMapController.complete(_controllerGoogleMap);
              _getCurrentLocation();

              setState(() {
                bottomPadding = 299;
              });
            },
          ),

          Positioned(
            top: 45,
            left: 20,
            child: InkWell(
              onTap: () {
                if (drawerCanOpen) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    drawerCanOpen ? Icons.menu : Icons.arrow_back_ios,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              duration: Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchDetailSheet,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Nice to see you',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'Where are you going ',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Color(0xFF336699),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  final res = await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const SearchScreen();
                                  }));

                                  if (res == 'getDirection') {
                                    showDetailsheet();
                                  }
                                },
                                child: Text(
                                  'Search Destination',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      Row(
                        children: [
                          const Icon(
                            OMIcons.home,
                            color: Colors.grey,
                            // color: Color(0xFF336699),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                child: Text(
                                  overflow: TextOverflow.ellipsis,
                                  Provider.of<AppData>(context, listen: true)
                                              .addressModel !=
                                          null
                                      ? Provider.of<AppData>(context,
                                              listen: false)
                                          .addressModel!
                                          .placeName
                                      : "Home",
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                'Your residential address',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Color(0xFFe2e2e2),
                        thickness: 1.0,
                        height: 1.0,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //RideDetails Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                height: rideDetailSheet,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Color(0xFFe3fded),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/uber1.png',
                                  width: 120,
                                  height: 120,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Taxi',
                                      style: GoogleFonts.wallpoet(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey.shade900,
                                      ),
                                    ),
                                    Text(
                                      tripDirectionDetails != null
                                          ? tripDirectionDetails!.distanceText!
                                          : "",
                                      style: GoogleFonts.roboto(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                Expanded(child: Container()),
                                tripDirectionDetails != null
                                    ? Text(
                                        "${PlacesController.estimatedFares(tripDirectionDetails!)} LYD",
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                          fontSize: 20,
                                        ),
                                      )
                                    : const Text(''),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.money_dollar,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Cash",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            appState = 'REQUESTING';
                          });

                          showRequestingSheet();

                          availableNearByDriverList =
                              ManageDriverMethods.nearByDriverList;

                          //search driver
                          searchDriver();
                        },
                        child: Container(
                          width: 319,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF102DE1),
                                Color(0xCC0D6EFF),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'REQUEST CAB',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //reqquest ride sheet
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: AnimatedSize(
              duration: const Duration(
                milliseconds: 150,
              ),
              curve: Curves.bounceIn,
              child: Container(
                height: requestSheetHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const SizedBox(
                      width: 250,
                      child: LinearProgressIndicator(),
                    ),
                    Text(
                      "Requesting a Ride...",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          width: 1,
                          color: Colors.blueGrey,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.close, size: 25),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        'Cancel ride',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///get direction

  Future<void> getDirection() async {
    final pickup = Provider.of<AppData>(context, listen: false).addressModel;
    final destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    final pickUpLatlng = LatLng(pickup!.latitude, pickup.longitude);
    final destinationLatlng =
        LatLng(destination!.latitude, destination.longitude);

    showDialog(
      barrierDismissible: false, // Prevents the user from dismissing the dialog
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(), // Loading indicator
              SizedBox(width: 20),
              Text("Loading..."),
            ],
          ),
        );
      },
    );

    final details = await PlacesController.getDirectionDetails(
        pickUpLatlng, destinationLatlng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);

    if (details == null ||
        details.encodedPoint == null ||
        details.encodedPoint!.isEmpty) {
      print('Failed to get direction details or polyline is empty.');
      return;
    }

    final PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(details.encodedPoint!);

    polylineCoordinates.clear();
    if (results.isNotEmpty) {
      for (PointLatLng point in results) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print('No points found in the polyline.');
    }

    _polyLines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId('polyId'),
        color: Colors.pink,
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        geodesic: true,
      );
      _polyLines.add(polyline);
    });

    ///make polyline fit map
    LatLngBounds? bounds;
    if (pickUpLatlng.latitude > destinationLatlng.latitude &&
        pickUpLatlng.longitude > destinationLatlng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatlng, northeast: pickUpLatlng);
    } else if (pickUpLatlng.longitude > destinationLatlng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          pickUpLatlng.latitude,
          destinationLatlng.longitude,
        ),
        northeast: LatLng(
          destinationLatlng.latitude,
          pickUpLatlng.longitude,
        ),
      );
    } else if (pickUpLatlng.latitude > destinationLatlng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatlng.latitude, pickUpLatlng.latitude),
          northeast:
              LatLng(pickUpLatlng.latitude, destinationLatlng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickUpLatlng, northeast: destinationLatlng);
    }
    _controllerGoogleMap!
        .animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
        markerId: const MarkerId('pickupmaker'),
        position: pickUpLatlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        infoWindow: InfoWindow(title: pickup.placeName, snippet: 'Location'));
    Marker destinationMarker = Marker(
      markerId: const MarkerId('destinationMarker'),
      position: destinationLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueBlue,
      ),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'destination'),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });
  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polyLines.clear();
      _markers.clear();
      _circle.clear();
      rideDetailSheet = 0;
      requestSheetHeight = 0;
      searchDetailSheet = (Platform.isAndroid) ? 275 : 300;
      bottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;

      status = '';
      driverFullName = '';
      driverPhoneNumber = '';
      driverCarDetails = '';
      tripStatusDisplay = 'Driver is Arriving';
    });
  }
}
