import 'dart:async';
import 'dart:io' as io;

import 'package:mecparts/models/operario_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// BASE DE DATOS LOCAL
// Docs armar las querys -> https://sqlite.org/lang.html

class DbHelper {
  static Database _db;

  final String tableOperario = 'Operarios';

  final String columnId = 'id';
  final String columnNombre = 'nombre';
  final String columnApellido = 'apellido';
  final String columnIngreso = 'ingreso';

  Future<Database> get db async {
    if (_db != null) return _db;

    _db = await initDb();

    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, 'mecparts.db');

    var MyDb = await openDatabase(path, version: 1, onCreate: _onCreate);

    return MyDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableOperario ($columnId INTEGER PRIMARY KEY, $columnNombre TEXT, $columnApellido TEXT, $columnIngreso DATETIME)');
  }

  Future<int> deleteOperario(int id) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn
          .rawDelete('DELETE FROM $tableOperario WHERE $columnId = $id');
    });
    return 0;
  }

  Future<int> updateOperario(Operario operario) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawUpdate(
          'UPDATE $tableOperario SET $columnNombre = \'${operario.nombre}\', $columnApellido= \'${operario.apellido}\', $columnIngreso = ${operario.ingreso} WHERE $columnId = ${operario.id} ');
    });
    return 0;
  }

  // Este método lo llamamos cada vez que tengamos un ingreso
  // confirmado por la respuesta ok del server por usuario activo
  Future saveOperario(Operario operario) async {
    var dbClient = await db;
    String _timestamp = operario.ingreso.toIso8601String();
    await dbClient.transaction((txn) async {
      await txn.rawQuery(
          'REPLACE INTO $tableOperario ($columnId, $columnNombre, $columnApellido, $columnIngreso) VALUES (${operario.id}, \'${operario.nombre}\', \'${operario.apellido}\', datetime(\'$_timestamp\'))');
    });
  }

  // la idea es que se listen alfabeticamente los ultimos 3 o 4 operarios
  // distintos con ingresos más recientes en el terminal

  Future<List> getOperarios() async {
    var dbClient = await db;

    return await dbClient.rawQuery(
        'SELECT * FROM (SELECT DISTINCT * FROM $tableOperario ORDER BY $columnIngreso DESC LIMIT 4) ORDER BY $columnApellido, $columnNombre ASC');

    /*for (int i = 0; i < lista.length; i++) {
      operarios.add(new Operario(lista[i]['id'], lista[i]['nombre'],
          lista[i]['apellido'], DateTime.parse(lista[i]['ingreso'])));
    }
    // Con esto deberiamos tener un vaciado automático para quedarnos solo con los últimos 6 distintos
    int count = await dbClient.rawDelete(
        'DELETE FROM $tableOperario WHERE id NOT IN (SELECT DISTINCT id FROM $tableOperario ORDER BY $columnIngreso DESC LIMIT 6)');
    print('borrados: $count');
    return lista;);*/
  }
}
