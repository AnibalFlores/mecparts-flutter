import 'package:flutter/material.dart';
import 'package:mecparts/helpers/data_base.dart';
import 'package:mecparts/helpers/globals_singleton.dart';
import 'package:mecparts/models/operario_model.dart';

enum ConfirmAction { CANCEL, ACCEPT }

class RecientesPage extends StatefulWidget {
  _RecienPageState createState() => _RecienPageState();
}

class _RecienPageState extends State<RecientesPage> {
  DbHelper db = new DbHelper();
  Globals globals = new Globals();
  List data;

  // Dialogo para confirmar seleccion de maquina y usuario

  Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // solo botones para cerrar el dialogo!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirma datos?'),
          content: Text(
            globals.getMensaje(),
            textScaleFactor: 2,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 12.0,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text(
                'Cancelar',
                textScaleFactor: 2,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14.0,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text(
                'Aceptar',
                textScaleFactor: 2,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14.0,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.ACCEPT);
              },
            )
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    db.getOperarios().then((l) {data = l;
    if (data == null || data.length == 0)
    { Navigator.of(context).pushNamed('/operarios');}
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
      body: FutureBuilder<Object>(
        future: db.getOperarios(),
        builder: (context, snapshot) {
          return Column(
            //mainAxisSize: MainAxisSize.min,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
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
                                  onPressed: () async {
                                    // print(data[index]['id']);
                                    globals.operarioId = data[index]['id'];
                                    globals.operarioName = data[index]['apellido'] +
                                        ", " +
                                        data[index]['nombre'];
                                    final ConfirmAction action =
                                    await _asyncConfirmDialog(context);
                                    if (action == ConfirmAction.ACCEPT) {
                                      await db.saveOperario(new Operario(
                                          data[index]['id'],
                                          data[index]['nombre'],
                                          data[index]['apellido'],
                                          new DateTime.now()));
                                      Navigator.of(context).pushReplacementNamed('/partes');
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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 68.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new FlatButton(
                      color: Colors.green,
                      onPressed: () {
                          Navigator.of(context).pushNamed('/operarios');
                      },
                      child: Text('Soy otro operario',
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 16.0,
                            color: Colors.white),
                      ),
                      shape: new StadiumBorder(),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ],
                ),
              )],
          );
          
        }
      ),
    );
  }
}