import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/bloc/theme_provider.dart';
import 'package:mecparts/bloc/theme_terminal.dart';
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';
import 'package:mecparts/models/theme_model.dart';

class PartesPage extends StatefulWidget {
  _PartsPageState createState() => _PartsPageState();
}

class _PartsPageState extends State<PartesPage> {
  // TODO Pasar a bloc
  ThemeTerminal terminal;
  UserPrefs prefs = new UserPrefs();
  Globals globals = new Globals();
  String url;
  int nroterminal;
  List data;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _codigoaBuscar = TextEditingController();
  bool _filtrado = false;
  bool _limpiar = false;
  bool esclaro = true;
  List partes;

  // Función para consultar JSON de partes x maquina

  Future<String> getJSONData() async {
    var response = await http.get(
        // Encode the url
        Uri.encodeFull(
            url + '/api/partespormaquina/' + globals.maquinaId.toString()),
        // Only accept JSON response
        headers: {"Accept": "application/json"});

    // Logs the response body to the console
    // print(response.body);

    // To modify the state of the app, use this method
    setState(() {
      // Get the JSON data
      var dataConvertedToJSON = json.decode(response.body);
      // Extract the required part and assign it to the global variable named data
      // data = dataConvertedToJSON['results'];
      partes = dataConvertedToJSON;
      data = dataConvertedToJSON;
      //print(data);
    });

    return "Successfull";
  }

  // Funcion para crear la labor en el server
  Future<String> getLaborId() async {
    if (globals.nroLabor == 0) {
      var response = await http
          .post(Uri.encodeFull(url + '/api/terminalnuevalabor/'), headers: {
        "Accept": "application/json"
      }, body: {
        "nombre": globals.maquinaName,
        "operario": globals.operarioName,
        "operarioId": globals.operarioId.toString()
      });
      var labor = jsonDecode(response.body);
      globals.nroLabor = labor['id'];
      globals.iniciolabor = DateTime.parse(labor['inicio']);
    }
    return "Labor iniciada OK: " + globals.nroLabor.toString();
  }

  @override
  void initState() {
    super.initState();
    prefs.getUrl().then((S) {
      url = S;
      prefs.getNroTerminal().then((t) {
        nroterminal = t;
        // Call the getJSONData() method when the app initializes
        this.getJSONData();
        this.getLaborId().then((s) async {
          // print(s);
          await salvaGlobals();
          // print(s);
        });
      });
    });
  }

  Future salvaGlobals() async {
    // print(url + '/api/terminalupdate/' + nroterminal.toString());
    var response = await http.put(
        Uri.encodeFull(
            url + '/api/terminalstatusupdate/' + nroterminal.toString()),
        headers: {
          "Accept": "application/json"
        },
        body: {
          // aca resguardamos los valores globales o por defecto del terminal
          "estado": 'En Espera',
          "iniciolabor": new DateTime.now().toIso8601String(),
          "inicioevento": new DateTime.now().toIso8601String(),
          "maquinaactual": globals.maquinaId.toString(),
          "maquinaname": globals.maquinaName,
          "operarioactual": globals.operarioId.toString(),
          "operarioname": globals.operarioName,
          "laboractual": globals.nroLabor.toString(),
          /*"parteactual" : globals.parteId.toString(),
        "partecodigo" : '', // con globals.parteCodigo explota
        "nroordenactual" : globals.nroOrden.toString(),*/
          "esmaquina": globals.esmaquina.toString(),
          "espap": globals.espap.toString(),
        });
    return response.body;
  }

  void _iniciarBusqueda() {
    setState(() {
      data = _filterPorBusqueda();
    });
  }

