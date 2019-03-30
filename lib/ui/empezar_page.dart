import 'package:flutter/material.dart';

class EmpezarPage extends StatefulWidget {
  _EmpezarPageState createState() => _EmpezarPageState();
}

class _EmpezarPageState extends State<EmpezarPage> {
  @override
  Widget build(BuildContext context) {
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
            new RaisedButton(
                splashColor: Colors.orangeAccent,
                color: Colors.green,
                child: new Text(
                  "EMPEZAR",
                  style: new TextStyle(fontSize: 30.0, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/maquinas');
                },
                padding: const EdgeInsets.all(5.0),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
            new Expanded(
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}
