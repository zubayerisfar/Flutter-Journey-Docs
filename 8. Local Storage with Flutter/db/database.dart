import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import '../model/task_model.dart';

class TaskDatabase {
  static Database? _database;

  static Future<Database> getDB() async {
    if (_database != null) return _database!;

    String dbPath = await getDatabasesPath();
    String fullPath = path.join(dbPath, 'tasks.db');
    _database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, isDone INTEGER)',
        );
      },
    );
    return _database!;
  }

  static Future<void> insertTask(TaskModel task) async {
    final db = await getDB();
    await db.insert(
      'tasks',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<TaskModel>> getTasks() async {
    final db = await getDB();
    final List<Map<String, dynamic>> tasks = await db.query('tasks');
    return List.generate(tasks.length, (i) => TaskModel.fromMap(tasks[i]));
  }

  static Future<void> deleteTask(int id) async {
    final db = await getDB();
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateTask(TaskModel task) async {
    final db = await getDB();
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
