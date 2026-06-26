import 'package:sqflite/sqflite.dart';
import 'package:trip/model/trip_model.dart';
import 'package:trip/model/trip_comment_model.dart';
import 'package:trip/model/daily_note_model.dart';
import 'database_helper.dart';

class TripRepository {
  final _dbHelper = DatabaseHelper.instance;

  // 1. 여행 전체 목록 조회 (getAllTrips)
  Future<List<TripModel>> getAllTrips() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TripDbInfo.tableName,
      orderBy: '${TripDbInfo.id} DESC',
    );
    return maps.map((json) => TripModel.fromJson(json)).toList();
  }

  // 2. 특정 여행 단건 조회 (getTripById)
  Future<TripModel?> getTripById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TripDbInfo.tableName,
      where: '${TripDbInfo.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) return TripModel.fromJson(maps.first);
    return null;
  }

  // 3. 여행 생성 혹은 수정 저장 (saveTrip)
  Future<int> saveTrip(TripModel trip) async {
    final db = await _dbHelper.database;
    final json = trip.toJson();

    if (trip.id == null) {
      json.remove(TripDbInfo.id);
      return await db.insert(TripDbInfo.tableName, json);
    } else {
      await db.update(TripDbInfo.tableName, json, where: '${TripDbInfo.id} = ?', whereArgs: [trip.id]);
      return trip.id!;
    }
  }

  // 4. 여행 삭제 (deleteTrip)
  Future<int> deleteTrip(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(TripDbInfo.tableName, where: '${TripDbInfo.id} = ?', whereArgs: [id]);
  }

  /// image, comment db 처리
  // 5. 특정 여행의 이미지 코멘트 목록 조회
  Future<List<TripCommentModel>> getCommentsByTrip(int tripId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TripCommentDbInfo.tableName,
      where: '${TripCommentDbInfo.tripId} = ?',
      whereArgs: [tripId],
    );
    return maps.map((json) => TripCommentModel.fromJson(json)).toList();
  }

  // 6. 이미지 코멘트 목록 전체 저장 (기존 데이터 지우고 새로 쓰는 트랜잭션 방식 권장)
  Future<void> saveTripComments(
    int tripId,
    List<TripCommentModel> comments,
  ) async {
    final db = await _dbHelper.database;
    // 트랜잭션을 걸어 도중에 에러가 나면 전부 롤백되도록 안전장치 마련
    await db.transaction((txn) async {
      // 1. 기존에 해당 여행에 등록되어 있던 이미지 코멘트 싹 비우기
      await txn.delete(
        TripCommentDbInfo.tableName,
        where: '${TripCommentDbInfo.tripId} = ?',
        whereArgs: [tripId],
      );

      // 2. 새로 전달받은 리스트 일괄 추가
      for (var comment in comments) {
        // 💡 핵심: 복사본을 만들 때 파라미터로 받은 확실한 tripId를 강제로 매핑해줍니다.
        final json = comment.copyWith(tripId: tripId).toJson()..remove(TripCommentDbInfo.id);
        await txn.insert(TripCommentDbInfo.tableName, json);
      }
    });
  }

  /// daily note db 처리
  // 7. 특정 여행의 일별 노트 리스트 조회
  Future<List<DailyNoteModel>> getDailyNotesByTrip(int tripId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      TripDailyNoteDbInfo.tableName,
      where: '${TripDailyNoteDbInfo.tripId} = ?',
      whereArgs: [tripId],
    );
    return maps.map((json) => DailyNoteModel.fromJson(json)).toList();
  }

  // 8. 일별 노트 추가 (insertDailyNote)
  Future<int> insertDailyNote(DailyNoteModel note) async {
    final db = await _dbHelper.database;
    final json = note.toJson()..remove(TripDailyNoteDbInfo.id);
    // id가 있으면(기존 데이터) 기존 id를 유지하여 덮어쓰고, 없으면 제거하여 자동 생성되게 합니다.
    if (note.id == null) {
      json.remove(TripDailyNoteDbInfo.id);
    }
    
    // 💡 [수정 포인트 1]: conflictAlgorithm을 추가하여 
    // 동일한 ID가 있거나 겹치는 상황이 발생하면 덮어쓰기(replace)하도록 안전장치를 만듭니다.
    return await db.insert(
      TripDailyNoteDbInfo.tableName, 
      json,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 9. 일별 노트 수정 (updateDailyNote)
  Future<int> updateDailyNote(DailyNoteModel note) async {
    final db = await _dbHelper.database;
    return await db.update(
      TripDailyNoteDbInfo.tableName,
      note.toJson(),
      where: '${TripDailyNoteDbInfo.id} = ?',
      whereArgs: [note.id],
    );
  }

  /// 여행 기간 수정 및 날짜 범위를 벗어난 일별 노트 자동 삭제 (방법 1)
  /// 
  /// [updatedTrip] 수정된 시작일과 종료일이 담긴 여행 모델
  /// 반환값: 업데이트된 여행의 행(row) 수 (성공 시 1)
  Future<int> updateTripAndAdjustNotes(TripModel updatedTrip) async {
    final db = await _dbHelper.database;
    int result = 0;

    // 트랜잭션을 걸어 여행 수정이나 노트 삭제 중 하나라도 실패하면 모두 롤백합니다.
    await db.transaction((txn) async {
      // 1. 여행 정보 업데이트
      result = await txn.update(
        TripDbInfo.tableName,
        updatedTrip.toJson(),
        where: '${TripDbInfo.id} = ?',
        whereArgs: [updatedTrip.id],
      );

      // 💡 [수정 포인트 2]: 계산된 총 일수(totalDays)를 구한 뒤, 
      // 이 일수를 초과하는 dayCount 데이터를 DB에서 물리적으로 삭제합니다.
      if (updatedTrip.startDate != null && updatedTrip.endDate != null) {
        final totalDays = updatedTrip.endDate!.difference(updatedTrip.startDate!).inDays + 1;

        await txn.delete(
          TripDailyNoteDbInfo.tableName,
          // 🎯 date 대신 실제 데이터의 기준인 dayCount로 매핑 조건을 변경합니다.
          where: '${TripDailyNoteDbInfo.tripId} = ? AND ${TripDailyNoteDbInfo.dayCount} > ?',
          whereArgs: [updatedTrip.id, totalDays],
        );
      }
    });

    return result;
  }
}
