import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupSqlService {
  static final BackupSqlService instance = BackupSqlService._instance();
  BackupSqlService._instance();
  factory BackupSqlService() => instance;

  Database? _database;

  /// 데이터베이스 인스턴스를 싱글톤으로 안전하게 가져옵니다.
  Future<Database> getDB(String dbName) async {
    // 💡 이미 연결이 열려 있다면 기존 연결을 그대로 반환합니다. (불필요한 close/open 방지)
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, '$dbName.db');

    _database = await openDatabase(dbPath, readOnly: false);
    return _database!;
  }
}