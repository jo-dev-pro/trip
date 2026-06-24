import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupRestoreSqlService {

  static final BackupRestoreSqlService instance = BackupRestoreSqlService._instance();
  Database? _database;

  // db 초기화
  BackupRestoreSqlService._instance() {
    // _openDataBase();
  }

  factory BackupRestoreSqlService() {
    return instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    // await _openDataBase();
    return _database!;
  }
  

  // Future<void> _openDataBase() async {
  //   var dbPath = await getDatabasesPath();
  // }

  Future<void> getDB(String dbName) async {

    //일반적 인 용도로 사용될 때의 db open
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, '$dbName.db');
    var exists = await databaseExists(dbPath);

    if (!exists) {
      try {
        await Directory(dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      var data = await rootBundle.load(
          join('assets/dbs/', '$dbName.db'));

      List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes, data.lengthInBytes);

      await File(dbPath).writeAsBytes(bytes, flush: true);
    }
    _database = await openDatabase(dbPath, readOnly: false);
  }
}
