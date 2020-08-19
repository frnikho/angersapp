import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parking {
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

  double distance = 0;

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
      this._infoUrl);

  factory Parking.fromJson(Map<String, dynamic> json) {
    Map<String, double> prices = new Map();
    prices['tarif_24h'] = json['tarif_24h'];
    prices['tarif_1h'] = json['tarif_1h'];
    prices['tarif_2h'] = json['tarif_2h'];
    prices['tarif_3h'] = json['tarif_3h'];
    prices['tarif_4h'] = json['tarif_4h'];
    LatLng pos = LatLng(
      json['coordonnees_'][0],
      json['coordonnees_'][1],
    );
    bool free = false;
    if (json['gratuit'] != "FAUX")
      free = true;
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
      json['url']
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
}