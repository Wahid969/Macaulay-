import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wahid_uber_app/driver/models/trip_details.dart';

class NoficationdialogWidget extends StatelessWidget {
  final TripDetails tripDetails;

  const NoficationdialogWidget({super.key, required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            Image.asset(
              'assets/images/uber1.png',
              width: 100,
            ),
            SizedBox(
              height: 16.0,
            ),
            Text('NEW TRIP REQUEST',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://storage.googleapis.com/codeless-dev.appspot.com/uploads%2Fimages%2Fnn2Ldqjoc2Xp89Y7Wfzf%2F2ee3a5ce3b02828d0e2806584a6baa88.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                          child: SizedBox(
                              child: Text(
                        tripDetails.pickupAddress.toString(),
                        style: GoogleFonts.montserrat(fontSize: 18),
                      )))
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/icons/desticon1.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.destinationAdddress.toString(),
                            style: GoogleFonts.montserrat(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
           const  SizedBox(
              height: 20,
            ),
           const  Divider(
              thickness: 2,
              color: Colors.grey,
            ),
           const  SizedBox(
              height: 8,
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text(
                        'DECLINE',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () {},
                          child: Text(
                            'ACCEPT',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ))),
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
