import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../model/daily_note_model.dart';
import '../../model/trip_comment_model.dart';
import '../../model/trip_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('${TripDbInfo.tableName}.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  // 외래키(Foreign Key) 활성화
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Trip 테이블
    await db.execute('''
      CREATE TABLE ${TripDbInfo.tableName} (
        ${TripDbInfo.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TripDbInfo.title} TEXT NOT NULL,
        ${TripDbInfo.place} TEXT NOT NULL,
        ${TripDbInfo.startDate} TEXT,
        ${TripDbInfo.endDate} TEXT,
        ${TripDbInfo.note} TEXT
      )
    ''');

    // 2. TripComment 테이블 (이미지 및 코멘트)
    await db.execute('''
      CREATE TABLE ${TripCommentDbInfo.tableName} (
        ${TripCommentDbInfo.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TripCommentDbInfo.tripId} INTEGER NOT NULL,
        ${TripCommentDbInfo.path} TEXT NOT NULL,
        ${TripCommentDbInfo.comment} TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (${TripCommentDbInfo.tripId}) 
          REFERENCES ${TripDbInfo.tableName} (${TripDbInfo.id}) 
          ON DELETE CASCADE
      )
    ''');

    // 3. DailyNote 테이블 (일별 코멘트)
    // 💡 [수정 포인트]: 테이블명을 daily_note -> daily_notes 로 변경합니다!
    await db.execute('''
      CREATE TABLE ${TripDailyNoteDbInfo.tableName} (
        ${TripDailyNoteDbInfo.id} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${TripDailyNoteDbInfo.tripId} INTEGER NOT NULL,
        ${TripDailyNoteDbInfo.dayCount} INTEGER NOT NULL, 
        ${TripDailyNoteDbInfo.comment} TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (${TripDailyNoteDbInfo.tripId}) 
          REFERENCES ${TripDbInfo.tableName} (${TripDbInfo.id}) 
          ON DELETE CASCADE
      )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
