import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'backup_sql_service.dart';
import 'backup_state.dart';

part 'backup_provider.g.dart';

@riverpod
class Backup extends _$Backup {
  final _sqlService = BackupSqlService();
  
  // 💡 고정된 단일 DB(테이블) 이름을 상수로 선언하여 가독성 확보
  static const String _dbName = 'trip'; 

  @override
  BackupState build() {
    // 🧹 무거웠던 리스트 초기화 코드를 전부 없애고 클린하게 시작
    return BackupState();
  }

  /// 백업 및 복원 통합 컨트롤러
  Future<bool> dbBackupRestore(String type, BuildContext context) async {
    // 💡 시작하자마자 로딩(isLoading: true) 상태를 주입하고 메시지를 초기화합니다.
    state = BackupState(isLoading: true);

    try {
      String resultMsg = '';

      if (type == 'backup') {
        resultMsg = await _backupToSelectedFolder();
      } else if (type == 'restoreFromExcel') {
        resultMsg = await _restoreFromSelectedFile();
      }

      // 사용자가 선택을 취소한 경우
      if (resultMsg.contains('취소') || resultMsg.contains('선택하지 않았습니다')) {
        state = BackupState(isLoading: false, message: resultMsg);
        return false;
      }

      if (!ref.mounted) return false;

      // 성공 상태 반영
      state = BackupState(isLoading: false, message: resultMsg);
      return true;
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      // 에러 상태 반영
      state = BackupState(isLoading: false, errorMessage: errorMessage);
      return false;
    }
  }

  /// ── 💾 [내보내기] 사용자가 선택한 폴더로 엑셀 및 이미지 백업 ──
  Future<String> _backupToSelectedFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return '백업 폴더 선택이 취소되었습니다.';

    // 💡 지저분한 변수 매핑 대신 멤버 상수로 클린하게 호출
    final db = await _sqlService.getDB(_dbName);
    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';

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

    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    String excelPath = join(selectedDirectory, 'trip_backup_$nowStr.xlsx');
    
    var fileBytes = excel.save();
    if (fileBytes != null) {
      File(excelPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    // 이미지 폴더 백업
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory sourceImgDir = Directory(join(appDocDir.path, 'trip_images'));

    if (await sourceImgDir.exists()) {
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
  Future<String> _restoreFromSelectedFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result == null || result.files.isEmpty) return '파일을 선택하지 않았습니다';

    final filePath = result.files.first.path;
    final bytes = result.files.first.bytes ?? (filePath != null ? File(filePath).readAsBytesSync() : null);
    if (bytes == null) return '파일을 읽을 수 없습니다';

    final db = await _sqlService.getDB(_dbName);
    await db.transaction((txn) async {
      await txn.execute('PRAGMA foreign_keys = OFF');
      await txn.delete('comment');
      await txn.delete('daily_note');
      await txn.delete('trip');
    });

    var excel = Excel.decodeBytes(bytes);

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

    // 이미지 주입 처리
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