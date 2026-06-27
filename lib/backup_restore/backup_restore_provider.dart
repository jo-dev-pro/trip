import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // 💡 실제 이미지 파일 경로 획득용
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
      // UI 전용 통합 문구
      showDbNameList: ['여행 통합 데이터 (이미지, 메모 포함)'],

      // 실제 물리 파일명인 'trip' 매핑
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
      JLoaders.warningSnackBar(
        context,
        title: '오류!!',
        message: '백업/복원할 항목을 선택해 주세요.',
      );
      return false;
    }

    try {
      final dbName = state.checkedDbNameList[0];

      if (type == 'backup') {
        await _backup(dbName);
      } else if (type == 'restore') {
        await _restore(dbName);
      }

      if (!ref.mounted) return false;

      if (!context.mounted) return false;
      JLoaders.successSnackBar(
        context,
        title: type == 'backup' ? '백업 완료' : '복원 완료',
        message: type == 'backup'
            ? '전체 데이터 및 이미지가 안전하게 백업되었습니다.\n(경로: Download/dbs/)'
            : '전체 데이터 및 이미지 복원이 완료되었습니다.',
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

  /// 내부 백업 로직 (DB 파일 + 진짜 이미지 파일 폴더)
  Future<void> _backup(String dbName) async {
    final dbPath = await getDatabasesPath();
    File sourceDb = File(join(dbPath, '$dbName.db'));
    var exists = await databaseExists(sourceDb.path);

    if (!exists) {
      throw Exception('백업할 데이터가 존재하지 않습니다.');
    }

    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      if (!ref.mounted) return;

      // 1. DB 파일 백업
      Directory copyTo = Directory(targetDirPath);
      await copyTo.create(recursive: true);
      String newDbPath = join(copyTo.path, '$dbName.db');
      await sourceDb.copy(newDbPath);

      // 2. 이미지 폴더 백업 (물리 파일 직접 복사)
      final appDocDir = await getApplicationDocumentsDirectory();
      // ※ 프로젝트 실제 이미지 폴더명이 다르면 'trip_images'를 수정하세요.
      Directory sourceImgDir = Directory(join(appDocDir.path, 'trip_images'));

      if (await sourceImgDir.exists()) {
        Directory targetImgDir = Directory(join(targetDirPath, 'trip_images'));
        await targetImgDir.create(recursive: true);

        await for (var file in sourceImgDir.list(recursive: false)) {
          if (file is File) {
            await file.copy(join(targetImgDir.path, basename(file.path)));
          }
        }
      }
    } else {
      throw Exception('저장소 접근 권한이 거부되었습니다.');
    }
  }

  /// 내부 복원 로직 (DB 파일 + 진짜 이미지 파일 폴더)
  Future<void> _restore(String dbName) async {
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, '$dbName.db');

    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      if (!ref.mounted) return;

      Directory backupPath = Directory(targetDirPath);
      String newDbPath = join(backupPath.path, '$dbName.db');
      File sourceDb = File(newDbPath);

      if (!await sourceDb.exists()) {
        throw Exception('Download/dbs/ 폴더에 백업 파일($dbName.db)이 존재하지 않습니다.');
      }

      // 1. 복사 전 기존 커넥션 해제 (_sqlService 인스턴스 참조 수정 완료)
      await _sqlService.closeDatabase(dbName);

      // 2. DB 파일 안정적 덮어쓰기
      await sourceDb.copy(dbPath);

      // 3. 이미지 폴더 복원 (물리 파일 주입)
      Directory sourceImgDir = Directory(join(targetDirPath, 'trip_images'));

      if (await sourceImgDir.exists()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        Directory targetImgDir = Directory(join(appDocDir.path, 'trip_images'));
        await targetImgDir.create(recursive: true); // 폴더가 없을 경우 자동 생성

        await for (var file in sourceImgDir.list(recursive: false)) {
          if (file is File) {
            await file.copy(join(targetImgDir.path, basename(file.path)));
          }
        }
      }

      // 4. 복원 종료 후 DB 재오픈
      await _sqlService.getDB(dbName);
    } else {
      throw Exception('저장소 접근 권한이 거부되었습니다.');
    }
  }
}
