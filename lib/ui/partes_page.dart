import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/helpers/user_pref.dart';


class PartesPage extends StatefulWidget {
  _PartsPageState createState() => _PartsPageState();
}

class _PartsPageState extends State<PartesPage> {
  UserPrefs prefs = new UserPrefs();
  Globals globals = new Globals();
  String url;
  List data;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  bool _autorefresh = false;
  List partes;

  // Function to get the JSON data

  Future<String> getJSONData() async {
    var response = await http.get(
      // Encode the url
        Uri.encodeFull(url + '/api/partespormaquina/' + globals.maquinaId.toString()),
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
      partes = dataConvertedToJSON;
      data = dataConvertedToJSON;
      //print(data);

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

  void _handleSearchBegin() {
    ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(
      onRemove: () {
        setState(() {
          _isSearching = false;
          _searchQuery.clear();
        });
      },
    ));
    setState(() {
      _isSearching = true;
      data = _filterBySearchQuery();
     });
  }

  List _filterBySearchQuery() {
    if (_searchQuery.text.isEmpty)
    return partes;
    final RegExp regexp = RegExp(_searchQuery.text, caseSensitive: false);
    return partes.where((p) => p['codigo'].contains(regexp)).toList();
  }


  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          automaticallyImplyLeading: false,
          elevation: 0.0,
        title: TextField(
            controller: _searchQuery,
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'Buscar códigos',
            )),
          actions: <Widget>[
      IconButton(
      icon: const Icon(Icons.search),
      onPressed: _handleSearchBegin,
      tooltip: 'Buscar',
      )]),
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
    );
  }
}
