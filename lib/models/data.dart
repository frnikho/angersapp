import 'dart:convert';

import 'package:angers/models/parking.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

const String availableUrl = "https://data.angers.fr/api/records/1.0/search/?dataset=parking-angers&q=&rows=100&facet=nom";
const String parkingUrl = "https://data.angers.fr/api/records/1.0/search/?dataset=angers_stationnement&q=&rows=100&timezone=Europe%2FParis";

enum sortType {unknown, alpha, location, size, price_1h, price_24h}

class Data with ChangeNotifier {

  List<Parking> parking;
  sortType sort = sortType.unknown;

  void update() {
    notifyListeners();
  }

  Future<void> calcDistance(LocationData currentPosition) async {
    for (Parking p in parking) {
      LatLng p1 = LatLng(currentPosition.latitude, currentPosition.longitude);
      LatLng p2 = LatLng(p.location.latitude, p.location.longitude);
      Distance distance = new Distance();
      double km = distance.distance(p1, p2);
      p.distance = km / 1000;
    }
  }
  
  Future<bool> fetchAllParking(LocationData locationData) async {
    if (parking != null)
      parking.clear();
    parking = new List();
    http.Response response = await http.get("$parkingUrl");
    List<dynamic> data = jsonDecode(response.body)['records'];
    data.forEach((element) {
      Map<String, dynamic> parkingData = element['fields'];
      parking.add(Parking.fromJson(parkingData));
      if (locationData != null)
        calcDistance(locationData);
    });
    if (sort != sortType.unknown) {
      if (sort == sortType.alpha)
        parking.sort((a, b) => a.name.compareTo(b.name));
      if (sort == sortType.location)
        parking.sort((a, b) => a.distance.compareTo(b.distance));
      if (sort == sortType.size)
        parking.sort((a, b) => b.spaceCars.compareTo(a.spaceCars));
      if (sort == sortType.price_24h)
        parking.sort((a, b) => a.prices['tarif_24h'].compareTo(b.prices['tarif_24h']));
      if (sort == sortType.price_24h)
        parking.sort((a, b) => a.prices['tarif_1h'].compareTo(b.prices['tarif_1h']));
    }
    return (true);
  }

  void sortByAlpha() {
    sort = sortType.alpha;
    update();
  }

  void sortByDistance() {
    sort = sortType.location;
    update();
  }

  void sortBySize() {
    sort = sortType.size;
    update();
  }

  void sortByPrice24h() {
    sort = sortType.price_24h;
    update();
  }

  void sortByPrice1h() {
    sort = sortType.price_1h;
    update();
  }

}