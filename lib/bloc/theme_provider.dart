import 'package:mecparts/bloc/theme_terminal.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends InheritedWidget {
  ThemeProvider({this.terminal, Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final ThemeTerminal terminal;

  static ThemeProvider of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ThemeProvider)
    as ThemeProvider);
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return true;
  }
}
