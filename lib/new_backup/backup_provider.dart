import 'dart:io';
import 'package:archive/archive_io.dart'; // ZIP 압축용 패키지
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart'; // 공유 창 실행용 패키지
import 'package:file_picker/file_picker.dart'; // 복원 파일 선택용 패키지

import 'backup_sql_service.dart';
import 'backup_state.dart'; // 제공해주신 새로운 State 파일 임포트

part 'backup_provider.g.dart';

@riverpod
class Backup extends _$Backup {
  final _sqlService = BackupSqlService();

  @override
  BackupState build() {
    // 초기 상태 설정
    return BackupState(
      isLoading: false,
      message: null,
      errorMessage: null,
    );
  }

  /// ── 🎛️ 백업 및 복원 통합 컨트롤러 ──
  Future<bool> dbBackupRestore(String type, BuildContext context) async {
    // 1. 로딩 시작 및 기존 메시지 초기화
    state = state.copyWith(isLoading: true, message: null, errorMessage: null);

    const String dbName = 'trip_db'; 

    try {
      String resultMsg = '';

      if (type == 'backup') {
        resultMsg = await _backupAndShare(dbName); 
      } else if (type == 'restoreFromExcel') {
        resultMsg = await _restoreFromSelectedFile(dbName);
      }

      if (resultMsg.contains('취소') || resultMsg.contains('선택하지 않았습니다')) {
        // 2. 취소 시 로딩 해제 및 안내 메시지 반영
        state = state.copyWith(isLoading: false, message: resultMsg);
        return false;
      }

      if (!ref.mounted) return false;

      // 3. 성공 시 로딩 해제 및 완료 메시지 반영
      state = state.copyWith(isLoading: false, message: resultMsg);
      return true;
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      // 4. 에러 발생 시 로딩 해제 및 에러 메시지 반영
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    }
  }

  /// ── 💾 [내보내기] 안전한 임시 폴더에 압축(ZIP) 생성 후 공유 창 열기 ──
  Future<String> _backupAndShare(String dbName) async {
    final db = await _sqlService.getDB(dbName);
    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';

    // 엑셀 데이터 추출 및 시트별 작성
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

    // 외부 권한이 필요 없는 안전한 앱 전용 임시 디렉토리(Cache) 확보
    final tempDir = await getTemporaryDirectory();
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    
    // 백업 파일을 모아둘 임시 작업 폴더 생성
    final backupWorkingDir = Directory(join(tempDir.path, 'trip_backup_$nowStr'));
    await backupWorkingDir.create(recursive: true);

    // 생성된 엑셀 파일을 임시 백업 폴더 내부에 쓰기
    String excelPath = join(backupWorkingDir.path, 'trip_backup_$nowStr.xlsx');
    var fileBytes = excel.save();
    if (fileBytes != null) {
      await File(excelPath).writeAsBytes(fileBytes);
    }

    // 이미지 폴더(trip_images)를 임시 백업 폴더 안으로 복사
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory sourceImgDir = Directory(join(appDocDir.path, 'trip_images'));

    if (await sourceImgDir.exists()) {
      Directory targetImgDir = Directory(join(backupWorkingDir.path, 'trip_images'));
      await targetImgDir.create(recursive: true);

      await for (var file in sourceImgDir.list(recursive: false)) {
        if (file is File) {
          await file.copy(join(targetImgDir.path, basename(file.path)));
        }
      }
    }

    // 엑셀 + 이미지가 함께 묶인 폴더를 하나의 ZIP 파일로 최종 압축
    final encoder = ZipFileEncoder();
    String zipPath = join(tempDir.path, 'trip_backup_$nowStr.zip');
    encoder.create(zipPath);
    await encoder.addDirectory(backupWorkingDir);
    encoder.close();

    // 용량 최적화를 위해 역할을 마친 임시 작업 폴더는 삭제
    if (await backupWorkingDir.exists()) {
      await backupWorkingDir.delete(recursive: true);
    }

    // 시스템 공유 허브를 호출하여 구글 드라이브, 카카오톡 등으로 전송
    await Share.shareXFiles(
      [XFile(zipPath)],
      subject: '여행 통합 데이터 백업 $nowStr',
    );

    return '백업 압축 파일이 준비되어 공유 창을 실행했습니다.';
  }

  /// ── 📂 [가져오기] 구글 드라이브나 스마트폰 공간에서 백업 파일을 선택해 데이터 복원 ──
  Future<String> _restoreFromSelectedFile(String dbName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      return '복원 파일 선택이 취소되었습니다.';
    }

    final filePath = result.files.single.path!;

    // TODO: 선택된 파일 기점으로 압축 해제 및 데이터 파싱 복원 구현

    return '데이터 복원 기능이 호출되었습니다. (선택 파일: ${basename(filePath)})';
  }
}