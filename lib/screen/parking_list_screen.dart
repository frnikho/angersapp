import 'package:angers/main.dart';
import 'package:angers/models/data.dart';
import 'package:angers/models/parking.dart';
import 'package:angers/screen/parking_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class ParkingListScreen extends StatefulWidget {

  static String id = "ParkingListScreen";

  @override
  _ParkingListScreenState createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {

  Location _location = new Location();
  LocationData _locationData;
  PermissionStatus status;

  Future<bool> _getLocation() async {
    bool _serviceEnable = await _location.serviceEnabled();
    if (!_serviceEnable) {
      _serviceEnable = await _location.requestService();
      if (!_serviceEnable) {
        return false;
      }
    }
    PermissionStatus _permissionStatus = await _location.hasPermission();
    if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await _location.requestPermission();
      if (_permissionStatus != PermissionStatus.granted) {
        return false;
      }
    }
    _locationData = await _location.getLocation();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _getLocation();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(OMIcons.arrowBackIos, color: Colors.black),
        title: Text("Parkings", style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () async {
                  Provider.of<Data>(context, listen: false).sortByDistance();
                  bool success = await _getLocation();
                  if (!success)
                    return;
                  setState(() {
                    Provider.of<Data>(context, listen: false).calcDistance(_locationData);
                  });
                },
                child: Icon(OMIcons.locationOn, color: Colors.black, size: 28),
              )
          ),
          Container(
            padding: EdgeInsets.only(right: 12),
            child: InkWell(
              child: Icon(OMIcons.sort, color: Colors.black),
              onTap: () {
                Provider.of<Data>(context, listen: false).sortByAlpha();
              },
            ),
          )
        ],
      ),
      body: Consumer<Data>(
        builder: (context, data, child) {
          return FutureBuilder<bool>(
            future: data.fetchAllParking(_locationData),
            builder: (context, snap) {
              if (!snap.hasData) {
                return CircularProgressIndicator();
              } else {
                if (snap.data) {
                  return RefreshIndicator(
                      onRefresh: () async {
                        data.update();
                      },
                      child: ParkingList(data.parking)
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }
            },
          );
        },
      ),
    );
  }
}

class ParkingList extends StatelessWidget {

  final List<Parking> parkings;

  ParkingList(this.parkings);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: parkings.length,
      itemBuilder: (context, index) {
        return ParkingTile(parkings[index]);
      },
    );
  }
}


class ParkingTile extends StatelessWidget {

  final Parking parking;

  ParkingTile(this.parking);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ParkingScreen(parking),
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 15),
              child: Row(
                  children: [
                    Expanded(
                      flex: 20,
                      child: Hero(
                        tag: "${parking.id}",
                        child: Container(
                          margin: EdgeInsets.all(10),
                          height: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage("${parking.imageUrl}")
                              )
                          ),
                          child: FutureBuilder(
                            builder: (context, snap) {
                              if (snap.hasData) {
                                if (parking.isFav)
                                  return Icon(Icons.star, color: Colors.yellow, size: 24);
                                return SizedBox();
                              } else {
                                return SizedBox();
                              }
                            },
                            future: parking.loadFavStorage(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 35,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Hero(
                                    tag: "${parking.name}",
                                    transitionOnUserGestures: true,
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Text("${parking.name}", style: GoogleFonts.creteRound(fontSize: 18))
                                    )
                                  ),
                                  SizedBox(height: 10),
                                  Text("${parking.address}", style: GoogleFonts.roboto(fontSize: 10))
                                ],
                              ),
                            ),
                            Expanded(
                              child: CircleAvatar(backgroundColor: Colors.blue, child: Text("${parking.distance.toStringAsFixed(1)}km", style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        )
      ],
    );
  }
}

