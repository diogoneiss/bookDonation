import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';
  String colImage = 'image';
  String colAuthor = 'author';
  String colContactEmail = 'emailDonated';
  String colUserCreated = "userDonated";

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + '/todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $tasksTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER, $colImage TEXT, $colAuthor TEXT, $colUserCreated TEXT, $colContactEmail TEXT)',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(tasksTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    taskList.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return taskList;
  }

  Future<int> insertTast(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(tasksTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      tasksTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  // Verifica se existe no banco. Se existir, atualiza pros dados mais recentes.
  // Se não existir insere.
  Future<int> updateTaskFromJson(Task task) async {
    if (task.title == null && task.author == null) return 0;
    Database db = await this.db;
    bool found = false;
    Task selectedInDb;

    if (task.date == null) task.date = DateTime.now();

    final List<Task> taskList = await getTaskList();
    int result;
    for (Task temp in taskList) {
      if (temp.id == task.id) {
        selectedInDb = temp;
        found = true;
        break;
      }
    }
    //se encontrar gerenciar conflitos
    if (found) {
      //atualizar dados mais recentes. Necessário verificar se está vazio em um e preechido n outro
      if (selectedInDb.userDonated.isEmpty && task.userDonated.isNotEmpty)
        selectedInDb.userDonated = task.userDonated;

      if (selectedInDb.imageEncoded.length < 10 &&
          task.imageEncoded.length > 10)
        selectedInDb.imageEncoded = task.imageEncoded;

      if (selectedInDb.emailDonated.isEmpty && task.emailDonated.isNotEmpty)
        selectedInDb.emailDonated = task.emailDonated;

      if (selectedInDb.author.isEmpty && task.author.isNotEmpty)
        selectedInDb.author = task.author;

      if (selectedInDb.priority.isEmpty && task.priority.isNotEmpty)
        selectedInDb.priority = task.priority;
      if (selectedInDb.date.toString().isEmpty &&
          task.date.toString().isNotEmpty) selectedInDb.date = task.date;

      result = await db.update(
        tasksTable,
        selectedInDb.toMap(),
        where: '$colId = ?',
        whereArgs: [task.id],
      );
    }
    //nao encontrado no db.
    //Inserir
    else {
      result = await insertTast(task);
    }
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      tasksTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
