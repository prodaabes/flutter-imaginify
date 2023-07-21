import 'package:sqflite/sqflite.dart';

const String tableGenerated = "generated";
const String columnId = "_id";
const String columnPrompt = "prompt";
const String columnImage = "image";

class Generated {
  int? id;
  String? prompt;
  String? image;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{columnPrompt: prompt, columnImage: image};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Generated();

  Generated.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId] as int?;
    prompt = map[columnPrompt] as String?;
    image = map[columnImage] as String?;
  }
}

class GeneratedProvider {
  Database? db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
CREATE TABLE $tableGenerated (
  $columnId INTEGER PRIMARY KEY AUTOINCREMENT, 
  $columnPrompt TEXT NOT NULL,
  $columnImage TEXT NOT NULL)
''');
    });
  }

  Future<Generated> insert(Generated generated) async {
    generated.id = await db?.insert(tableGenerated, generated.toMap());
    return generated;
  }

  Future<Generated?> getGenerated(int id) async {
    List<Map> maps = await db!.query(tableGenerated,
        columns: [columnId, columnPrompt, columnImage],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Generated.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map<dynamic, dynamic>>> getAll() async {
    List<Map> maps = await db!.query(tableGenerated,
        columns: [columnId, columnPrompt, columnImage], orderBy: '_id DESC');
    return maps;
  }

  Future<int> delete(int id) async {
    return await db!
        .delete(tableGenerated, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Generated generated) async {
    return await db!.update(tableGenerated, generated.toMap(),
        where: '$columnId = ?', whereArgs: [generated.id]);
  }

  Future close() async => db?.close();
}
