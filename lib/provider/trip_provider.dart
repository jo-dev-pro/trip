import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 Firestore 임포트

import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';

part 'trip_provider.g.dart';

// ===============================================
// TripList (여행 목록 전체를 관리 (리스트 화면))
// ===============================================
@riverpod
class TripList extends _$TripList {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  @override
  Stream<List<TripModel>> build() {
    return _firestore
        .collection(TripDbInfo.tableName)
        .orderBy(TripDbInfo.startDate, descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TripModel.fromJson(doc.data()))
              .toList(),
        );
  }

  Future<void> addTrip(TripModel trip) async {
    await _firestore
        .collection(TripDbInfo.tableName)
        .doc(trip.id)
        .set(trip.toJson());
    final current = state.value ?? [];
    state = AsyncData([...current, trip]);
  }

  Future<void> updateTrip(TripModel trip) async {
    // 1. 로딩 상태 시작 (UI에서 버튼이 스피너로 바뀜)
    state = const AsyncLoading();

    try {
      // 2. 실제 데이터 업데이트
      await _firestore
          .collection(TripDbInfo.tableName)
          .doc(trip.id)
          .update(trip.toJson());

      // 3. 상태 갱신
      final current = state.value ?? [];
      state = AsyncData(
        current.map((t) => t.id == trip.id ? trip : t).toList(),
      );
    } catch (e, st) {
      // 4. 에러 발생 시 상태 처리
      state = AsyncError(e, st);
      rethrow; // UI에서 catch하도록 다시 던짐
    }
  }

  Future<void> deleteTrip(String id) async {
    // 1. 로딩 상태 시작 (UI에서 watch(tripListProvider).isLoading이 true가 됨)
    state = const AsyncLoading();

    try {
      final tripDoc = _firestore.collection(TripDbInfo.tableName).doc(id);

      // 1. Trip 문서 삭제 전에 데이터 가져오기
      final tripSnapshot = await tripDoc.get();
      final tripData = tripSnapshot.data();

      // 2. Comments 삭제
      final commentsSnapshot = await tripDoc
          .collection(TripCommentDbInfo.tableName)
          .get();
      for (final doc in commentsSnapshot.docs) {
        await doc.reference.delete();
        final path = doc.data()[TripCommentDbInfo.path] as String?;
        if (path != null && path.startsWith('http')) {
          try {
            await _storage.refFromURL(path).delete();
          } catch (_) {}
        }
      }

      // 3. DailyNotes 삭제
      final notesSnapshot = await tripDoc
          .collection(TripDailyNoteDbInfo.tableName)
          .get();
      for (final doc in notesSnapshot.docs) {
        await doc.reference.delete();
      }

      // 4. Cover 이미지 삭제
      final coverPath = tripData?[TripDbInfo.coverImagePath] as String?;
      if (coverPath != null && coverPath.startsWith('http')) {
        try {
          await _storage.refFromURL(coverPath).delete();
        } catch (_) {}
      }

      // 5. Trip 문서 삭제
      await tripDoc.delete();

      // 6. Provider 상태 갱신
      final current = state.value ?? [];
      state = AsyncData(current.where((t) => t.id != id).toList());
    } catch (e, st) {
      // 7. 실패 시 에러 상태로 전환 (로딩이 멈추고 UI에 에러 표시 가능)
      state = AsyncError(e, st);
      // 에러를 다시 던져서 UI에서 스낵바를 띄울 수 있게 합니다.
      rethrow;
    }
  }
}
