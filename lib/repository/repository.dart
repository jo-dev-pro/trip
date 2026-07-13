import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/trip_model.dart';
import '../../model/trip_comment_model.dart';
import '../../model/daily_note_model.dart';

class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. 전체 여행 목록 조회
  Future<List<TripModel>> getAllTrips() async {
    final snapshot = await _firestore.collection('trips').orderBy('id', descending: true).get();
    return snapshot.docs.map((doc) => TripModel.fromJson(doc.data())).toList();
  }

 Future<TripModel?> getTripById(int tripId) async {
    final doc = await _firestore.collection('trips').doc(tripId.toString()).get();
    return doc.exists ? TripModel.fromJson(doc.data()!) : null;
  }

  Future<List<TripCommentModel>> getCommentsByTrip(int tripId) async {
    final snapshot = await _firestore.collection('trips').doc(tripId.toString()).collection('comments').get();
    return snapshot.docs.map((doc) => TripCommentModel.fromJson(doc.data())).toList();
  }

  Future<List<DailyNoteModel>> getDailyNotesByTrip(int tripId) async {
    final snapshot = await _firestore.collection('trips').doc(tripId.toString()).collection('dailyNotes').orderBy('dayCount').get();
    return snapshot.docs.map((doc) => DailyNoteModel.fromJson(doc.data())).toList();
  }

  // 3. 여행 저장 (생성 및 수정)
  Future<void> saveTrip(TripModel trip) async {
    final docRef = _firestore.collection('trips').doc(trip.id.toString());
    await docRef.set(trip.toJson(), SetOptions(merge: true));
  }

  // 4. 여행 삭제
  Future<void> deleteTrip(int tripId) async {
    await _firestore.collection('trips').doc(tripId.toString()).delete();
  }

  // 5. 코멘트 저장 (Firestore 방식)
  Future<void> saveTripComments(int tripId, List<TripCommentModel> comments) async {
    final batch = _firestore.batch();
    final colRef = _firestore.collection('trips').doc(tripId.toString()).collection('comments');
    
    // 기존 데이터 삭제 후 새 데이터 추가 (Batch 이용)
    final snapshots = await colRef.get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    for (var comment in comments) {
      batch.set(colRef.doc(), comment.toJson());
    }
    await batch.commit();
  }

  // 8 & 9. 일별 노트 저장/수정 (Firestore의 set 활용)
  Future<void> saveDailyNote(DailyNoteModel note) async {
    // 문서 ID를 dayCount로 설정하면 수정/저장이 매우 쉬워집니다.
    final docRef = _firestore
        .collection('trips')
        .doc(note.tripId.toString())
        .collection('dailyNotes')
        .doc('day_${note.dayCount}');

    await docRef.set(note.toJson(), SetOptions(merge: true));
  }

  // 10. 여행 기간 수정 시 범위 벗어난 노트 삭제
  Future<void> adjustNotesOnDateChange(int tripId, int maxDayCount) async {
    final colRef = _firestore
        .collection('trips')
        .doc(tripId.toString())
        .collection('dailyNotes');

    // maxDayCount보다 큰 문서들을 찾아 삭제
    final snapshots = await colRef.where('dayCount', isGreaterThan: maxDayCount).get();
    
    final batch = _firestore.batch();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> addComment(int tripId, TripCommentModel comment) async {
    await _firestore
        .collection('trips')
        .doc(tripId.toString())
        .collection('comments')
        .doc() // 문서를 생성할 때 doc()를 비워두면 자동 생성(ID 부여)됩니다.
        .set(comment.toJson());
  }

  // Firebase에 여행, 코멘트, 노트를 한 번에 저장하는 메서드
  Future<void> saveEntireTrip(
    TripModel trip, 
    List<TripCommentModel> comments, 
    List<DailyNoteModel> notes
  ) async {
    final batch = _firestore.batch();
    final tripDocRef = _firestore.collection('trips').doc(trip.id.toString());

    // 1. 여행 기본 정보 저장
    batch.set(tripDocRef, trip.toJson(), SetOptions(merge: true));

    // 2. 코멘트 저장 (기존 코멘트 삭제 후 새로 추가)
    final commentsColRef = tripDocRef.collection('comments');
    final existingComments = await commentsColRef.get();
    for (var doc in existingComments.docs) {
      batch.delete(doc.reference);
    }
    for (var comment in comments) {
      batch.set(commentsColRef.doc(), comment.toJson());
    }

    // 3. 일별 노트 저장
    for (var note in notes) {
      final noteDocRef = tripDocRef.collection('dailyNotes').doc('day_${note.dayCount}');
      batch.set(noteDocRef, note.toJson(), SetOptions(merge: true));
    }

    // 4. 트랜잭션 일괄 커밋
    await batch.commit();
  }
}