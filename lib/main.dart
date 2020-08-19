import 'package:angers/screen/parking_list_screen.dart';
import 'package:angers/screen/parking_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/data.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Data>(
      create: (context) => Data(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          HomeScreen.id: (context) => HomeScreen(),
          ParkingListScreen.id: (context) => ParkingListScreen(),
        },
        home: ParkingListScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {

  static String id = "HomeScreen";

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
