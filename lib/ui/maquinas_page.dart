import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/data_base.dart';
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';

class MaquinasPage extends StatefulWidget {
  _MaqsPageState createState() => _MaqsPageState();
}

class _MaqsPageState extends State<MaquinasPage> {

  // TODO pasar todo esto a bloc
  UserPrefs prefs = new UserPrefs();
  DbHelper db = new DbHelper();
  Globals globals = new Globals();
  String url;
  String _terminal;
  List data;
  String ruta = '/operarios';

  // Function to get the JSON data
  Future<String> getJSONData() async {
    var response = await http.get(
        // Encode the url
        Uri.encodeFull(url + '/api/maquinasporterminal/' + _terminal),
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

      data = dataConvertedToJSON;
    });

    return "Successfull";
  }

  @override
  void initState() {
    super.initState();

    db.getOperarios().then((ope) {
    if (ope == null || ope.length == 0)
    { ruta ='/operarios';}
    else {ruta ='/recientes';}
    });

    prefs.getNroTerminal().then((nro) {
      _terminal = nro.toString();
      prefs.getUrl().then((S) {
        url = S;
        // Call the getJSONData() method when the app initializes
        this.getJSONData();
      });
    });
  }

  @override
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
              decoration: BoxDecoration(
                border: new Border(
                    bottom: new BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 2,
                        style: BorderStyle.solid
                    )),

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
                      onPressed: () {
                        // print(data[index]['id']);
                        globals.maquinaId = data[index]['id'];
                        globals.maquinaName = data[index]['nombre'];
                        globals.esmaquina = data[index]['tipo'] == 'Máquina';
                        globals.espap = data[index]['pap'];
                        globals.esaterminar = data[index]['aterminar'];
                        Navigator.of(context).pushNamed(ruta);
                      },
                      child: Text(
                        data[index]['nombre'],
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
