import 'package:flutter/material.dart';
import 'package:mecparts/bloc/theme_provider.dart';
import 'package:mecparts/bloc/theme_terminal.dart';
import 'package:mecparts/helpers/user_pref.dart';
import 'package:mecparts/models/theme_model.dart';

class PrefsPage extends StatefulWidget {
  _PrefsPageState createState() => _PrefsPageState();
}

class _PrefsPageState extends State<PrefsPage> {
  final _formKey = GlobalKey<FormState>();
  //ThemeTerminal _terminal;
  UserPrefs prefs = UserPrefs();
  int nroterminal;
  String url;
  String _tema;
  bool luz;

  @override
  void initState() {
    super.initState();
    prefs.getTheme().then((t) {
      _tema = t;
      luz = ('claro' == _tema);
    });

    prefs.getUrl().then((s) {
      url = s;
    });

    prefs.getNroTerminal().then((n) {
      nroterminal = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeTerminal terminal = ThemeProvider.of(context).terminal;
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text('Preferencias'),
          titleSpacing: 0.0,
        ),
        body: new Container(
            padding: const EdgeInsets.all(40.0),
            child: StreamBuilder(
                stream: terminal.getTheme,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data != null) {
                    return new Form(
                        key: _formKey,
                        child: new SingleChildScrollView(
                            child: new Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                              new TextFormField(
                                initialValue: nroterminal == null
                                    ? ""
                                    : nroterminal.toString(),
                                decoration: new InputDecoration(
                                    labelText: "Ingrese el número de terminal"),
                                keyboardType: TextInputType.number,
                                onSaved: (String value) {
                                  prefs.saveNroTerminal(int.parse(value));

                                  // code when the user saves the form.
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Por favor ingrese un número de terminal';
                                  } else if (int.parse(value) <= 0) {
                                    return 'El el número de terminal debe ser mayor a cero';
                                  }
                                },
                              ),
                              new TextFormField(
                                initialValue: url == null ? "http://" : url,
                                decoration: new InputDecoration(
                                    labelText: "Ingrese la Url del server"),
                                keyboardType: TextInputType.url,
                                onSaved: (String value) {
                                  prefs.saveUrl(value);

                                  // code when the user saves the form.
                                },
                                validator: (value) {
                                  if (value.isEmpty || value == 'http://') {
                                    return 'Por favor ingrese una url para el servidor. Ej.: http://192.168.0.100:2345';
                                  }
                                },
                              ),
                              Row(
                                children: <Widget>[
                                  new Text('Tema ' + _tema),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: new Switch(
                                      value: luz,
                                      //title: const Text('Luces'),
                                      /* items: <String>['claro', 'oscuro']
                                      .map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: new Text(value),
                                    );
                                  }).toList(),*/
                                      //secondary:const Icon(Icons.lightbulb_outline),
                                      // hint: Text("Cambiar modo de color"),
                                      /*onChanged: (_) {
                                    terminal.updateTheme(ThemeModel.getTheme(
                                        snapshot.data.name == "claro"
                                            ? 'oscuro'
                                            : 'claro'));
                                  },*/
                                      onChanged: (bool value) {
                                        setState(() {
                                          luz = value;
                                          _tema = luz ? 'claro' : 'oscuro';
                                        });

                                        if (value) {
                                          terminal.updateTheme(
                                              ThemeModel.getTheme('claro'));
                                        } else {
                                          terminal.updateTheme(
                                              ThemeModel.getTheme('oscuro'));
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 20.0),
                                  child: RaisedButton(
                                      child: Text('Guardar',
                                          style: new TextStyle(
                                              fontSize: 28.0,
                                              color: Colors.white)),
                                      padding: const EdgeInsets.all(15.0),
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0)),
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          // If the form is valid, we want to show a Snackbar
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  action: SnackBarAction(
                                                      textColor: Colors.white,
                                                      disabledTextColor:
                                                          Colors.orange,
                                                      label: 'OK',
                                                      onPressed: Scaffold.of(
                                                              context)
                                                          .hideCurrentSnackBar),
                                                  content: Text(
                                                      'Preferencias guardadas. Puede ser necesario reiniciar.')));
                                          _formKey.currentState.save();
                                        }
                                      }))
                            ])));
                  } else {
                    return Container(child: new Text('No hay datos'));
                  }
                })));
  }
}
