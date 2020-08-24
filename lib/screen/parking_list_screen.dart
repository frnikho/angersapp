import 'package:angers/main.dart';
import 'package:angers/models/data.dart';
import 'package:angers/models/parking.dart';
import 'package:angers/screen/parking_map.dart';
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
        title: Text("Parkings", style: GoogleFonts.roboto(color: Colors.black, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 12),
            child: InkWell(
              child: Icon(OMIcons.map, color: Colors.black),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ParkingMap(parkings: Provider.of<Data>(context).parking);
                  }
                ));
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 12),
            child: InkWell(
              child: Icon(OMIcons.sort, color: Colors.black),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return _buildDialog(context);
                  }
                );
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
                return Center(child: CircularProgressIndicator());
              } else {
                if (snap.data) {
                  return RefreshIndicator(
                      onRefresh: () async {
                        data.update();
                      },
                      child: ParkingList(data.parking)
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
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

class DialogText extends StatelessWidget {

  final IconData icon;
  final String text;
  final Function callback;

  DialogText({this.icon, this.text, this.callback});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        this.callback();
      },
      borderRadius: BorderRadius.all(Radius.circular(3)),
      child: Container(
        margin: EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(this.icon ?? Icons.close, size: 28),
            SizedBox(width: 10),
            Text(this.text ?? "not defined", style: GoogleFonts.openSans(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}


Widget _buildDialog(BuildContext context) {
  return Dialog(
      elevation: 0,
      child: Container(
        height: 400,
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogText(
                callback: () {
                  Provider.of<Data>(context, listen: false).sortByAlpha();
                  Navigator.pop(context);
                },
                icon: OMIcons.sortByAlpha,
                text: "Alpha",
              ),
              DialogText(
                callback: ()  {
                  Provider.of<Data>(context, listen: false).sortByDistance();
                  Navigator.pop(context);
                },
                icon: OMIcons.locationOn,
                text: "Distance",
              ),
              DialogText(
                callback: ()  {
                  Provider.of<Data>(context, listen: false).sortBySize();
                  Navigator.pop(context);
                },
                icon: OMIcons.confirmationNumber,
                text: "Taille",
              ),
              DialogText(
                callback: ()  {
                  Provider.of<Data>(context, listen: false).sortByPrice1h();
                  Navigator.pop(context);
                },
                icon: OMIcons.attachMoney,
                text: "Prix 1h",
              ),
              DialogText(
                callback: ()  {
                  Provider.of<Data>(context, listen: false).sortByPrice24h();
                  Navigator.pop(context);
                },
                icon: OMIcons.attachMoney,
                text: "Prix 24h",
              ),
            ],
          )
      )
  );
}