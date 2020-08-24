import 'package:angers/models/parking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ParkingScreen extends StatefulWidget {

  static String id = "ParkingScreen";

  final Parking parking;

  ParkingScreen(this.parking);

  @override
  _ParkingScreenState createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {
  void _openMap() async {
    String mapOptions = [
      'query=${widget.parking.location.latitude},${widget.parking.location.longitude}',
    ].join('&');

    final url = "https://www.google.com/maps/dir/api=1&$mapOptions";

    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = new Set();
    markers.add(Marker(markerId: MarkerId("localisation"), position: widget.parking.location));
    String free = "";
    widget.parking.free ? free = "Gratuit" : free = "Payant";

    TextStyle spacesStyle = GoogleFonts.armata(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  return ParkingScreen(widget.parking);
                }
              ));
            });
          },
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Hero(
                        tag: "${widget.parking.id}",
                        child: Container(
                          height: 240,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(40), bottomLeft: Radius.circular(40)),
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: NetworkImage("${widget.parking.imageUrl}")
                              )
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CircleAvatar(
                              radius: 16,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(OMIcons.arrowBackIos, color: Colors.white, size: 22)
                              ),
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                            CircleAvatar(
                              radius: 16,
                              child: Icon(OMIcons.list, color: Colors.white, size: 22),
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 60, left: 15, right: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.parking.toggleFav();
                                });
                              },
                              child: CircleAvatar(
                                radius: 16,
                                child: widget.parking.isFav ? Icon(OMIcons.star, color: Colors.white, size: 22) : Icon(OMIcons.starBorder, color: Colors.white, size: 22),
                                backgroundColor: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    child: Hero(
                      tag: "${widget.parking.name}",
                      transitionOnUserGestures: true,
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text("${widget.parking.name}", style: GoogleFonts.openSans(fontWeight: FontWeight.w600, fontSize: 18)))
                    )
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(width: 10),
                            Icon(FontAwesomeIcons.moon),
                            Text(" ${widget.parking.closeTime}    ", style: GoogleFonts.openSans()),
                            Icon(FontAwesomeIcons.sun),
                            Text(" ${widget.parking.openTime}", style: GoogleFonts.openSans()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Icon(OMIcons.locationOn),
                            Text("${widget.parking.distance.toStringAsFixed(2)} km", style: GoogleFonts.openSans()),
                            SizedBox(width: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent.withOpacity(0.7), Colors.blue],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text("${widget.parking.spaceBikes ?? 0} ", style: spacesStyle),
                            Icon(OMIcons.directionsBike, color: Colors.white),
                          ],
                        ),
                        FutureBuilder(
                          future: widget.parking.getSpaceLeft(),
                          builder: (context, snap) {
                            if (snap.hasData) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("${widget.parking.spaceCars-snap.data}", style: spacesStyle),
                                      Text("/${widget.parking.spaceCars ?? 0}", style: spacesStyle),
                                    ],
                                  ),
                                  Text("${snap.data} place restantes", style: spacesStyle.copyWith(color: Colors.white, fontSize: 12),),
                                  Icon(OMIcons.directionsCar, color: Colors.white),
                                ],
                              );
                            } else {
                              return Text("?", style: spacesStyle);
                            }
                          },
                        ),
                        Column(
                          children: [
                            Text("${widget.parking.spacePmr ?? 0} ", style: spacesStyle),
                            Icon(FontAwesomeIcons.wheelchair, color: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 30),
                      height: 220,
                      width: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        child: Container(
                          child: GoogleMap(
                            onTap: (LatLng pos) {
                              _openMap();
                            },
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: widget.parking.location,
                              zoom: 14
                            ),
                            markers: markers,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(widget.parking.address, style: GoogleFonts.openSans()),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, top: 20),
                    child: Text("Tarifs", style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  buildParkingPrices(widget.parking),
                  Container(
                    padding: EdgeInsets.only(left: 30, right: 30, top: 20),
                    child: Text("Plus d'info", style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    child: InkWell(
                      child: Text("${widget.parking.infoUrl}", style: GoogleFonts.armata(decoration: TextDecoration.underline, fontSize: 14)),
                      onTap: () {
                        launch("${widget.parking.infoUrl}");
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PriceCard extends StatelessWidget {

  final Parking parking;
  final int shadowDegree;
  final String hours;
  final double prices;

  final TextStyle _style = GoogleFonts.openSans(color: Colors.white, fontWeight: FontWeight.w700);

  PriceCard({@required this.shadowDegree, @required this.hours, @required this.prices, @required this.parking});

  final List<Color> colorsDegree = [
    Colors.blue.withOpacity(0.6),
    Colors.blue.withOpacity(0.7),
    Colors.blue.withOpacity(0.8),
    Colors.blue.withOpacity(0.9),
    Colors.blue.withOpacity(1)
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: colorsDegree[shadowDegree],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text("${prices.toStringAsFixed(2)} €", style: _style,),
    );
  }
}


Widget buildParkingPrices(Parking parking) {
  TextStyle _style = GoogleFonts.openSans(color: Colors.black);
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("1h", style: _style),
            Text("2h", style: _style),
            Text("3h", style: _style),
            Text("4h", style: _style),
            Text("24h", style: _style),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PriceCard(shadowDegree: 0, hours: "1h", prices: parking.prices['tarif_1h'], parking: parking),
            PriceCard(shadowDegree: 1, hours: "2h", prices: parking.prices['tarif_2h'], parking: parking),
            PriceCard(shadowDegree: 2, hours: "3h", prices: parking.prices['tarif_3h'], parking: parking),
            PriceCard(shadowDegree: 3, hours: "4h", prices: parking.prices['tarif_4h'], parking: parking),
            PriceCard(shadowDegree: 4, hours: "24h", prices: parking.prices['tarif_24h'], parking: parking),
          ],
        ),
      ],
    ),
  );

  /*
  return Container(
    child: Column(
      children: <Widget>[
        Text("${parking.prices['tarif_1h']}"),
        Text("${parking.prices['tarif_2h']}"),
        Text("${parking.prices['tarif_3h']}"),
        Text("${parking.prices['tarif_24h']}"),
      ],
    ),
  );*/
}