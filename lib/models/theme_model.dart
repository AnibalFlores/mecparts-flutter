import 'package:flutter/material.dart';

class ThemeModel {
  final ThemeData themedata;
  final String name;

  const ThemeModel({this.name, this.themedata});

  static ThemeModel getTheme(String name) {
    if (name == "claro") {
      return ThemeModel(
          name: 'claro',
          themedata: ThemeData(
              brightness: Brightness.light,
              accentColor: Colors.black54,
              primaryColor: Colors.orange,
              buttonColor: Colors.deepOrange,
              fontFamily: 'Lato',
              textTheme: TextTheme(
                headline:
                    TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                title: TextStyle(fontSize: 26.0, fontStyle: FontStyle.italic),
                body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
              )));
    } else {
      return ThemeModel(
          name: 'oscuro',
          themedata: ThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.white,
              primaryColor: Colors.black,
              buttonColor: Colors.red,
              fontFamily: 'Lato',
              textTheme: TextTheme(
                headline:
                    TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold,color: Colors.blueAccent),
                title: TextStyle(fontSize: 26.0, fontStyle: FontStyle.italic, color: Colors.grey),
                body1: TextStyle(fontSize: 14.0, fontFamily: 'Hind',color: Colors.grey),
                body2: TextStyle(fontSize: 14.0, fontFamily: 'Hind',color: Colors.grey),
                button: TextStyle(fontSize: 14.0, fontFamily: 'Hind',color: Colors.grey),
              )));
    }
  }
}
