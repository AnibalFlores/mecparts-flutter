import 'package:flutter/material.dart';
import 'package:mecparts/bloc/theme_provider.dart';
import 'package:mecparts/bloc/theme_terminal.dart';
import 'package:mecparts/helpers/user_pref.dart';
import 'package:mecparts/models/theme_model.dart';
import 'package:mecparts/ui/empezar_page.dart';
import 'package:mecparts/ui/maquinas_page.dart';
import 'package:mecparts/ui/operarios_page.dart';
import 'package:mecparts/ui/partes_page.dart';
import 'package:mecparts/ui/prefs_page.dart';
import 'package:mecparts/ui/recientes_page.dart';

class MyHomePage extends StatefulWidget {
  // MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "Mec-Parts";
  UserPrefs prefs = UserPrefs();
  int nro_terminal;
  String themename;
  ThemeTerminal _terminal;

  void initState() {
    _terminal = ThemeTerminal();

    prefs.getTheme().then((tema) {
      themename = tema;
      print('Tema actual $tema');
      if (tema == null) _terminal.updateTheme(ThemeModel.getTheme('claro'));
      setState(() {});
      _terminal.setTheme.add(ThemeModel.getTheme(themename ?? 'claro'));
    });
    super.initState();
    // fijarinit();
  }

  /*void fijarinit() {
    prefs.getCounter().then((c) {
      setState(() {
        nro_terminal = (c ?? 0);
      });
    });
  }*/

  /*void _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      prefs.getCounter().then((c) {
        _counter = (c ?? 0) + 1;
      });
    });
    prefs.saveCounter(_counter);
  }*/

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      terminal: _terminal,
      child: StreamBuilder(
        stream: _terminal.getTheme,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return CircularProgressIndicator();
          } else {
            return MaterialApp(
              title: 'Mec-Parts',
              theme: snapshot.data.themedata,
              home: EmpezarPage(),
              // Routing
              initialRoute: '/',
              routes: {
                '/empezar': (BuildContext context) => EmpezarPage(),
                '/prefs': (BuildContext context) => PrefsPage(),
                '/recientes': (BuildContext context) => RecientesPage(),
                '/operarios': (BuildContext context) => OperariosPage(),
                '/maquinas': (BuildContext context) => MaquinasPage(),
                '/partes': (BuildContext context) => PartesPage(),
              },
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _terminal.dispose();
    super.dispose();
  }
}
