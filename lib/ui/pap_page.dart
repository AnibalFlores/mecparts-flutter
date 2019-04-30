import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/bloc/theme_provider.dart';
import 'package:mecparts/bloc/theme_terminal.dart';
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';
import 'package:mecparts/models/theme_model.dart';

class PapPage extends StatelessWidget {
  Globals globals = new Globals();
  String mensaje;
  String url;
  String ruta;
  int nroterminal;
  BuildContext contexto;
  UserPrefs prefs = UserPrefs();
  bool esclaro = true;

  // Guardamos el status pasando de pap a mecanizando
  Future salvaGlobals() async {
    url = globals.url;
    // print(url + '/api/terminalupdate/' + nroterminal.toString());
    var response = await http.put(
        Uri.encodeFull(
            url + '/api/terminalstatusupdate/' + nroterminal.toString()),
        headers: {
          "Accept": "application/json"
        },
        body: {
          // aca resguardamos los valores globales o por defecto del terminal
          "estado": globals.esmaquina ? 'Mecanizando' : 'Operando',
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

  // Guardamos evento Mecanizando u Operando el datetime lo pone el server
  Future salvaEvento() async {
    if (globals.nroLabor != 0) {
      var res =
          await http.post(Uri.encodeFull(url + '/api/eventonuevo/'), headers: {
        "Accept": "application/json"
      }, body: {
        "nombre": globals.esmaquina ? 'MEC' : 'OPE',
        "laborid": globals.nroLabor.toString(),
      });
      var event = json.decode(res.body);
      globals.inicioevento = DateTime.parse(event['inicio']);
      return event;
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: contexto,
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

  String _formatDuration(Duration tiempo) {
    String dosdigitos(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String minutos = dosdigitos(tiempo.inMinutes.remainder(60));
    String segundos = dosdigitos(tiempo.inSeconds.remainder(60));
    return "${dosdigitos(tiempo.inHours)}:$minutos:$segundos";
  }

  Future<bool> _tiempoTranscurrido() {
    Duration tiempo = DateTime.now().difference(globals.inicioevento);
    return showDialog(
          context: contexto,
          builder: (context) => new AlertDialog(
                title: new Text('Tiempo aproximado transcurrido'),
                content: new Text(_formatDuration(tiempo), textScaleFactor: 2),
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
    ThemeTerminal terminal = ThemeProvider.of(context).terminal;
    _esclaro();
    contexto = context;
    nroterminal = globals.terminal;
    mensaje = globals.esmaquina ? 'Máquina: ' : 'Operación: ';
    mensaje += globals.maquinaName + '\nOperario: ' + globals.operarioName;
    mensaje += '\nCódigo: ' + globals.parteCodigo;
    mensaje += '\nOrden: ' + globals.nroOrden.toString();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: new IconButton(
                icon: new Icon(Icons.access_time, size: 30.0),
                onPressed: () {
                  _tiempoTranscurrido();
                },
              ),
              title: Center(
                  child: Text(
                'Puesta A Punto      ',
                textScaleFactor: 2,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14.0,
                ),
              )),
              titleSpacing: 0.0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(esclaro ? Icons.brightness_3 : Icons.wb_sunny),
                  onPressed: () async {
                    terminal.updateTheme(
                        ThemeModel.getTheme(esclaro ? 'oscuro' : 'claro'));
                    await _esclaro();
                  },
                )
              ]),
          body: Center(
              child: new Container(
                  padding: const EdgeInsets.all(8.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.assignment,
                            color: Colors.orange, size: 58.0),
                        new Text(
                          mensaje,
                          textScaleFactor: 2,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 14.0,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 8.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: new Border(
                                          top: new BorderSide(
                                              color: Theme.of(context)
                                                  .dividerColor,
                                              width: 2,
                                              style: BorderStyle.solid)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new RaisedButton(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 100.0),
                                        onPressed: () async {
                                          ruta = globals.esmaquina
                                              ? '/mecanizando'
                                              : '/operando';
                                          await salvaGlobals();
                                          await salvaEvento();
                                          Navigator.of(context).pushNamed(ruta);
                                        },
                                        child: Text(
                                            globals.esmaquina
                                                ? 'INICIAR MECANIZADO'
                                                : 'INICIAR OPERACION',
                                            style: new TextStyle(
                                                fontSize: 28.0,
                                                color: Colors.black)),
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    30.0)),
                                        color: Colors.yellowAccent,
                                      ),
                                    ),
                                  )
                                ]))
                      ])))),
    );
  }
}
