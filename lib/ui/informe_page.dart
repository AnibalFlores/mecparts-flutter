import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';

enum Pendientes { terminadas, aterminar }

class InformePage extends StatefulWidget {
  _InformePageState createState() => _InformePageState();
}

class _InformePageState extends State<InformePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _aptas = TextEditingController(text: '');
  final TextEditingController _rechazos = TextEditingController(text: '');
  UserPrefs prefs = new UserPrefs();
  Globals globals = new Globals();
  int total = 0;
  int aptas = 0;
  int rechazos = 0;
  String mensaje;
  String url;
  String ruta;
  int nroterminal;
  Pendientes _pendientes = Pendientes.terminadas;
  bool building = true;

  @override
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

  Future borraGlobals() async {
    // print(url + '/api/terminalupdate/' + nroterminal.toString());
    globals.maquinaId = 0;
    globals.maquinaName = '';
    globals.operarioId = 0;
    globals.operarioName = '';
    globals.esmaquina = false;
    globals.espap = false;
    globals.esaterminar = false;
    globals.parteId = 0;
    globals.parteCodigo = '';
    globals.nroOrden = 0;
    globals.nroLabor = 0;
    globals.nota = '';
    var response = await http.put(
        Uri.encodeFull(
            url + '/api/terminalstatusupdate/' + nroterminal.toString()),
        headers: {
          "Accept": "application/json"
        },
        body: {
          // aca reseteamos los valores globales a los por defecto del terminal
          "estado": 'Apagado',
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
        });
    return response.body;
  }

  Future salvaLabor() async {
    if (globals.nroLabor != 0) {
      var response = await http.put(
          Uri.encodeFull(
              url + '/api/laborupdate/' + globals.nroLabor.toString()),
          headers: {
            "Accept": "application/json"
          },
          body: {
            "terminalid": globals.terminal.toString(),
            "nombre": globals.maquinaName,
            "operario": globals.operarioName,
            "operarioId": globals.operarioId.toString(),
            "nroorden": globals.nroOrden.toString(),
            "parteid": globals.parteId.toString(),
            "parte": globals.parteCodigo,
            // Cuando se guarda el final se calculan las duraciones de los eventos con un trigger en postgres
            "final": DateTime.now().toIso8601String(),
            "aptas": aptas.toString(),
            "rechazos": rechazos.toString(),
            "terminadas": (_pendientes == Pendientes.terminadas ? true : false)
                .toString(),
            "observacion": globals.nota
          });
    }
    return "Labor cerrada OK";
  }

  Widget _aterminar() {
    if (globals.esaterminar) {
      return Row(
        children: <Widget>[
          Radio<Pendientes>(
            value: Pendientes.terminadas,
            groupValue: _pendientes,
            onChanged: (Pendientes value) {
              setState(() {
                _pendientes = value;
              });
            },
          ),
          new Text('Terminadas',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 24.0,
              )),
          Radio<Pendientes>(
            value: Pendientes.aterminar,
            groupValue: _pendientes,
            onChanged: (Pendientes value) {
              setState(() {
                _pendientes = value;
              });
            },
          ),
          new Text('A Terminar',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 24.0,
              )),
        ],
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.settings, size: 30.0),
            onPressed: () {},
          ),
          title: Center(
              child: Text(
            'Informe de Producción      ',
            textScaleFactor: 2,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14.0,
            ),
          )),
          titleSpacing: 0.0,
        ),
        body: Center(
          child: new Container(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey,
                  child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: calculaTotal(),
                        ),
                        new TextFormField(
                          controller: _aptas,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 24.0,
                          ),
                          maxLength: 5,
                          maxLengthEnforced: true,
                          decoration: new InputDecoration(labelText: "Aptas"),
                          keyboardType: TextInputType.number,
                          onSaved: (String value) {
                            aptas = int.parse(value);
                          },
                          onEditingComplete: () {
                            calculaTotal();
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Por favor ingrese una cantidad de Aptas';
                            }
                          },
                        ),
                        new TextFormField(
                          controller: _rechazos,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 24.0,
                          ),
                          maxLength: 5,
                          maxLengthEnforced: true,
                          decoration:
                              new InputDecoration(labelText: "Rechazos"),
                          keyboardType: TextInputType.number,
                          onEditingComplete: () {
                            calculaTotal();
                          },
                          onSaved: (String value) {
                            rechazos = int.parse(value);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Por favor ingrese una cantidad de rechazos';
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 2.0),
                          child: _aterminar(),
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
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamed('/observaciones');
                                    },
                                    child: Text('OBSERVACIONES',
                                        style: new TextStyle(
                                            fontSize: 28.0,
                                            color: Colors.white)),
                                    padding: const EdgeInsets.all(5.0),
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(20.0)),
                                    color: Colors.grey,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: botonConfirmar(context),
                                ),
                              ],
                            ))
                      ]))),
        ));
  }

  Widget calculaTotal() {
    if (_aptas.text.isNotEmpty && _rechazos.text.isNotEmpty) {
      FocusScope.of(context).detach();//oculta teclado
      setState((){total = int.parse(_aptas.text) + int.parse(_rechazos.text);});

      if (total != null) {
        return Text("Total: " + total.toString(),
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 24.0,
            ));
      }
    }
  }

  Widget botonConfirmar(BuildContext context) {
    return RaisedButton(
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            await salvaLabor();
            await borraGlobals();
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/maquinas", ModalRoute.withName("/"));
          }
        },
        child: Text('CONFIRMAR',
            style: new TextStyle(fontSize: 28.0, color: Colors.white)),
        padding: const EdgeInsets.all(5.0),
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)));
  }
}
