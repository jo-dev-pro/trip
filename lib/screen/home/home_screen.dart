import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:trip/common/route/route.dart';
import 'package:trip/model/trip_model.dart';
import 'package:trip/provider/trip_provider.dart';
import 'package:trip/screen/create/create_screen.dart';
import 'package:trip/screen/home/widget/build_empty_state.dart';

import '../../common/provider/onpop_invoked_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 프로바이더가 AsyncValue<List<TripModel>>을 반환하므로 타입을 일치시킵니다.
    final tripListAsync = ref.watch(tripListProvider);
    final canPopState = ref.watch(jOnPopInvokedProvider);
    final controller = ref.read(jOnPopInvokedProvider.notifier);

    return PopScope(
      // 🔥 수정: 고정된 false 대신, Provider의 상태인 canPopState를 바인딩합니다.
      canPop: canPopState,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 뒤로가기 버튼을 눌렀을 때 실행할 로직
        // (이전 답변에서 수정해 드린 handlePopInvoked 메소드 호출)
        controller.handlePopInvoked(context);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            backgroundColor: Colors.indigo.shade700,
            foregroundColor: Colors.white,
            title: const Text(
              '나의 여행',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              // 새 일정 추가 버튼
              TextButton.icon(
                onPressed: () async {
                  ref.invalidate(tripFormProvider);
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateScreen()),
                  );
                  ref.read(tripListProvider.notifier).refresh();
                },
                icon: const Icon(
                  Icons.add_location_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  '새 일정',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 기존 백업 버튼
              GestureDetector(
                child: CircleAvatar(
                  backgroundColor: Colors.grey.withValues(alpha: 0.8),
                  radius: 20,
                  child: Icon(
                    Icons.settings_backup_restore_outlined,
                    color: Colors.indigo.shade800,
                    size: 22,
                  ),
                ),
                onTap: () => context.pushNamed(JRoutes.backup),
              ),
              const SizedBox(width: 10),
            ],
            elevation: 0,
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: [
                Tab(text: '다가오는 여행'),
                Tab(text: '지난 추억'),
              ],
            ),
          ),
          body: tripListAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const BuildEmptyState();
              }
              // 💡 이제 List<TripModel> 타입이 정확히 맞아떨어집니다!
              return _buildTabBarView(list);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                '데이터를 불러오지 못했습니다:\n$err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 💡 매개변수 타입을 List<TripModel>로 변경하여 에러를 해결합니다.
  Widget _buildTabBarView(List<TripModel> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcomingList = list.where((trip) {
      if (trip.endDate == null) return false;
      final end = DateTime(
        trip.endDate!.year,
        trip.endDate!.month,
        trip.endDate!.day,
      );
      return end.isAtSameMomentAs(today) || end.isAfter(today);
    }).toList();

    final pastList = list.where((trip) {
      if (trip.endDate == null) return true;
      final end = DateTime(
        trip.endDate!.year,
        trip.endDate!.month,
        trip.endDate!.day,
      );
      return end.isBefore(today);
    }).toList();

    return TabBarView(
      children: [
        _buildtripListView(upcomingList, isPast: false),
        _buildtripListView(pastList, isPast: true),
      ],
    );
  }

  // 💡 매개변수 타입을 List<TripModel>로 변경
  Widget _buildtripListView(List<TripModel> items, {required bool isPast}) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isPast ? '지난 여행 기록이 없습니다.' : '예정된 여행 일정이 없습니다.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final trip = items[index];

        final startStr = trip.startDate != null
            ? DateFormat('yyyy.MM.dd').format(trip.startDate!)
            : '';
        final endStr = trip.endDate != null
            ? DateFormat('yyyy.MM.dd').format(trip.endDate!)
            : '';

        String dDayStr = '';
        if (!isPast && trip.startDate != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final start = DateTime(
            trip.startDate!.year,
            trip.startDate!.month,
            trip.startDate!.day,
          );
          final difference = start.difference(today).inDays;

          if (difference == 0) {
            dDayStr = 'D-Day';
          } else if (difference > 0) {
            dDayStr = 'D-$difference';
          } else {
            dDayStr = '여행 중';
          }
        }

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0.5,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  context.pushNamed(JRoutes.detail, extra: trip.id);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 💡 대표 이미지 표시 구역 ──
                    // 현재 구조상 TripModel 내부에 이미지가 없으므로,
                    // 이미지 로드가 완료되기 전까지는 우선 일관성 있게 에러 빌더(아이콘)나 플레이스홀더를 보여줍니다.
                    // ※ 추후 특정 trip.id에 대응하는 첫 번째 comment.path를 불러오는 프로바이더를 연동하면 완벽합니다.
                    _buildMainImage(trip.id),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isPast
                                      ? Colors.indigo.shade100
                                      : Colors.indigo.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  trip.place,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isPast
                                        ? Colors.indigo.shade700
                                        : Colors.indigo.shade700,
                                  ),
                                ),
                              ),
                              if (!isPast)
                                Text(
                                  dDayStr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        dDayStr == 'D-Day' || dDayStr == '여행 중'
                                        ? Colors.red.shade600
                                        : Colors.indigo.shade700,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            trip.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          if (startStr.isNotEmpty && endStr.isNotEmpty)
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 14,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$startStr ~ $endStr',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          if (trip.note != null && trip.note!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade100, height: 1),
                            const SizedBox(height: 12),
                            Text(
                              trip.note!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        );
      },
    );
  }

  // ── 💡 여행 ID별로 첫 번째 이미지를 안전하게 로드하기 위한 빌더 위젯 ──
  Widget _buildMainImage(int? tripId) {
    if (tripId == null) return _buildPlaceholderImage();

    return Consumer(
      builder: (context, ref, child) {
        // ✨ 비동기로 바뀐 tripFirstImageProvider(AsyncValue 상태)를 감시합니다.
        final imageAsync = ref.watch(tripFirstImageProvider(tripId));

        return imageAsync.when(
          data: (imagePath) {
            // 이미지 경로가 비어있거나 없는 경우 기본 플레이스홀더 표시
            if (imagePath == null || imagePath.isEmpty) {
              return _buildPlaceholderImage();
            }

            // 경로 규칙 분기 (네트워크 URL 인지 로컬 기기 파일 경로 인지 구분)
            final isNetwork =
                imagePath.startsWith('http') || imagePath.startsWith('https');

            return SizedBox(
              height: 150,
              width: double.infinity,
              child: isNetwork
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          _buildPlaceholderImage(),
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          _buildPlaceholderImage(),
                    ),
            );
          },
          // 이미지를 DB에서 읽어오는 동안 보여줄 임시 뼈대 스켈레톤 (플레이스홀더로 대체)
          loading: () => _buildPlaceholderImage(),
          // 에러 발생 시에도 깨지지 않게 플레이스홀더 배치
          error: (err, stack) => _buildPlaceholderImage(),
        );
      },
    );
  }

  // ── ✨ 공통 플레이스홀더 이미지 레이아웃 메서드 추가 ──
  Widget _buildPlaceholderImage() {
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.indigo.shade50,
      child: Center(
        child: Icon(
          Icons.flight_takeoff,
          color: Colors.indigo.shade300,
          size: 48,
        ),
      ),
    );
  }
} // HomeScreen 클래스 끝
