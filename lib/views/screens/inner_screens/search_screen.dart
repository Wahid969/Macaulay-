import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:wahid_uber_app/global_variables.dart';
import 'package:wahid_uber_app/models/address.dart';
import 'package:wahid_uber_app/models/places.dart';
import 'package:wahid_uber_app/provider/app_data.dart';
import 'package:wahid_uber_app/services/manage_http_response.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _pickUpController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode(); // 1. FocusNode
  List<Place> _placePredictionList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _destinationFocusNode.requestFocus(); // 2. Request focus
    });
  }

  @override
  void dispose() {
    _destinationFocusNode.dispose(); // 3. Dispose FocusNode
    _pickUpController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void searchPlace(String value) async {
    if (value.isNotEmpty) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&key=$mapKey";

      final response = await ManageHttpResponse.getRequest(url);

      if (response == "Failed") {
        return;
      } else {
        if (response['status'] == "OK") {
          var predictions = response['predictions'];
          List<Place> places =
              predictions.map<Place>((json) => Place.fromMap(json)).toList();
          setState(() {
            _placePredictionList = places;
          });
        }
      }
    }
  }

  void getPlaceDetails(String placeId) async {
    // Show a loading dialog
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

    // Perform the async operation
    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?fields=name%2Cgeometry&place_id=$placeId&key=$mapKey';
    final response = await ManageHttpResponse.getRequest(url);

    // Close the loading dialog after the operation is done
    Navigator.of(context).pop();

    if (response == "Failed") {
      return;
    } else {
      if (response['status'] == "OK") {
        var result = response['result'];
        if (result != null && result['geometry'] != null) {
          Address address = Address(
              placeName: result['name'],
              latitude: result['geometry']['location']['lat'],
              longitude: result['geometry']['location']['lng'],
              placeId: placeId,
              placeFormatedAddress: '');

          Provider.of<AppData>(context, listen: false)
              .updateDestinationAddress(address);
          print(address.placeName);

          Navigator.pop(context ,'getDirection');
        } else {
          print("Geometry data is missing in the response.");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String address = Provider.of<AppData>(context).addressModel!.placeName;
    _pickUpController.text = address;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 210,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  spreadRadius: 0.2,
                  offset: Offset(0.7, 0.7),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: Column(
                children: [
                  Stack(
                    children: [
                      const Icon(Icons.arrow_back),
                      Center(
                        child: Text(
                          'Your route',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Image.network(
                        "https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png",
                        width: 16,
                        height: 16,
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: _pickUpController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey,
                            border: InputBorder.none,
                            filled: true,
                            hintText: 'Pickup location',
                            hintStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.only(
                                left: 10, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(OMIcons.locationOn, size: 20),
                      Flexible(
                        child: TextFormField(
                          onChanged: (value) {
                            searchPlace(value);
                          },
                          controller: _destinationController,
                          focusNode: _destinationFocusNode, // Attach FocusNode
                          decoration: InputDecoration(
                            fillColor: Colors.grey,
                            border: InputBorder.none,
                            filled: true,
                            hintText: 'Where to?',
                            hintStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.only(
                                left: 10, top: 8, bottom: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _placePredictionList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(OMIcons.locationOn),
                  title: Text(_placePredictionList[index].mainText),
                  subtitle: Text(_placePredictionList[index].secondaryText),
                  onTap: () {
                    getPlaceDetails(_placePredictionList[index].placeId);
                    setState(() {
                      _placePredictionList = [];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Place Model
