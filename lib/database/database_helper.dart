import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../home/models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE user(id TEXT PRIMARY KEY, name TEXT, email TEXT)",
        );
        await db.execute(
          "CREATE TABLE todos(id INTEGER PRIMARY KEY, userId INTEGER, title TEXT, completed INTEGER)",
        );
      },
    );
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    await db.insert(
      'user',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('user');
  }

  Future<void> insertToDoList(List<ToDoModel> todos) async {
    final db = await database;
    Batch batch = db.batch();
    for (var todo in todos) {
      batch.insert(
        'todos',
        todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
  }

  Future<void> insertToDo(ToDoModel todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateToDo(ToDoModel todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteToDo(int id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ToDoModel>> getToDos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List<ToDoModel>.from(maps.map((x) => ToDoModel.fromMap(x)));
  }

  Future<void> deleteToDos() async {
    final db = await database;
    await db.delete('todos');
  }
}
