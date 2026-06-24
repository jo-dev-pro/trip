// import 'import_box.dart'; // 필요한 패키지들 (path_provider, path, io 등)
// import 'dart:io';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';

// class ImageMigrationService {
  
//   // 현재 정상 작동하는 새 디렉토리 경로 가져오기
//   static Future<Directory> _getNewTravelImagesDir() async {
//     final appDir = await getApplicationDocumentsDirectory();
//     final dir = Directory(p.join(appDir.path, 'travel_images'));
//     if (!await dir.exists()) {
//       await dir.create(recursive: true);
//     }
//     return dir;
//   }

//   // 구버전 앱에서 사용했을 법한 후보 경로들 탐색 및 이사 진행
//   static Future<void> migrateOldImages() async {
//     try {
//       final newDir = await _getNewTravelImagesDir();
      
//       // 구버전 후보 1: path_provider를 아예 안 쓰고 상대 경로로 'travel_images'를 만든 경우
//       // (기기 내 앱 실행 루트 디렉토리에 생성됨)
//       final candidate1 = Directory('travel_images');

//       // 구버전 후보 2: getExternalStorageDirectory()를 썼을 경우 (Android 외장 저장소)
//       Directory? candidate2;
//       if (Platform.isAndroid) {
//         final extDir = await getExternalStorageDirectory();
//         if (extDir != null) {
//           candidate2 = Directory(p.join(extDir.path, 'travel_images'));
//         }
//       }

//       // 구버전 후보 3: getTemporaryDirectory() (캐시 폴더)에 저장했을 경우
//       final tempDir = await getTemporaryDirectory();
//       final candidate3 = Directory(p.join(tempDir.path, 'travel_images'));

//       // 후보지들을 리스트로 묶어서 하나씩 검사
//       final oldDirs = [candidate1, candidate2, candidate3];

//       for (var oldDir in oldDirs) {
//         if (oldDir != null && await oldDir.exists()) {
//           print('舊 버전 이미지 디렉토리 발견: ${oldDir.path}');
          
//           // 옛날 폴더 안의 모든 파일(이미지) 목록 가져오기
//           final List<FileSystemEntity> entities = await oldDir.list().toList();
          
//           for (var entity in entities) {
//             if (entity is File) {
//               final fileName = p.basename(entity.path);
//               final newPath = p.join(newDir.path, fileName);
              
//               // 새 경로에 파일이 없을 때만 복사 (덮어쓰기 방지)
//               if (!await File(newPath).exists()) {
//                 await entity.copy(newPath);
//                 print('이미지 이사 완료: $fileName -> $newPath');
//               }
//             }
//           }
          
//           // 이사가 전부 끝났다면 구버전 폴더는 깔끔하게 삭제 (선택 사항)
//           // 안전을 위해 데이터가 제대로 뜨는 걸 확인한 뒤 아래 주석을 해제하시는 걸 권장합니다.
//           // await oldDir.delete(recursive: true);
//         }
//       }
//     } catch (e) {
//       print('이미지 마이그레이션 중 오류 발생: $e');
//     }
//   }
// }