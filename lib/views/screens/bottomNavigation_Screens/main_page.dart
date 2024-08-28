import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wahid_uber_app/controllers/Places_controller.dart';
import 'package:wahid_uber_app/controllers/auth_controller.dart';
import 'package:wahid_uber_app/controllers/firehelperController.dart';
import 'package:wahid_uber_app/controllers/location_controller.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/models/direction.dart';
import 'package:wahid_uber_app/models/nearbydriver.dart';
import 'package:wahid_uber_app/provider/app_data.dart';
import 'package:wahid_uber_app/provider/geo_provider.dart';
import 'package:wahid_uber_app/views/screens/inner_screens/search_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<LatLng> polylineCoordinates = [];
  double searchDetailSheet = (Platform.isAndroid) ? 300 : 275;
  double rideDetailSheet = 0;
  final Set<Polyline> _polyLines = {};
  Set<Marker> _markers = {};
  final Set<Circle> _circle = {};
  bool drawerCanOpen = true;
  double requestSheetHeight = 0;
  final List<String> keysRetrieved = []; // or Set<String> if you prefer

  double bottomPadding = 0;
  final LocationController _locationController = LocationController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? _mapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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
  void showRequestingSheet() {
    setState(() {
      rideDetailSheet = 0;
      requestSheetHeight = (Platform.isAndroid) ? 195 : 220;
      bottomPadding = (Platform.isAndroid) ? 200 : 190;
      drawerCanOpen = true;
    });

    createRideRequest();
  }

  BitmapDescriptor? nearByCar;
  void createMarker() {
    if (nearByCar == null) {
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(2, 2)),
              'assets/icons/car_android.png')
          .then((icon) {
        setState(() {
          nearByCar = icon;
        });
      });
    }
  }

  bool _hasStartedGeofireListener = false;

  @override
  void initState() {
    super.initState();
    AuthController.getCurrentUserInfo();
    WidgetsBinding.instance.addObserver(this); // Add observer for app lifecycle
    _initializeGeofireListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeGeofireListener();
  }

  void _initializeGeofireListener() {
    final geofireProvider =
        Provider.of<GeofireProvider>(context, listen: false);
    final userLocation = _locationController.userCurrentPosition;

    if (userLocation != null && !_hasStartedGeofireListener) {
      startGeofireListener();
      _hasStartedGeofireListener = true; // Ensure listener is only started once
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeGeofireListener(); // Reinitialize on resume
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context).user;
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
              )
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
            onMapCreated: (GoogleMapController mapController) async {
              _mapController = mapController;
              _controller.complete(_mapController);
              _locationController.setGoogleMapController(_mapController!);

              // Ensure getCurrentUserLocation completes before starting GeoFire listener
              await _locationController.getCurrentUserLocation(context);

              startGeofireListener();
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
                      Row(
                        children: [
                          const Icon(
                            OMIcons.work,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Work',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Your Office address',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  letterSpacing: 0.8,
                                ),
                              )
                            ],
                          )
                        ],
                      )
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
                            color: Colors.blueAccent.shade100.withOpacity(
                              0.9,
                            ),
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
                          showRequestingSheet();
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
                        onPressed: () {
                          cancelRequest();
                          resetApp();
                        },
                        icon: const Icon(Icons.close, size: 25),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        cancelRequest();
                        resetApp();
                      },
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
        polylineId: PolylineId('polyId'),
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
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickUpMarker = Marker(
        markerId: MarkerId("pickUp"),
        position: pickUpLatlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: pickup.placeName,
          snippet: "My Location",
        ));

    Marker destinationMarker = Marker(
        markerId: const MarkerId("destination"),
        position: destinationLatlng,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        infoWindow: InfoWindow(
          title: destination.placeName,
          snippet: "Desitination",
        ));

    setState(() {
      _markers.add(pickUpMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: const CircleId('pickUp'),
      strokeColor: Colors.blue,
      radius: 12,
      strokeWidth: 3,
      center: pickUpLatlng,
      fillColor: Colors.blue,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId('pickUp'),
      strokeColor: Colors.blue,
      radius: 12,
      strokeWidth: 3,
      center: destinationLatlng,
      fillColor: Colors.purple,
    );

    setState(() {
      _circle.add(pickupCircle);
      _circle.add(destinationCircle);
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
      searchDetailSheet = (Platform.isAndroid) ? 300 : 275;
      bottomPadding = (Platform.isAndroid) ? 280 : 270;
      drawerCanOpen = true;
    });
  }

  void createRideRequest() async {
    rideRef = FirebaseDatabase.instance.ref().child('rideRequest').push();

    final pickUp = Provider.of<AppData>(context, listen: false).addressModel;
    final destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;
    Map pickUpMap = {
      'latitude': pickUp!.latitude.toString(),
      'longitude': pickUp.longitude.toString(),
    };
    Map destinationMap = {
      'latitude': destination!.latitude.toString(),
      'longitude': destination.longitude.toString(),
    };
    Map rideMap = {
      'created_at': DateTime.now().toString(),
      'riderName': userInfo!.fullName,
      'pickUpAddress': pickUp.placeName,
      'destinationAddress': destination.placeName,
      'location': pickUpMap,
      'destination': destinationMap,
      'payment': "cash",
      'driver': "waiting",
    };

    await rideRef!.set(rideMap);
  }

  void cancelRequest() async {
    await rideRef!.remove();
  }

  void startGeofireListener() async {
    Platform.isAndroid
        ? await Firebase.initializeApp(
            options: const FirebaseOptions(
              apiKey: "AIzaSyB_SdqRX8aYQ6LgUneHgQ4Nudw2EIIE-uc",
              appId: '1:107113386007:android:b6faa5a9aa0f3b41318c52',
              messagingSenderId: '107113386007',
              projectId: 'uber-app-439a2',
              storageBucket: "uber-app-439a2.appspot.com",
            ),
          )
        : await Firebase.initializeApp();
    Geofire.initialize('driverAvailable');
    print('GeoFire initialized with collection: driverAvailable');
    Geofire.queryAtLocation(_locationController.userCurrentPosition!.latitude,
            _locationController.userCurrentPosition!.longitude, 20)
        ?.listen((map) {
      print('Listener triggered');
      if (map != null) {
        print('Entering data');
        print(map);
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            print('Key entered');
            NearByDriver nearbyDriver = NearByDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            Firehelpercontroller.nearbyDriverList.add(nearbyDriver);
            if (nearByDriverKeyLoaded) {
              updateDriverOnMap();
            }
            break;

          case Geofire.onKeyExited:
            print('Key exited');

            Firehelpercontroller.removeFromList(map['key']);
            updateDriverOnMap();
            break;

          case Geofire.onKeyMoved:
            print('Key moved');
            NearByDriver nearbyDriver = NearByDriver();
            nearbyDriver.key = map['key'];
            nearbyDriver.latitude = map['latitude'];
            nearbyDriver.longitude = map['longitude'];
            Firehelpercontroller.updateNearByLocation(nearbyDriver);
            updateDriverOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearByDriverKeyLoaded = true;
            updateDriverOnMap();
            break;
        }

        setState(() {});
      } else {
        print('Data not received');
      }
    });
  }

  void updateDriverOnMap() {
    setState(() {
      _markers.clear();
    });

    Set<Marker> tempMarkers = Set<Marker>();
    for (NearByDriver driver in Firehelpercontroller.nearbyDriverList) {
      LatLng driverPosition = LatLng(driver.latitude!, driver.longitude!);
      Marker thisMarker = Marker(
        markerId: MarkerId("${driver.key}"),
        position: driverPosition,
        icon: nearByCar!,
        rotation: PlacesController.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _markers = tempMarkers;
    });
  }
}
