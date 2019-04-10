import 'package:flutter/material.dart';
import 'package:mecparts/helpers/globals_singleton.dart';

class OperandoPage extends StatelessWidget {
  Globals globals = new Globals();
  String mensaje;

  @override
  Widget build(BuildContext context) {
    mensaje = globals.esmaquina ? 'Máquina: ' : 'Operación: ';
    mensaje += globals.maquinaName + '\nOperario: ' + globals.operarioName;
    mensaje += '\nCódigo: ' + globals.parteCodigo;
    mensaje += '\nOrden: ' + globals.nroOrden.toString();
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: new IconButton(
            icon: new Icon(Icons.settings,size: 30.0),
            onPressed: () {},
          ),
          title: Center(
              child: Text(
                'Operando...       ',
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
                      Icon(Icons.settings_applications,
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
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed('/informe');
                                      },
                                      child: Text('FINALIZAR OPERACIÓN',
                                          style: new TextStyle(
                                              fontSize: 28.0,
                                              color: Colors.black)),
                                      shape: new RoundedRectangleBorder(
                                          borderRadius:
                                          new BorderRadius.circular(30.0)),
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                              ]))
                    ]))));
  }
}
