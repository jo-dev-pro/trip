import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import '../repository/repository.dart';
import '../model/trip_model.dart';
import '../model/trip_comment_model.dart';
import '../model/daily_note_model.dart';

class MigrationService {
  final TripRepository _localRepo = TripRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> migrateToFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('is_migrated_to_firebase') ?? false) return;

    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      List<TripModel> localTrips = await _localRepo.getAllTrips();

      for (var trip in localTrips) {
        if (trip.id == null) continue;
        final tripIdStr = trip.id!.toString();

        String? newCoverUrl = trip.coverImagePath;
        if (trip.coverImagePath != null && !trip.coverImagePath!.startsWith('http')) {
          newCoverUrl = await _uploadFileToStorage('covers/$tripIdStr', File(trip.coverImagePath!));
        }

        final tripDocRef = _firestore.collection('trips').doc(tripIdStr);
        await tripDocRef.set({
          'id': trip.id,
          'title': trip.title,
          'place': trip.place,
          'startDate': trip.startDate?.toIso8601String(),
          'endDate': trip.endDate?.toIso8601String(),
          'note': trip.note,
          'coverImagePath': newCoverUrl,
        });

        List<TripCommentModel> localComments = await _localRepo.getCommentsByTrip(trip.id!);
        for (var comment in localComments) {
          String? newCommentImgUrl = comment.path;
          if (!comment.path.startsWith('http')) {
            final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(comment.path)}';
            newCommentImgUrl = await _uploadFileToStorage('comments/$tripIdStr/$uniqueFileName', File(comment.path));
          }

          if (newCommentImgUrl != null) {
            await tripDocRef.collection('comments').doc(comment.id?.toString()).set({
              'id': comment.id,
              'tripId': comment.tripId,
              'path': newCommentImgUrl,
              'comment': comment.comment,
            });
          }
        }

        List<DailyNoteModel> localNotes = await _localRepo.getDailyNotesByTrip(trip.id!);
        for (var note in localNotes) {
          await tripDocRef.collection('daily_notes').doc(note.id?.toString()).set({
            'id': note.id,
            'tripId': note.tripId,
            'dayCount': note.dayCount,
            'comment': note.comment,
          });
        }
      }

      await prefs.setBool('is_migrated_to_firebase', true);
      print('🎉 마이그레이션 성공');
    } catch (e) {
      print('❌ 마이그레이션 중 실패: $e');
    }
  }

  Future<String?> _uploadFileToStorage(String storagePath, File file) async {
    if (!await file.exists()) return null;
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('스토리지 업로드 에러 ($storagePath): $e');
      return null;
    }
  }
}