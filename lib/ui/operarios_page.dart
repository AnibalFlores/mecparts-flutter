import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OperariosPage extends StatefulWidget {
  _OperPageState createState() => _OperPageState();
}

class _OperPageState extends State<OperariosPage> {
  final String url = "http://192.168.1.3:3000/api/operarios/";
  List data;
  // Function to get the JSON data
  Future<String> getJSONData() async {
    var response = await http.get(
      // Encode the url
        Uri.encodeFull(url),
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

    // Call the getJSONData() method when the app initializes
    this.getJSONData();
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
                          onPressed: () {
                            print(data[index]['id']);
                            // Navigator.of(context).pushNamed('/operarios');
                          },
                          child: Text(
                            data[index]['apellido'] + ", " +
                            data[index]['nombre'],
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 16.0,
                                color: Colors.black
                            ),
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