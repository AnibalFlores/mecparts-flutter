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
  ThemeTerminal _terminal;
  UserPrefs prefs = UserPrefs();
  int nroterminal;
  String url;

  bool luz;

  void initState() {
    _terminal = ThemeTerminal();

    prefs.getTheme().then((tema) {
      luz = ('claro' == tema);
    });
    prefs.getUrl().then((s){ url = s;});

    prefs.getNroTerminal().then((n){nroterminal = n;});

    super.initState();
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
                                initialValue: nroterminal.toString(),
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
                                  }
                                },
                              ),
                              new TextFormField(
                                initialValue: url,
                                decoration: new InputDecoration(
                                    labelText: "Ingrese la Url del server"),
                                keyboardType: TextInputType.url,
                                onSaved: (String value) {
                                  prefs.saveUrl(value);

                                  // code when the user saves the form.
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Por favor ingrese una url para el servidor';
                                  }
                                },
                              ),
                              Row(
                                children: <Widget>[
                                  new Text('LUZ'),
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
                                        });

                                        if (value) {
                                          terminal.updateTheme(
                                              ThemeModel.getTheme('claro'));
                                        } else {
                                          terminal.updateTheme(
                                              ThemeModel.getTheme('oscuro'));
                                        }
                                        print(value);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: RaisedButton(
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          // If the form is valid, we want to show a Snackbar
                                          Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Procesando Datos')));
                                          _formKey.currentState.save();

                                        }
                                      },
                                      child: Text('Guardar',
                                          style: new TextStyle(
                                              fontSize: 20.0,
                                              color: Colors.white)),
                                      padding: const EdgeInsets.all(5.0),
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(18.0))))
                            ])));
                  } else {
                    return Container(child: new Text('No hay datos'));
                  }
                })));
  }
}
