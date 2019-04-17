import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';

class NroOrdenPage extends StatefulWidget {
  _NroOrdenPageState createState() => _NroOrdenPageState();
}

class _NroOrdenPageState extends State<NroOrdenPage> {
  final _formKey = GlobalKey<FormState>();
  UserPrefs prefs = new UserPrefs();
  Globals globals = new Globals();
  int nroorden;
  String mensaje;
  String url;
  String ruta;
  int nroterminal;

  void initState() {
    mensaje = globals.esmaquina ? 'Máquina: ' : 'Operación: ';
    mensaje += globals.maquinaName + '\nOperario: ' + globals.operarioName;
    mensaje += '\nCódigo: ' + globals.parteCodigo;
    prefs.getUrl().then((S) {
      url = S;
      prefs.getNroTerminal().then((t) {
        nroterminal = t;
      });
    });
    super.initState();
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
          "estado": defineEstado(),
          "maquinaactual": globals.maquinaId.toString(),
          "maquinaname": globals.maquinaName,
          "operarioactual": globals.operarioId.toString(),
          "operarioname": globals.operarioName,
          "laboractual": globals.nroLabor.toString(),
          "parteactual": globals.parteId.toString(),
          "partecodigo": globals.parteCodigo,
          "nroordenactual": globals.nroOrden.toString(),
          "esmaquina": globals.esmaquina.toString(),
          "espap": globals.esmaquina.toString(),
          "esaterminar": globals.esaterminar.toString(),
        });
    return response.body;
  }

  String defineEstado() {
    String estado = 'En Espera';
    if (globals.esmaquina) {
      estado = 'Mecanizando';
    } else {
      estado = 'Operando';
    }
    if (globals.espap) {
      estado = 'PAP';
    }
    return estado;
  }

  saltaRuta() async {
    if (!globals.esmaquina) {
      ruta = '/operando';
      await salvaEvento('OPE');
    } else {
      if (globals.espap && globals.esmaquina) {
        ruta = '/pap';
        await salvaEvento('PAP');
      } else{
      ruta = '/mecanizando';
      await salvaEvento('MEC');
    }
    }

    Navigator.of(context).pushNamed(ruta);
  }

  // Guardamos evento PAP el datetime lo pone el server
  Future salvaEvento(String titulo) async {
    if (globals.nroLabor != 0) {
      var res = await http.post(
          Uri.encodeFull(
              url + '/api/eventonuevo/'),
          headers: {
            "Accept": "application/json"
          },
          body: {
            "nombre": titulo,
            "laborid": globals.nroLabor.toString(),
          } );
      return res.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Center(
                child: new Container(
                    padding: const EdgeInsets.all(40.0),
                    child: Form(
                        key: _formKey,
                        child: new Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.assignment_turned_in,
                                  color: Colors.orange, size: 58.0),
                              new Text(
                                mensaje,
                                textScaleFactor: 2,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 14.0,
                                ),
                              ),
                              new TextFormField(
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 28.0,
                                ),
                                initialValue:
                                    nroorden != null ? nroorden.toString() : '',
                                maxLength: 5,
                                maxLengthEnforced: true,
                                decoration: new InputDecoration(
                                    labelText: "Ingrese el número de orden"),
                                keyboardType: TextInputType.number,
                                onSaved: (String value) async {
                                  globals.nroOrden = int.parse(value);
                                  await salvaGlobals();
                                  saltaRuta();
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Por favor ingrese un número de orden';
                                  }
                                },
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: RaisedButton(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0,
                                              horizontal: 25.0),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('ATRAS',
                                              style: new TextStyle(
                                                  fontSize: 28.0,
                                                  color: Colors.white)),
                                          shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      25.0)),
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: RaisedButton(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 25.0),
                                            onPressed: () {
                                              if (_formKey.currentState
                                                  .validate()) {
                                                // If the form is valid, we want to show a Snackbar
                                                Scaffold.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Procesando Datos...')));
                                                _formKey.currentState.save();
                                              }
                                            },
                                            child: Text('CONFIRMAR',
                                                style: new TextStyle(
                                                    fontSize: 28.0,
                                                    color: Colors.white)),
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        25.0))),
                                      ),
                                    ],
                                  ))
                            ]))),
              );
            }));
  }
}
