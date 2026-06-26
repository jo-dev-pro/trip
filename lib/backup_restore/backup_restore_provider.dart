import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../common/util/loaders/loaders.dart';
import '../model/trip_model.dart';
import 'backup_restore_sql_service.dart';
import 'backup_restore_state.dart';

part 'backup_restore_provider.g.dart';

@riverpod
class BackupRestore extends _$BackupRestore {
  String targetDirPath = '/storage/emulated/0/Download/dbs/';
  final _sqlService = BackupRestoreSqlService();

  @override
  BackupRestoreState build() {
    return BackupRestoreState(
      // 💡 [개선]: UI에는 깔끔하게 통합 문구 하나만 보여줍니다.
      showDbNameList: ['여행 통합 데이터 (이미지, 메모 포함)'],
      
      // 🎯 [개선]: 실제 물리 파일명인 'trip' 하나만 리스트에 담습니다.
      checkedDbNameList: [
        TripDbInfo.tableName, // 'trip' 
      ], 
      checkedDbList: [false],
      selectedCount: 0,
    );
  }

  void toggleCheck(int index, bool value) {
    final newCheckedDbList = [...state.checkedDbList];
    newCheckedDbList[index] = value;

    int newCount = state.selectedCount + (value ? 1 : -1);

    state = state.copyWith(
      checkedDbList: newCheckedDbList,
      selectedCount: newCount,
    );
  }

  /// 백업 및 복원 컨트롤 타워
  Future<bool> dbBackupRestore(String type, BuildContext context) async {
    if (state.selectedCount == 0) {
      JLoaders.warningSnackBar(context, title: '오류!!', message: '백업/복원할 항목을 선택해 주세요.');
      return false;
    }

    try {
      // 🎯 [개선]: 리스트가 단 1개이므로 복잡한 반복문이나 Set 구조 없이 index 0번 고정 처리합니다.
      final dbName = state.checkedDbNameList[0];

      if (type == 'backup') {
        await _backup(dbName);
      } else if (type == 'restore') {
        await _restore(dbName);
      }

      if (!ref.mounted) return false;

      // 3. 성공 피드백 안내
      if (!context.mounted) return false;
      JLoaders.successSnackBar(
        context,
        title: type == 'backup' ? '백업 완료' : '복원 완료',
        message: type == 'backup' 
            ? '전체 데이터가 안전하게 백업되었습니다.\n(경로: Download/dbs/)'
            : '전체 데이터 복원이 완료되었습니다.',
      );
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      JLoaders.errorSnackBar(context, title: '작업 실패', message: errorMessage);
      return false;
    }
  }

  /// 내부 백업 로직
  Future<void> _backup(String dbName) async {
    final dbPath = await getDatabasesPath();
    File source = File(join(dbPath, '$dbName.db'));
    var exists = await databaseExists(source.path);

    if (!exists) {
      throw Exception('백업할 데이터가 존재하지 않습니다.');
    }

    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      if (!ref.mounted) return;

      Directory copyTo = Directory(targetDirPath);
      await copyTo.create(recursive: true);

      String newPath = join(copyTo.path, '$dbName.db');
      await source.copy(newPath);
    } else {
      throw Exception('저장소 접근 권한이 거부되었습니다.');
    }
  }

  /// 내부 복원 로직
  Future<void> _restore(String dbName) async {
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, '$dbName.db');

    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      if (!ref.mounted) return;

      Directory backupPath = Directory(targetDirPath);
      String newPath = join(backupPath.path, '$dbName.db');
      File source = File(newPath);

      if (!await source.exists()) {
        throw Exception('Download/dbs/ 폴더에 백업 파일($dbName.db)이 존재하지 않습니다.');
      }

      // 복사 전 기존 커넥션 해제 (DB Lock 방지)
      await _sqlService.closeDatabase(dbName);

      // 파일 안정적 덮어쓰기
      await source.copy(dbPath);

      // 복원 종료 후 재오픈
      await _sqlService.getDB(dbName);
    } else {
      throw Exception('저장소 접근 권한이 거부되었습니다.');
    }
  }
}