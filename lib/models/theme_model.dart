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
            accentColor: Colors.black,
            primaryColor: Colors.orange,
            buttonColor: Colors.deepOrange,
          ));
    } else {
      return ThemeModel(
          name: 'oscuro',
          themedata: ThemeData(
            brightness: Brightness.dark,
            accentColor: Colors.white,
            primaryColor: Colors.black,
            buttonColor: Colors.red,
          ));
    }
  }
}