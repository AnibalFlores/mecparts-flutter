import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mecparts/models/operario_model.dart';

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
        'CREATE TABLE $tableOperario ($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnNombre TEXT, $columnApellido TEXT, $columnIngreso DATETIME');
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
  // confirmado por por la respuesta ok del server por alta de labor
  void saveOperario(Operario operario) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO $tableOperario ($columnNombre, $columnApellido, $columnIngreso VALUES(\'${operario.nombre}\', \'${operario.apellido}\', datetime(\'now\')');
    });
  }

  // la idea es que se listen alfabeticamente los ultimos 3 o 4 operarios
  // distintos con ingresos más recientes en el terminal

  Future<List<Operario>> getOperarios() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        'SELECT * FROM (SELECT DISTINCT * FROM $tableOperario ORDER BY $columnIngreso DESC LIMIT 4) ORDER BY $columnApellido, $columnNombre ASC');

    List<Operario> operarios = List();

    for (int i = 0; i < list.length; i++) {
      operarios.add(Operario(list[i]['id'], list[i]['nombre'],
          list[i]['apellido'], list[i]['ingreso']));
    }

    // Con esto deberiamos tener un vaciado automático para quedarnos solo con los últimos 6 distintos
    int count = await dbClient.rawDelete(
        'DELETE * FROM $tableOperario WHERE NOT IN (SELECT DISTINCT * FROM $tableOperario ORDER BY $columnIngreso DESC LIMIT 6)');

    print('borrados: $count');

    return operarios;
  }
}
