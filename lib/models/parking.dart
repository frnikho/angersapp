import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Parking  {
  String _id;
  int _spaceCars;
  int _spaceBikes;
  int _spacePmr; // place handicap
  String _imageUrl;
  Map<String, double> _prices;
  bool _free;
  LatLng _location;
  String _name;
  String _address;
  String _infoUrl;
  String _openTime = "";
  String _closeTime = "";

  double distance = 0;
  bool isFav = false;

  void toggleFav() async {
    this.isFav = !this.isFav;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("${id}_favorite", this.isFav);
  }

  Future<bool> loadFavStorage() async {
    this.isFav = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool result = prefs.getBool("${id}_favorite");
    if (result != null && result)
      this.isFav = true;
    return true;
  }

  Parking(
      this._id,
      this._spaceCars,
      this._spaceBikes,
      this._spacePmr,
      this._imageUrl,
      this._prices,
      this._free,
      this._location,
      this._name,
      this._address,
      this._infoUrl,
      this._openTime,
      this._closeTime);

  factory Parking.fromJson(Map<String, dynamic> json) {
    Map<String, double> prices = new Map();
    prices['tarif_1h'] = json['tarif_1h'] ?? -1;
    prices['tarif_2h'] = json['tarif_2h'] ?? -1;
    prices['tarif_3h'] = json['tarif_3h'] ?? -1;
    prices['tarif_4h'] = json['tarif_4h'] ?? -1;
    prices['tarif_24h'] = json['tarif_24h'] ?? -1;
    LatLng pos = LatLng(
      json['coordonnees_'][0],
      json['coordonnees_'][1],
    );
    bool free = false;
    if (json['gratuit'] != "FAUX")
      free = true;

    String open = json['horaires_ouverture'];
    String close = json['horaires_fermeture'];
    return Parking(
      json['id_parking'],
      json['nb_places'],
      json['nb_velo'],
      json['nb_pmr'],
      json['photo'],
      prices,
      free,
      pos,
      json['nom'],
      json['adresse'],
      json['url'],
      open ?? "00:00",
      close ?? "00:00"
    );
  }

  String get infoUrl => _infoUrl;
  String get address => _address;
  String get name => _name;
  LatLng get location => _location;
  bool get free => _free;
  Map<String, double> get prices => _prices;
  String get imageUrl => _imageUrl;
  int get spacePmr => _spacePmr;
  int get spaceBikes => _spaceBikes;
  int get spaceCars => _spaceCars;
  String get id => _id;
  String get closeTime => _closeTime;
  String get openTime => _openTime;

  Future<int> getSpaceLeft() async {
    http.Response response = await http.get("https://data.angers.fr/api/records/1.0/search/?dataset=parking-angers&q=$id&rows=-1&timezone=Europe%2FParis");
    return jsonDecode(response.body)['records'][0]['fields']['disponible'] ?? 0;
  }

}