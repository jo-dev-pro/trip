import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // 💡 이미지 압축 모듈 임포트
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 Firestore 임포트
import 'package:firebase_storage/firebase_storage.dart'; // 💡 Storage 임포트

import '../model/daily_note_model.dart';
import '../model/trip_comment_model.dart';
import '../model/trip_model.dart';

part 'trip_detail_provider.freezed.dart';
part 'trip_detail_provider.g.dart';

@freezed
abstract class TripDetailState with _$TripDetailState {
  const factory TripDetailState({
    required TripModel trip,
    required List<TripCommentModel> comments,
    required List<DailyNoteModel> dailyNotes,
  }) = _TripDetailState;
}

// ==========================================
// TripDetail (특정 여행의 상세 정보 관리 (코멘트, 데일리노트 포함))
// ==========================================
@riverpod
class TripDetail extends _$TripDetail {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<TripDetailState> build(String tripId) async {
    return _loadTripDetailFromFirebase(tripId);
  }

  Future<TripDetailState> _loadTripDetailFromFirebase(String tripId) async {
    final tripDoc = _firestore.collection(TripDbInfo.tableName).doc(tripId);

    final tripGet = await tripDoc.get();
    if (!tripGet.exists) throw Exception("해당 일정을 원격지에서 찾을 수 없습니다.");
    final trip = TripModel.fromJson(tripGet.data()!);

    // 서브 컬렉션(comments) 획득
    final commentsSnapshot = await tripDoc
        .collection(TripCommentDbInfo.tableName)
        .orderBy(FieldPath.documentId) // 🔹 숫자 id 기준 정렬
        .get();
    final comments = commentsSnapshot.docs
        .map((doc) => TripCommentModel.fromJson(doc.data()))
        .toList();

    // 서브 컬렉션(daily_notes) 획득
    final notesSnapshot = await tripDoc
        .collection(TripDailyNoteDbInfo.tableName)
        .get();
    final dailyNotes = notesSnapshot.docs
        .map((doc) => DailyNoteModel.fromJson(doc.data()))
        .toList();

    dailyNotes.sort((a, b) => (a.dayCount ?? 0).compareTo(b.dayCount ?? 0));

    return TripDetailState(
      trip: trip,
      comments: comments,
      dailyNotes: dailyNotes,
    );
  }

  // add comment 에서 사용하는 용도
  Future<File?> _compressImage(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = p.join(
      tempDir.path,
      "${Uuid().v4()}_compressed.webp", // UUID로 고유 파일명 보장
    );

    var result = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 85,
      minWidth: 1080,
      minHeight: 1080,
      format: CompressFormat.webp,
    );

    if (result == null) return null;
    return File(result.path);
  }

  Future<void> addComment({
    required String path,
    required String comment,
  }) async {
    final current = state.value;
    if (current == null) return;

    String remoteUrl = path;
    if (!path.startsWith('http')) {
      final compressedFile = await _compressImage(path);
      if (compressedFile != null) {
        final uniqueId = Uuid().v4();
        final ref = _storage.ref().child(
          'comments/${current.trip.id}/$uniqueId.webp',
        );
        await ref.putFile(compressedFile);
        remoteUrl = await ref.getDownloadURL();
      }
    }

    final commentId = Uuid().v4();
    await _firestore
        .collection(TripDbInfo.tableName)
        .doc(current.trip.id)
        .collection(TripCommentDbInfo.tableName)
        .doc(commentId)
        .set({
          TripCommentDbInfo.id: commentId,
          TripCommentDbInfo.tripId: current.trip.id,
          TripCommentDbInfo.path: remoteUrl,
          TripCommentDbInfo.comment: comment,
        });

    // ✅ 로컬 state 갱신
    final newComments = [
      ...current.comments,
      TripCommentModel(
        id: commentId,
        tripId: current.trip.id,
        path: remoteUrl,
        comment: comment,
      ),
    ];
    state = AsyncData(current.copyWith(comments: newComments));
  }

  Future<void> updateComment({
    required String tripId,
    required String commentId,
    required String newComment,
    String? newImagePath,
  }) async {
    final current = state.value;
    if (current == null) return;

    String? updatedPath;
    if (newImagePath != null && !newImagePath.startsWith('http')) {
      final compressedFile = await _compressImage(newImagePath);
      if (compressedFile != null) {
        final ref = _storage.ref().child('comments/$tripId/$commentId.webp');
        await ref.putFile(compressedFile);
        updatedPath = await ref.getDownloadURL();
      }
    }

    final Map<String, dynamic> data = {TripCommentDbInfo.comment: newComment};

    if (updatedPath != null) {
      data[TripCommentDbInfo.path] = updatedPath;
    }
    await _firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId)
        .collection(TripCommentDbInfo.tableName)
        .doc(commentId)
        .update(data);

    // ✅ 로컬 state 갱신
    final newComments = current.comments.map((c) {
      if (c.id == commentId) {
        return c.copyWith(comment: newComment, path: updatedPath ?? c.path);
      }
      return c;
    }).toList();
    state = AsyncData(current.copyWith(comments: newComments));
  }

  Future<void> deleteComment(
    String tripId,
    String commentId,
    String imagePath,
  ) async {
    final current = state.value;
    if (current == null) return;

    await _firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId)
        .collection(TripCommentDbInfo.tableName)
        .doc(commentId)
        .delete();

    if (imagePath.startsWith('http')) {
      try {
        final ref = _storage.refFromURL(imagePath);
        await ref.delete();
      } catch (_) {}
    }

    // ✅ 로컬 state 갱신
    final newComments = current.comments
        .where((c) => c.id != commentId)
        .toList();
    state = AsyncData(current.copyWith(comments: newComments));
  }

  Future<void> saveDailyNote({
    required int dayCount,
    required String comment,
  }) async {
    final current = state.value;
    if (current == null) return;

    await _firestore
        .collection(TripDbInfo.tableName)
        .doc(current.trip.id)
        .collection(TripDailyNoteDbInfo.tableName)
        .doc(dayCount.toString())
        .set({
          TripDailyNoteDbInfo.id: dayCount,
          TripDailyNoteDbInfo.tripId: current.trip.id,
          TripDailyNoteDbInfo.dayCount: dayCount,
          TripDailyNoteDbInfo.comment: comment,
        }, SetOptions(merge: true));

    // ✅ 로컬 state 갱신
    final newNotes = current.dailyNotes.map((n) {
      return n.dayCount == dayCount ? n.copyWith(comment: comment) : n;
    }).toList();
    state = AsyncData(current.copyWith(dailyNotes: newNotes));
  }
}

@riverpod
Future<String?> tripFirstImage(Ref ref, String tripId) async {
  final firestore = FirebaseFirestore.instance;
  try {
    final doc = await firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId)
        .get();
    if (doc.exists) {
      final trip = TripModel.fromJson(doc.data()!);
      if (trip.coverImagePath != null && trip.coverImagePath!.isNotEmpty) {
        return trip.coverImagePath;
      }
    }

    final commentsSnapshot = await firestore
        .collection(TripDbInfo.tableName)
        .doc(tripId)
        .collection(TripCommentDbInfo.tableName)
        .get();
    if (commentsSnapshot.docs.isNotEmpty) {
      return commentsSnapshot.docs.first.data()['path'] as String?;
    }
  } catch (e) {
    debugPrint('❌ [tripFirstImage] 파이어베이스 조회 실패 (tripId: $tripId): $e');
  }
  return null;
}
