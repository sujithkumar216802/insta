import 'dart:io';

import 'package:insta_downloader/models/history_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'historyDB';
  static const _tableName = 'history';
  static const _dbVersion = 1;
  static const columnUrl = 'url';
  static const columnThumbnail = 'thumbnail';
  static const columnFiles = 'files';
  static const columnDescription = 'description';
  static const columnAccountTag = 'tag';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;

  Future<Database> get database async {
    if (_database == null) _database = await _initiateDatabase();
    return _database;
  }

  Future<Database> _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return await openDatabase(join(directory.path, _dbName),
        version: _dbVersion, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    return await db.execute('''
      CREATE TABLE $_tableName(
      $columnUrl TINYTEXT PRIMARY KEY,
      $columnThumbnail LONGTEXT,
      $columnFiles LONGTEXT,
      $columnDescription MEDIUMTEXT,
      $columnAccountTag TEXT
      )
      ''');
  }

  Future<void> insert(History history) async {
    Database db = await instance.database;
    await db.insert(_tableName, history.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(History history) async {
    Database db = await instance.database;
    await db.update(_tableName, history.toMap(),
        where: 'url = ?', whereArgs: [history.url]);
  }

  Future<void> delete(History history) async {
    Database db = await instance.database;
    await db.delete(_tableName, where: 'url = ?', whereArgs: [history.url]);
  }

  Future<List<History>> getAllHistory() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List<History>.generate(maps.length, (index) {
      return History.fromMap(maps[index]);
    });
  }

  Future<List<String>> getUrls() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> urls =
        await db.query(_tableName, columns: [columnUrl]);
    return List.generate(urls.length, (index) => urls[index]['url']);
  }

  Future<History> getHistory(String url) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> history =
        await db.query(_tableName, where: '$columnUrl = ?', whereArgs: [url]);
    return History.fromMap(history.first);
  }
}
