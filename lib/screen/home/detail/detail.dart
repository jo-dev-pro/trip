import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip/model/daily_note_model.dart';
import 'package:trip/model/trip_comment_model.dart';
import 'package:trip/model/trip_model.dart';
import 'package:trip/provider/trip_provider.dart'; // 💡 단일 통합 프로바이더 경로
import 'package:trip/screen/edit/edit_screen.dart';
import 'package:trip/screen/home/detail/detail_view.dart';

class DetailScreen extends ConsumerWidget {
  final int id;

  const DetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(tripDetailProvider(id));

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(
        body: Center(
          child: Text(
            '여행 정보를 불러올 수 없거나 삭제된 일정입니다.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      ),
      data: (data) {
        // 💡 통합된 TripDetailState 객체에서 필드 추출
        final TripModel trip = data.trip;
        final List<TripCommentModel> comments = data.comments;
        final List<DailyNoteModel> dailyNotes =
            data.dailyNotes; // dynamic 대신 명확한 모델 타입 지정

        final hasImages = comments.isNotEmpty;
        final String? firstImagePath = hasImages ? comments.first.path : null;

        // 날짜가 누락되었을 경우를 대비한 가드 코드 포함
        final formattedStartDate = trip.startDate != null
            ? DateFormat('yyyy. MM. dd').format(trip.startDate!)
            : '-';
        final formattedEndDate = trip.endDate != null
            ? DateFormat('yyyy. MM. dd').format(trip.endDate!)
            : '-';

        final int totalDays = (trip.startDate != null && trip.endDate != null)
            ? trip.endDate!.difference(trip.startDate!).inDays + 1
            : 1;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // 💡 [수정 완료]: 데이터가 완벽히 일치하므로 가공 없이 데이터 통째로 토스합니다.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditScreen(
                    tripState: data, // 복잡한 재생성 로직 제거하고 단일 데이터 바인딩
                  ),
                ),
              );
            },
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              '수정하기',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              // ─── 상단 앱바 ───
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.indigo.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(
                    left: 52,
                    bottom: 16,
                    right: 20,
                  ),
                  title: Text(
                    trip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      firstImagePath != null
                          ? Image.file(File(firstImagePath), fit: BoxFit.cover)
                          : Container(
                              color: Colors.indigo.shade50,
                              child: Icon(
                                Icons.flight_takeoff,
                                size: 80,
                                color: Colors.indigo.shade300,
                              ),
                            ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black38,
                              Colors.transparent,
                              Colors.black54,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── 본문 기본 정보 영역 ───
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.indigo.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  trip.place,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${totalDays - 1}박 $totalDays일',
                                    style: TextStyle(
                                      color: Colors.indigo.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$formattedStartDate ~ $formattedEndDate',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (trip.note != null &&
                          trip.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          '여행 기록 & 메모',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            trip.note!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Text(
                        '날짜별 여정',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ─── 날짜별 타임라인 리스트 ───
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (trip.startDate == null) return const SizedBox.shrink();

                  final currentDay = trip.startDate!.add(Duration(days: index));
                  final dayString = DateFormat(
                    'MM/dd (E)',
                    'ko_KR',
                  ).format(currentDay);
                  final dayCount = index + 1;

                  // 💡 DB에서 가져온 일자별 comment를 타임라인에 정확히 매핑
                  String dayTheme = '${trip.place} 탐방 일정';
                  if (dailyNotes.isNotEmpty) {
                    final matchedNote = dailyNotes.firstWhere(
                      (note) => note.dayCount == dayCount,
                      orElse: () => DailyNoteModel(
                        id: null,
                        tripId: id,
                        dayCount: dayCount,
                        comment: '',
                      ),
                    );
                    if (matchedNote.id != null &&
                        matchedNote.comment.trim().isNotEmpty) {
                      dayTheme = matchedNote.comment;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade700,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.indigo.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            if (index != totalDays - 1)
                              Container(
                                width: 2,
                                height: 68,
                                color: Colors.indigo.shade100,
                              ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Day $dayCount - $dayString',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                dayTheme,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }, childCount: totalDays),
              ),

              // ─── 등록사진 및 기록 섹션 헤더 ───
              if (hasImages)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '등록된 여행 사진 & 기록',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${comments.length}개',
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── 사진 그리드 배치 ───
              if (hasImages)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12.0,
                          crossAxisSpacing: 12.0,
                          childAspectRatio: 0.82,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = comments[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              barrierDismissible: true,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                    return ImageCommentViewer(
                                      imageComments: comments,
                                      initialIndex: index,
                                    );
                                  },
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(14),
                                  ),
                                  child: Image.file(
                                    File(item.path),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    item.comment,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: comments.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        );
      },
    );
  }
}
