import 'package:flutter/material.dart';
import 'package:mecparts/helpers/globals_singleton.dart';


class NotasPage extends StatefulWidget {
  _NotasPageState createState() => _NotasPageState();
}

class _NotasPageState extends State<NotasPage> {
  final _formKey = GlobalKey<FormState>();

  Globals globals = new Globals();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.edit, size: 30.0),
            onPressed: () {},
          ),
          title: Center(
              child: Text(
            'Observaciones      ',
            textScaleFactor: 2,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14.0,
            ),
          )),
          titleSpacing: 0.0,
        ),
        body: StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Center(
                child: new Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: _formKey,
                        child: new Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new TextFormField(
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 24.0,
                                ),
                                keyboardType: TextInputType.text,
                                initialValue: globals.nota,
                                maxLines: 3,
                                maxLength: 144,
                                onSaved: (s) {
                                  globals.nota = s;
                                  Navigator.of(context).pop();
                                },
                              ),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: RaisedButton(
                                            onPressed: () {
                                              if (_formKey.currentState
                                                  .validate()) {
                                               _formKey.currentState.save();
                                              }
                                            },
                                            child: Text('LISTO',
                                                style: new TextStyle(
                                                    fontSize: 24.0,
                                                    color: Colors.white)),
                                            padding: const EdgeInsets.all(5.0),
                                            shape: new RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        20.0))),
                                      ),
                                    ],
                                  ))
                            ]))),
              );
            }));
  }
}
