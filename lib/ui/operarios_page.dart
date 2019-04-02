import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class OperariosPage extends StatefulWidget {
  _OperPageState createState() => _OperPageState();
}

class _OperPageState extends State<OperariosPage> {
  UserPrefs prefs = new UserPrefs();
  Globals globals = new Globals();
  String url;
  List data;

  // Dialogo para confirmar seleccion de maquina y usuario

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // solo botones para cerrar el dialogo!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirma datos?'),
          content: Text(globals.getMensaje(),
            textScaleFactor: 2,
            style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 12.0,
                color: Colors.black),),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancelar',
                textScaleFactor: 2,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14.0,
                    color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('Aceptar',textScaleFactor: 2,
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14.0,
                    color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }

  // Function to get the JSON data
  Future<String> getJSONData() async {
    var response = await http.get(
        // Encode the url
        Uri.encodeFull(url + '/api/operarios/'),
        // Only accept JSON response
        headers: {"Accept": "application/json"});

    // Logs the response body to the console
    print(response.body);

    // To modify the state of the app, use this method
    setState(() {
      // Get the JSON data
      var dataConvertedToJSON = json.decode(response.body);
      // Extract the required part and assign it to the global variable named data
      // data = dataConvertedToJSON['results'];
      data = dataConvertedToJSON;
    });

    return "Successfull";
  }

  @override
  void initState() {
    super.initState();
    prefs.getUrl().then((S) {
      url = S;
      // Call the getJSONData() method when the app initializes
      this.getJSONData();
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      /*appBar: new AppBar(
        title: new Text("Listado JSON de Partes via HTTP GET"),
        backgroundColor: Colors.orange,
      ),*/
      // Create a Listview and load the data when available
      body: new ListView.builder(
          padding: EdgeInsets.all(60.0),
          itemCount: data == null ? 0 : data.length,
          itemBuilder: (BuildContext context, int index) {
            return new Container(
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
                        // print(data[index]['id']);
                        globals.operarioId = data[index]['id'];
                        globals.operarioName = data[index]['apellido'] +
                            ", " +
                            data[index]['nombre'];
                        final ConfirmAction action = await _asyncConfirmDialog(context);
                        if ( action == ConfirmAction.ACCEPT ) {
                          Navigator.of(context).pushNamed('/partes');
                        } else {
                          print('no dialoga $action');
                        }
                      },
                      child: Text(
                        data[index]['apellido'] + ", " + data[index]['nombre'],
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
    );
  }
}
