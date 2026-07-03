import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart'; // 💡 폴더 및 파일 지정을 위해 필수 추가
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../model/trip_model.dart';

import 'backup_sql_service.dart';
import 'backup_state.dart';

part 'backup_provider.g.dart';

@riverpod
class Backup extends _$Backup {
  final _sqlService = BackupSqlService();

  @override
  BackupState build() {
    return BackupState(
      showDbNameList: ['여행 통합 데이터 (엑셀 변환 및 이미지 포함)'],
      checkedDbNameList: [TripDbInfo.tableName], // 'trip'
      checkedDbList: [false],
      selectedCount: 0,
    );
  }

  void toggleCheck(int index, bool value) {
    final newCheckedDbList = [...state.checkedDbList];
    newCheckedDbList[index] = value;
    int newCount = state.selectedCount + (value ? 1 : -1);
    state = state.copyWith(checkedDbList: newCheckedDbList, selectedCount: newCount);
  }

  /// 백업 및 복원 통합 컨트롤러
  Future<bool> dbBackupRestore(String type, BuildContext context) async {
    if (state.selectedCount == 0) {
      state = state.copyWith(errorMessage: '백업/복원할 항목을 선택해 주세요.');
      return false;
    }

    // 💡 작업 시작 전 이전 메시지 상태 초기화
    state = state.copyWith(message: null, errorMessage: null);

    try {
      final dbName = state.checkedDbNameList[0];
      String resultMsg = '';

      if (type == 'backup') {
        resultMsg = await _backupToSelectedFolder(dbName);
      } else if (type == 'restoreFromExcel') {
        resultMsg = await _restoreFromSelectedFile(dbName);
      }

      if (resultMsg.contains('취소') || resultMsg.contains('선택하지 않았습니다')) {
        state = state.copyWith(message: resultMsg); // 취소 안내도 일반 메시지로 전달
        return false;
      }

      if (!ref.mounted) return false;

      // 🎯 [성공 주입]: 성공 메시지를 상태에 반영하여 UI Listener를 깨웁니다.
      state = state.copyWith(message: resultMsg);
      return true;
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // 🎯 [에러 주입]: 에러 메시지를 상태에 반영합니다.
      state = state.copyWith(errorMessage: errorMessage);
      return false;
    }
  }

  /// ── 💾 [내보내기] 사용자가 선택한 폴더로 엑셀 및 이미지 백업 ──
  Future<String> _backupToSelectedFolder(String dbName) async {
    // 1. 저장소 권한 요청 및 확인
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    }
    if (!(await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted)) {
      throw Exception('저장소 접근 권한이 거부되었습니다.');
    }

    // 2. 사용자가 저장할 디렉토리(폴더)를 직접 선택하게 함
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return '백업 폴더 선택이 취소되었습니다.';

    final db = await _sqlService.getDB(dbName);
    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';

    // 백업 타겟 테이블 목록 명시
    List<String> tables = ['trip', 'comment', 'daily_note'];

    for (String tableName in tables) {
      var tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
      if (tableCheck.isEmpty) continue;

      List<Map<String, dynamic>> rows = await db.query(tableName);
      if (rows.isEmpty) continue;

      Sheet sheetObject = excel[tableName];

      // 헤더 작성
      List<String> headers = rows.first.keys.toList();
      sheetObject.appendRow(headers.map((e) => TextCellValue(e.toString())).toList());

      // 데이터 행 추가
      for (var row in rows) {
        List<CellValue> excelRow = [];
        for (var header in headers) {
          var val = row[header];
          excelRow.add(TextCellValue(val != null ? val.toString() : ''));
        }
        sheetObject.appendRow(excelRow);
      }
    }

    if (excel.sheets.containsKey('trip') && defaultSheet != 'trip') {
      excel.delete(defaultSheet);
    }

    // 3. 파일명에 날짜포맷을 부여하여 유연성 확보
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    String excelPath = join(selectedDirectory, 'trip_backup_$nowStr.xlsx');
    
