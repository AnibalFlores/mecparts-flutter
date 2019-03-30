import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  //theme name to be stored in shared prefs
  static const String THEME = "theme";
  static const String COUNTER = "counter";
  static const String NROTERMINAL = "nroterminal";
  static const String URLTERMINAL = "urlterminal";


  SharedPreferences _prefs;

  void saveTheme(String nombre) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setString(THEME, nombre);
  }

  Future<String> getTheme() async {
    _prefs = await SharedPreferences.getInstance();
    String nombre = _prefs.getString(THEME);
    return nombre;
  }

  void saveUrl(String urlterminal) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setString(URLTERMINAL, urlterminal);
  }

  Future<String> getUrl() async {
    _prefs = await SharedPreferences.getInstance();
    String urlterminal = _prefs.getString(URLTERMINAL);
    return urlterminal;
  }

  Future<int> getContador() async {
    _prefs = await SharedPreferences.getInstance();
    int counter = _prefs.getInt(COUNTER);
    return counter;
  }

  void saveContador(int counter) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setInt(COUNTER, counter);
  }

  Future<int> getNroTerminal() async {
    _prefs = await SharedPreferences.getInstance();
    int nro = _prefs.getInt(NROTERMINAL);
    return nro;
  }

  void saveNroTerminal(int nro) async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setInt(NROTERMINAL, nro);
  }
}