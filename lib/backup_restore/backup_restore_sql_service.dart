import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupRestoreSqlService {
  static final BackupRestoreSqlService instance =
      BackupRestoreSqlService._instance();
  final Map<String, Database> _databases = {};

  BackupRestoreSqlService._instance();

  factory BackupRestoreSqlService() => instance;

  /// 기존 로컬 스마트폰에 있는 DB 파일을 안전하게 연결(Open)하는 기능
  Future<Database> getDB(String dbName) async {
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, '$dbName.db');

    // 안전장치: 기존에 서비스 내부 맵에 동일한 커넥션이 열려 있다면 닫아줍니다.
    if (_databases[dbName] != null && _databases[dbName]!.isOpen) {
      await _databases[dbName]!.close();
    }

    final db = await openDatabase(dbPath, readOnly: false);
    _databases[dbName] = db;
    return db;
  }

  /// 복원(Restore) 덮어쓰기 전 안전하게 기존 커넥션을 해제하는 유틸
  Future<void> closeDatabase(String dbName) async {
    if (_databases.containsKey(dbName)) {
      if (_databases[dbName] != null && _databases[dbName]!.isOpen) {
        await _databases[dbName]!.close();
      }
      _databases.remove(dbName);
    }
  }
}
