import 'package:mecparts/models/theme_model.dart';
import 'package:mecparts/helpers/user_pref.dart';
import 'package:rxdart/rxdart.dart';

class ThemeTerminal {
  UserPrefs _userPrefs = UserPrefs();
  final _themeController = BehaviorSubject<ThemeModel>();

  Stream<ThemeModel> get getTheme => _themeController.stream;
  Sink<ThemeModel> get setTheme => _themeController.sink;

  void updateTheme(ThemeModel model) async {
    _themeController.sink.add(model);
    _userPrefs.saveTheme(model.name);
  }

  void dispose() {
    _themeController.close();
  }
}