  List _filterPorBusqueda() {
    if (_codigoaBuscar.text.isEmpty) {
      _filtrado = false;
      return partes;
    }

    final RegExp regexp = RegExp(_codigoaBuscar.text, caseSensitive: false);
    _filtrado = true;
    return partes.where((p) => p['codigo'].contains(regexp)).toList();
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Atención:'),
                content: new Text(
                    'Accion no permitida.\nDatos anteriores ya confirmados.\n' +
                        globals.getMensaje()),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context)
                        .pop(false), // cambiar a false para trabar el back
                    child: new Text('ACEPTAR'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future _esclaro() async {
    esclaro = await prefs.getTheme() == 'claro';
  }

  @override
  Widget build(BuildContext context) {
    terminal = ThemeProvider.of(context).terminal;
    _esclaro();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
            automaticallyImplyLeading: false,
            elevation: 0.0,
            leading: Icon(Icons.search, size: 40.0),
            title: TextField(
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 28.0,
                ),
                controller: _codigoaBuscar,
                onEditingComplete: _BusquedaEdit,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Buscar códigos...',
                )),
            actions: <Widget>[
              IconButton(
                icon: Icon(esclaro ? Icons.brightness_3 : Icons.wb_sunny),
                onPressed: () async {
                  setState(() {
                    terminal.updateTheme(
                        ThemeModel.getTheme(esclaro ? 'oscuro' : 'claro'));
                    _esclaro();
                  });
                },
              )
            ]),
        // Create a Listview and load the data when available
        body: new ListView.builder(
            padding: EdgeInsets.all(60.0),
            itemCount: data == null ? 0 : data.length,
            itemBuilder: (BuildContext context, int index) {
              return new Container(
                decoration: BoxDecoration(
                  border: new Border(
                      bottom: new BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                          style: BorderStyle.solid)),
                ),
                child: new Center(
                    child: new Column(
                  // Stretch the cards in horizontal axis
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new FlatButton(
                        color: Colors.amber,
                        onPressed: () async {
                          if (await _validaParte(data[index]['id'])) {
                            globals.parteId = data[index]['id'];
                            globals.parteCodigo = data[index]['codigo'];
                            Navigator.of(context).pushNamed('/nroorden');
                          } else {
                            _parteNoValida();
                          }
                        },
                        child: Text(
                          data[index]['codigo'],
                          textScaleFactor: 2,
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 16.0,
                              color: Colors.black),
                        ),
                        shape: new StadiumBorder(),
                        padding: const EdgeInsets.all(8.0),
                      ),
                    ),
                  ],
                )),
              );
            }),
        floatingActionButton: StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return FloatingActionButton(
                child: _filtrado
                    ? Icon(
                        Icons.filter_list,
                        size: 40.0,
                      )
                    : Icon(
                        Icons.help_outline,
                        size: 40.0,
                      ),
                onPressed: () {
                  _showToast(context);
                },
                backgroundColor: Colors.green,
                foregroundColor: Colors.black,
                tooltip: 'Buscar',
              );
            }),
      ),
    );
  }

  void _BusquedaFlip() {
    if (_limpiar) {
      _codigoaBuscar.clear();
      _iniciarBusqueda();
    } else {
      _limpiar = true;
      _iniciarBusqueda();
    }
  }

  void _BusquedaEdit() {
    FocusScope.of(context).detach(); //oculta teclado
    _limpiar = false;
    _iniciarBusqueda();
  }

  Future<bool> _parteNoValida() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: new Text('Atención:'),
                content: new Text(
                    'El código no es válido.\nSeleccione otro.\n' +
                        globals.getMensaje()),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context)
                        .pop(false), // cambiar a false para trabar el back
                    child: new Text('ACEPTAR'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<bool> _validaParte(id) async {
    if (id != 0) {
      var res = await http.get(
          Uri.encodeFull(url + '/api/parte/' + id.toString()),
          headers: {"Accept": "application/json"});
      var parte = json.decode(res.body);
      return parte['activa'] == true;
    }

    return false;
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    _BusquedaFlip();
    scaffold.showSnackBar(
      SnackBar(
        content: Text('Total: ' + data.length.toString()),
        action: SnackBarAction(
            textColor: Colors.white,
            disabledTextColor: Colors.orange,
            label: 'OK',
            onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
