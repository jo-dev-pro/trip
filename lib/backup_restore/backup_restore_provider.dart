import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../common/util/loaders/loaders.dart';
import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';
import 'backup_restore_sql_service.dart';
import 'backup_restore_state.dart';

part 'backup_restore_provider.g.dart';

@riverpod
class BackupRestore extends _$BackupRestore {
  // 백업과 복원 모두 대문자 'Download'로 통일
  String targetDirPath = '/storage/emulated/0/Download/dbs/';

  @override
  BackupRestoreState build() {
    return BackupRestoreState(
      showDbNameList: ['여행', '여행이미지', '여행일자코멘트'],
      checkedDbNameList: [
        TripDbInfo.tableName,
        TripCommentDbInfo.tableName,
        TripDailyNoteDbInfo.tableName,
      ],
      checkedDbList: [false, false, false],
      selectedCount: 0,
    );
  }

  void toggleCheck(int index, bool value) {
    final newCheckedDbList = [...state.checkedDbList];
    newCheckedDbList[index] = value;

    int newCount = state.selectedCount;
    if (value == true) {
      newCount++;
    } else {
      newCount--;
    }

    state = state.copyWith(
      checkedDbList: newCheckedDbList,
      selectedCount: newCount,
    );

    if (newCount > 0) {
      _openCreatedDB();
    }
  }

  Future<void> _openCreatedDB() async {
    for (int i = 0; i < state.checkedDbNameList.length; i++) {
      // 💡 비동기 루프 진입 전 체크
      if (!ref.mounted) return;
      await _getDataBase(state.checkedDbNameList[i]);
    }
  }

  Future<void> _getDataBase(String dbName) async {
    BackupRestoreSqlService sqlService = BackupRestoreSqlService();
    await sqlService.getDB(dbName);
  }

  Future<bool> dbBackupRestore(String type, BuildContext context) async {
    // 0. 선택된 DB가 없을 때 예외 처리 (루프 돌기 전에 먼저 체크하는 것이 효율적입니다)
    if (state.selectedCount == 0) {
      JLoaders.warningSnackBar(
        context,
        title: '오류!!',
        message: '선택된 DB가 없습니다.',
      );
      return false;
    }

    // 💡 [핵심] for문 진입 전, 필요한 리스트 데이터를 로컬 변수에 완전히 복사합니다.
    // 이렇게 하면 루프 도중 provider가 dispose되어도 영향을 받지 않습니다.
    final List<bool> localCheckedDbList = [...state.checkedDbList];
    final List<String> localCheckedDbNameList = [...state.checkedDbNameList];

    // 1. 선택된 타겟 비즈니스 로직 순차 실행
    for (int i = 0; i < localCheckedDbList.length; i++) {
      if (localCheckedDbList[i] == true) {
        final dbName = localCheckedDbNameList[i];

        if (type == 'backup') {
          await _backup(dbName);
        } else if (type == 'restore') {
          await _restore(dbName);
        } else {
          await _getDataBase(dbName);
        }
      }
    }

    // 💡 모든 비동기 작업이 끝난 후, UI 작업을 하기 직전에만 딱 한 번 mounted 체크!
    if (!ref.mounted) return false;

    // 3. 피드백 스낵바 노출 처리 구조
    try {
      if (type == 'backup') {
        if (!context.mounted) return false;
        JLoaders.successSnackBar(
          context,
          title: '백업 완료',
          message: '백업이 완료 되었습니다(경로: phone/download/dbs/)',
        );
      } else if (type == 'restore') {
        if (!context.mounted) return false;
        JLoaders.successSnackBar(
          context,
          title: '복원 완료',
          message: '복원이 완료 되었습니다(경로: phone/download/dbs/)',
        );
      } else {
        if (!context.mounted) return false;
        JLoaders.successSnackBar(
          context,
          title: 'DB 가져오기 완료',
          message: 'assets에서 DB 가져오기가 완료 되었습니다',
        );
      }
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      JLoaders.errorSnackBar(
        context,
        title: 'DB 백업 오류!!',
        message: e.toString(),
      );
      return false;
    }
  }

  Future<void> _backup(String dbName) async {
    final dbPath = await getDatabasesPath();
    File source = File(join(dbPath, '$dbName.db'));
    var exists = await databaseExists(source.path);

    if (exists) {
      // 1. 안드로이드 권한 체크 및 요청
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {
        // 비동기 갭 체크
        if (!ref.mounted) return;

        // 2. 백업 대상 폴더 생성
        Directory copyTo = Directory(targetDirPath);
        await copyTo.create(recursive: true);

        // 3. 올바른 경로 조립 및 복사 (File.create는 불필요하므로 삭제)
        String newPath = join(copyTo.path, '$dbName.db');
        await source.copy(newPath);
      } else {
        // 권한 거부 시 예외 처리 혹은 로그
        print("저장소 권한이 거부되어 백업을 진행할 수 없습니다.");
      }
    }
  }

  Future<void> _restore(String dbName) async {
    var databasesPath = await getDatabasesPath();
    var dbPath = join(databasesPath, '$dbName.db');

    // 1. 안드로이드 권한 체크 및 요청
    if (await Permission.manageExternalStorage.request().isGranted ||
        await Permission.storage.request().isGranted) {
      // 비동기 갭 체크
      if (!ref.mounted) return;

      // 2. 복원할 원본 파일 경로 조립
      Directory backupPath = Directory(targetDirPath);
      String newPath = join(backupPath.path, '$dbName.db');

      File source = File(newPath);

      // 3. 💡 복원 전 파일이 실제로 존재하지 않으면 중단 (안전장치)
      if (!await source.exists()) {
        return;
      }

      // 4. 안전하게 덮어쓰기 복사
      await source.copy(dbPath);
    } else {
      print("저장소 권한이 거부되어 복원을 진행할 수 없습니다.");
    }
  }
}
