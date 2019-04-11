import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/globals_singleton.dart';


class PapPage extends StatelessWidget {
  Globals globals = new Globals();
  String mensaje;
  String url;
  int nroterminal;
  BuildContext contexto;

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
          "estado": 'Mecanizando',
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

  // Guardamos evento Mecanizando el datetime lo pone el server
  Future salvaEvento() async {
    if (globals.nroLabor != 0) {
      var res = await http.post(
          Uri.encodeFull(
              url + '/api/eventonuevo/'),
          headers: {
            "Accept": "application/json"
          },
          body: {
            "nombre": 'Mecanizando',
            "laborid": globals.nroLabor.toString(),
          } );
      return res.body;
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: contexto,
      builder: (context) => new AlertDialog(
        title: new Text('Atención:'),
        content: new Text('Accion no permitida.\nDatos anteriores ya confirmados.\n'
            + globals.getMensaje()),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),// cambiar a false para trabar el back
            child: new Text('ACEPTAR'),
          ),

        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Colors.yellow,
            leading: new IconButton(
              icon: new Icon(Icons.access_time, size: 30.0),
              onPressed: () {},
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
          ),
          body: Center(
              child: new Container(
                  padding: const EdgeInsets.all(8.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.assignment, color: Colors.orange, size: 58.0),
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
                                              color:
                                                  Theme.of(context).dividerColor,
                                              width: 2,
                                              style: BorderStyle.solid)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: new RaisedButton(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15.0, horizontal: 100.0),
                                        onPressed: () async {
                                          await salvaGlobals();
                                          await salvaEvento();
                                          Navigator.of(context)
                                              .pushNamed('/mecanizando');
                                        },
                                        child: Text('INICIAR MECANIZADO',
                                            style: new TextStyle(
                                                fontSize: 28.0,
                                                color: Colors.black)),
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(30.0)),
                                        color: Colors.yellow,
                                      ),
                                    ),
                                  )
                                ]))
                      ])))),
    );
  }
}
