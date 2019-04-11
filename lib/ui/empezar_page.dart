import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';

class EmpezarPage extends StatefulWidget {
  _EmpezarPageState createState() => _EmpezarPageState();
}

class _EmpezarPageState extends State<EmpezarPage> {
  final UserPrefs prefs = new UserPrefs();
  final Connectivity _connectivity = new Connectivity();
  Globals globals = new Globals();
  String _connectionStatus;
  String ruta;

  var _subscription;
  String url;
  int nroterminal;

  @override
  initState() {
    super.initState();
    _subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result.toString();
      });
    });
    prefs.getUrl().then((S) {
      url = S;
      prefs.getNroTerminal().then((t) async {
        nroterminal = t;
        ruta = await definirRuta();
      });
    });
  }

  @override
  dispose() {
    super.dispose();
    _subscription.cancel();
  }

  Future checkServer() async {
    http.Response response = await http.get(url + "/api/serverinfo/");
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    }
  }

  Future checkStatus() async {
    // print(url + "/api/terminalstatus/" + nroterminal.toString());
    http.Response response =
        await http.get(url + "/api/terminalstatus/" + nroterminal.toString());
    if (response.statusCode == HttpStatus.ok) {
      return response.body;
    }
  }

// define la ruta y recupera globales (por si la app se cerro volver al estado en curso)
  Future definirRuta() async {
    String _ruta;
    var status = json.decode(await checkStatus());
    // print(status);
    // aca no se han confirmado maquina ni operario
    if (status['estado'] == 'Apagado') {
      _ruta = '/maquinas';
    }
    // aca se han confirmado maquina y operario pero no la parte y el nro de orden
    if (status['estado'] == 'En Espera') {
      _ruta = '/partes';
    }
    // aca es una maquina pero no inicio mecanizado
    if (status['estado'] == 'PAP') {
      _ruta = '/pap';
    }
    // aca es un mecanizado en curso
    if (status['estado'] == 'Mecanizando') {
      _ruta = '/mecanizando';
    }
    // aca es una operacion en curso
    if (status['estado'] == 'Operando') {
      _ruta = '/operando';
    }

    // aca recuperamos los valores globales o por defecto del terminal
    globals.maquinaId = status['maquinaactual'];
    globals.maquinaName = status['maquinaname'];
    globals.operarioId = status['operarioactual'];
    globals.operarioName = status['operarioname'];
    globals.nroLabor = status['laboractual'];
    globals.parteId = status['parteactual'];
    globals.parteCodigo = status['partecodigo'];
    globals.nroOrden = status['nroordenactual'];
    globals.esmaquina = status['esmaquina'];
    globals.espap = status['espap'];
    globals.esaterminar = status['esaterminar'];
    return _ruta;
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionStatus == 'ConnectivityResult.wifi') {
      return Scaffold(
        appBar: AppBar(
          title: Text(' Mec-Parts'),
          titleSpacing: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/prefs');
              },
            )
          ],
        ),
        body: FutureBuilder<Object>(
            future: checkServer(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var serverinfo = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(80.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      new RaisedButton(
                          splashColor: Colors.orangeAccent,
                          color: Colors.green,
                          child: new Text(
                            "EMPEZAR",
                            style: new TextStyle(
                                fontSize: 30.0, color: Colors.white),
                          ),
                          onPressed: () {
                            // ya tenemos la conexion la guardamos en globales
                            globals.terminal = nroterminal;
                            globals.url = url;
                            Navigator.of(context).pushNamed(this.ruta);
                          },
                          padding: const EdgeInsets.all(5.0),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      new Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.laptop_mac,
                                color: Colors.grey,
                                size: 40.0,
                              ),
                              Text(
                                serverinfo,
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(80.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Center(
                          child: new CircularProgressIndicator(),
                        ),
                      ),
                      new RaisedButton(
                          splashColor: Colors.orangeAccent,
                          color: Colors.red,
                          child: new Text(
                            "ERROR DE SERVIDOR",
                            style: new TextStyle(
                                fontSize: 30.0, color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/prefs');
                          },
                          padding: const EdgeInsets.all(5.0),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      Padding(
                        padding: const EdgeInsets.all(28.0),
                        child: Center(
                            child: Text(
                                'Verifique su conexión  al servidor y su nro de terminal')),
                      ),
                      new Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                );
              }
            }),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(' Mec-Parts'),
          titleSpacing: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/prefs');
              },
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(80.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                  child: new CircularProgressIndicator(),
                ),
              ),
              new RaisedButton(
                  splashColor: Colors.orangeAccent,
                  color: Colors.red,
                  child: new Text(
                    "ERROR DE RED",
                    style: new TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/prefs');
                  },
                  padding: const EdgeInsets.all(5.0),
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0))),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                    child: Text(
                        'Verifique su conexión WiFi y/o su nro de terminal y servidor')),
              ),
              new Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      );
    }
  }
}
