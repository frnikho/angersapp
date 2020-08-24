import 'package:angers/models/parking.dart';
import 'package:angers/screen/parking_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const double _angersLatitude = 47.4667;
const double _angersLongitude = -0.55;

class ParkingMap extends StatelessWidget {

  final List<Parking> parkings;

  ParkingMap({this.parkings});

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = new Set<Marker>();
    parkings.forEach((parking) {
      markers.add(
        Marker(
          position: parking.location,
          markerId: MarkerId(parking.id),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ParkingScreen(parking);
              }
            ));
          }
        )
      );
    });
    return Scaffold(
      body: GoogleMap(
        markers: markers,
        initialCameraPosition: CameraPosition(
          target: LatLng(_angersLatitude, _angersLongitude),
          zoom: 13,
        ),
      ),
    );
  }
}
