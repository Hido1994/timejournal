import 'package:faktura/persistence/datasource/data_source.dart';
import 'package:sqflite/sqflite.dart';

import '../../service/preference_service.dart';

class SqliteDataSource extends DataSource {
  PreferenceService preferenceService = PreferenceService.instance;
  Database? _database;

  static final SqliteDataSource instance =
      SqliteDataSource._privateConstructor();

  SqliteDataSource._privateConstructor();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    await initDB();
    return _database!;
  }

  initDB() async {
    String path = await preferenceService.getDatabasePath();
    _database = await openDatabase(path,
        version: 2,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE Trip ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
        "startDate INTEGER,"
        "endDate INTEGER,"
        "type TEXT,"
        "startLocation TEXT,"
        "endLocation TEXT,"
        "reason TEXT,"
        "vehicle TEXT,"
        "startMileage INTEGER,"
        "endMileage INTEGER,"
        "parent INTEGER, "
        "FOREIGN KEY (parent) REFERENCES Trip (id) ON DELETE CASCADE "
        ")");
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("UPDATE Trip SET startDate = (startDate/1000)*1000, endDate = (endDate/1000)*1000");
    }
  }

  @override
  Future<dynamic> save(String table, Map<String, dynamic> entry) async {
    Database db = await database;
    dynamic id = await db.insert(table, entry);
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String table,
      {String? where, String? orderBy}) async {
    Database db = await database;
    List<Map<String, dynamic>> result =
        await db.query(table, where: where, orderBy: orderBy);
    return result;
  }

  @override
  Future<dynamic> delete(String table, dynamic id,
      {String idName = 'id'}) async {
    Database db = await database;
    return await db.delete(table, where: '$idName = ?', whereArgs: [id]);
  }

  @override
  Future<Map<String, dynamic>> getById(String table, dynamic id,
      {String idName = 'id'}) async {
    Database db = await database;
    List<Map<String, dynamic>> result =
        await db.query(table, where: '$idName = ?', whereArgs: [id]);
    return result[0];
  }

  @override
  Future<List<dynamic>> getDistinctValues(String table, String column) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(table,
        columns: [column],
        orderBy: 'startDate DESC',
        where: '$column is not null');
    return result.map((e) => e[column]).toSet().toList();
  }

  @override
  Future<dynamic> update(String table, Map<String, dynamic> entry,
      {String idName = 'id'}) async {
    Database db = await database;
    return await db
        .update(table, entry, where: '$idName = ?', whereArgs: [entry[idName]]);
  }
}
