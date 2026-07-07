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
import 'backup_state.dart';

part 'backup_provider.g.dart';

@riverpod
class Backup extends _$Backup {
  final _sqlService = BackupSqlService();

  @override
  BackupState build() {
    return BackupState(
      isLoading: false,
      message: null,
      errorMessage: null,
    );
  }

  /// ── 🎛️ 백업 및 복원 통합 컨트롤러 ──
  Future<bool> dbBackupRestore(String type, BuildContext context) async {
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
        state = state.copyWith(isLoading: false, message: resultMsg);
        return false;
      }

      if (!ref.mounted) return false;

      state = state.copyWith(isLoading: false, message: resultMsg);
      return true;
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return false;
    }
  }

  /// ── 💾 [내보내기] 데이터 안정성 확보 및 인메모리 압축 ──
  Future<String> _backupAndShare(String dbName) async {
    final db = await _sqlService.getDB(dbName);
    var excel = Excel.createExcel();
    String defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';

    // 1. 엑셀 데이터 추출 및 시트 작성
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

    // 🌟 2. 엑셀 인코딩 데이터를 메모리에 즉시 고정 (깨짐 방지 핵심)
    final List<int>? excelBytes = excel.encode(); 
    if (excelBytes == null || excelBytes.isEmpty) {
      throw Exception('엑셀 데이터 인코딩에 실패했습니다.');
    }

    // 3. 가상 압축 파일(Archive) 저장소 개설
    var archive = Archive();

    // 🌟 4. 껍데기가 아닌 진짜 데이터 바이트를 압축 파일에 주입
    archive.addFile(ArchiveFile(
      'trip_backup.xlsx', // 내부 파일명 지정
      excelBytes.length,
      excelBytes,
    ));

    // 5. 이미지 폴더 백업 처리 (물리 파일 동기화 방식)
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory sourceImgDir = Directory(join(appDocDir.path, 'trip_images'));

    if (await sourceImgDir.exists()) {
      // 디렉토리 내 모든 파일을 동기식으로 안전하게 리스팅
      List<FileSystemEntity> files = sourceImgDir.listSync(recursive: false);
      
      for (var file in files) {
        if (file is File) {
          List<int> imgBytes = file.readAsBytesSync(); // 동기식 바이너리 로드
          if (imgBytes.isNotEmpty) {
            String imgName = basename(file.path);
            archive.addFile(ArchiveFile(
              'trip_images/$imgName', 
              imgBytes.length, 
              imgBytes,
            ));
          }
        }
      }
    }

    // 6. 메모리에 빌드된 아카이브를 단일 ZIP 파일 데이터로 변환
    final List<int>? zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null || zipBytes.isEmpty) {
      throw Exception('ZIP 압축 인코딩에 실패했습니다.');
    }

    // 7. 기기 임시 폴더에 디스크 저장 처리 (물리적 쓰기 완료 보장)
    final tempDir = await getTemporaryDirectory();
    final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    String zipPath = join(tempDir.path, 'trip_backup_$nowStr.zip');

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipBytes, flush: true); // 💡 flush 처리로 전송 도중 잘림 현상 방지

    // 8. 알림창 및 시스템 공유 허브 호출
    await Share.shareXFiles(
      [XFile(zipPath)],
      subject: '여행 통합 데이터 백업 $nowStr',
    );

    return '백업 파일 내보내기가 완료되었습니다.';
  }

  /// ── 📂 [가져오기] 압축 해제 및 트랜잭션 단위 복원 ──
  Future<String> _restoreFromSelectedFile(String dbName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) {
      return '복원 파일 선택이 취소되었습니다.';
    }

    final filePath = result.files.single.path!;
    final db = await _sqlService.getDB(dbName);

    final tempDir = await getTemporaryDirectory();
    final decodeDir = Directory(join(tempDir.path, 'restore_temp'));
    if (await decodeDir.exists()) await decodeDir.delete(recursive: true);
    await decodeDir.create(recursive: true);

    // ZIP 해제 로직
    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File(join(decodeDir.path, filename))
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }

    // 내부 엑셀 찾기
    final entities = await decodeDir.list().toList();
    File? excelFile;
    for (var entity in entities) {
      if (entity is File && (extension(entity.path) == '.xlsx' || basename(entity.path) == 'trip_backup.xlsx')) {
        excelFile = entity;
        break;
      }
    }

    if (excelFile == null) {
      return '백업 파일 내에서 유효한 엑셀 데이터를 찾을 수 없습니다.';
    }

    // 여행앱 스타일: 밀어버리고 재생성 트랜잭션
    await db.transaction((txn) async {
      List<String> tables = ['trip', 'comment', 'daily_note'];

      for (String tableName in tables) {
        await txn.execute("DELETE FROM $tableName"); 
        await txn.execute("DELETE FROM sqlite_sequence WHERE name='$tableName'");
      }

      var excelBytes = excelFile!.readAsBytesSync();
      var excel = Excel.decodeBytes(excelBytes);

      for (String tableName in tables) {
        if (!excel.sheets.containsKey(tableName)) continue;
        var sheet = excel[tableName];
        if (sheet.maxRows <= 1) continue;

        List<String> headers = sheet.rows.first.map((cell) => cell?.value?.toString() ?? '').toList();

        for (int i = 1; i < sheet.maxRows; i++) {
          var row = sheet.rows[i];
          Map<String, dynamic> rowMap = {};
          
          for (int j = 0; j < headers.length; j++) {
            if (headers[j].isEmpty) continue;
            var cellValue = row[j]?.value;
            rowMap[headers[j]] = cellValue?.toString();
          }

          if (rowMap.isNotEmpty) {
            await txn.insert(tableName, rowMap);
          }
        }
      }
    });

    // 이미지 교체
    final appDocDir = await getApplicationDocumentsDirectory();
    Directory targetImgDir = Directory(join(appDocDir.path, 'trip_images'));
    Directory sourceImgDir = Directory(join(decodeDir.path, 'trip_images'));

    if (await sourceImgDir.exists()) {
      if (await targetImgDir.exists()) await targetImgDir.delete(recursive: true);
      await targetImgDir.create(recursive: true);

      await for (var file in sourceImgDir.list(recursive: false)) {
        if (file is File) {
          await file.copy(join(targetImgDir.path, basename(file.path)));
        }
      }
    }

    await decodeDir.delete(recursive: true);

    return '데이터 및 이미지 복원이 완료되었습니다.';
  }
}