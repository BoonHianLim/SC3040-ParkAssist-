import 'package:flutter/material.dart';
//import 'package:parkassist/boundary/mainpage.dart';
import 'package:parkassist/boundary/map_interface.dart';
import 'package:parkassist/boundary/favouritesInterface.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FavouritesInterface(),
    );
  }
}