    var fileBytes = excel.save();
    if (fileBytes != null) {
      File(excelPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    // 4. 이미지 폴더 백업 (동일 디렉토리 내에 복사 생성)
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory sourceImgDir = Directory(join(appDocDir.path, 'trip_images'));

    if (await sourceImgDir.exists()) {
      // 선택된 폴더 내부에 trip_images 폴더 강제 매핑 구조 생성
      Directory targetImgDir = Directory(join(selectedDirectory, 'trip_images'));
      await targetImgDir.create(recursive: true);

      await for (var file in sourceImgDir.list(recursive: false)) {
        if (file is File) {
          await file.copy(join(targetImgDir.path, basename(file.path)));
        }
      }
    }

    return '지정된 폴더에 엑셀 및 이미지가 안전하게 저장되었습니다.\n파일명: trip_backup_$nowStr.xlsx';
  }

  /// ── 📂 [가져오기] 사용자가 선택한 엑셀 파일 기준으로 데이터 및 이미지 복원 ──
  Future<String> _restoreFromSelectedFile(String dbName) async {
    if (Platform.isAndroid) {
      await Permission.manageExternalStorage.request();
    }
    if (!(await Permission.manageExternalStorage.isGranted || await Permission.storage.isGranted)) {
      throw Exception('저장소 접근 권한이 거부되었습니다.');
    }

    // 1. 복원용 백업 엑셀 파일 선택
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null || result.files.isEmpty) return '파일을 선택하지 않았습니다'; //[cite: 5]

    final filePath = result.files.first.path;
    final bytes = result.files.first.bytes ?? (filePath != null ? File(filePath).readAsBytesSync() : null);
    if (bytes == null) return '파일을 읽을 수 없습니다'; //[cite: 5]

    // 2. 데이터베이스 초기화 트랜잭션 수행
    final db = await _sqlService.getDB(dbName);
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');
      await txn.delete('comment');
      await txn.delete('daily_note');
      await txn.delete('trip');
    });

    // 3. 엑셀 디코딩 및 DB 주입 처리
    var excel = Excel.decodeBytes(bytes); //[cite: 5]

    for (String sheetName in excel.sheets.keys) {
      Sheet? sheet = excel.sheets[sheetName];
      if (sheet == null || sheet.maxRows <= 1) continue;

      List<List<Data?>> rows = sheet.rows;
      List<String> headers = rows.first.map((e) => e?.value?.toString() ?? '').toList();

      await db.transaction((txn) async {
        for (int i = 1; i < rows.length; i++) {
          Map<String, dynamic> rowMap = {};
          for (int j = 0; j < headers.length; j++) {
            if (headers[j].isEmpty) continue;
            var cellValue = rows[i][j]?.value;
            rowMap[headers[j]] = (cellValue == null || cellValue.toString().isEmpty) 
                ? null 
                : cellValue.toString();
          }
          if (rowMap.isNotEmpty) {
            await txn.insert(sheetName, rowMap, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });
    }
    await db.execute('PRAGMA foreign_keys = ON');

    // 4. 이미지 주입 처리 (중요: 선택한 엑셀 파일이 존재하던 부모 폴더의 하위 'trip_images' 탐색)
    if (filePath != null) {
      String selectedDirectory = dirname(filePath);
      Directory sourceImgDir = Directory(join(selectedDirectory, 'trip_images'));

      if (await sourceImgDir.exists()) {
        final appDocDir = await getApplicationDocumentsDirectory();
        Directory targetImgDir = Directory(join(appDocDir.path, 'trip_images'));
        await targetImgDir.create(recursive: true);

        await for (var file in sourceImgDir.list(recursive: false)) {
          if (file is File) {
            await file.copy(join(targetImgDir.path, basename(file.path)));
          }
        }
      }
    }

    return '엑셀 파일의 이력과 보관된 동형 이미지가 성공적으로 앱에 주입되었습니다.';
  }
}