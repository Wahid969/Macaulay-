import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wahid_uber_app/driver/controllers/driver_auth_controlle.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  final DriverAuthController _driverAuthController = DriverAuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String carColor;
  late String carModel;
  late String vehicleNumber;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(
        0.95,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter vehicle info',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                    onChanged: (value) {
                      carModel = value;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Car Model';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      labelText: ' Car Model',
                      labelStyle: GoogleFonts.montserrat(
                        fontSize: 14,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  onChanged: (value) {
                    carColor = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Car Color';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    labelText: ' Car Color',
                    labelStyle: GoogleFonts.montserrat(
                      fontSize: 14,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  onChanged: (value) {
                    vehicleNumber = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Vehicle Number';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    labelText: 'Vehicle Number',
                    labelStyle: GoogleFonts.montserrat(
                      fontSize: 14,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                InkWell(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      _driverAuthController.updateProfile(
                          carColor: carColor,
                          carModel: carModel,
                          vehicleNumber: vehicleNumber, context: context);
                    }
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
                    child: Stack(
                      children: [
                        Positioned(
                          left: 278,
                          top: 19,
                          child: Opacity(
                            opacity: 0.5,
                            child: Container(
                              width: 60,
                              height: 60,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 12,
                                  color: const Color(0xFF103DE5),
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 311,
                          top: 36,
                          child: Opacity(
                            opacity: 0.3,
                            child: Container(
                              width: 5,
                              height: 5,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 281,
                          top: -10,
                          child: Opacity(
                            opacity: 0.3,
                            child: Container(
                              width: 20,
                              height: 20,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        Center(
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Continue',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
