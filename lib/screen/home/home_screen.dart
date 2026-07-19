import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart'; // 💡 캐싱 위젯 추가

import '../../common/route/route.dart';
import '../../common/widget/popscope.dart';
import '../../model/trip_model.dart';
import '../../provider/trip_form_provider.dart';
import '../../provider/trip_provider.dart';
import '../create/create_screen.dart';
import 'widget/build_empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripListAsync = ref.watch(tripListProvider);

    return JPopScope(
      child: DefaultTabController(
        length: 2,
        initialIndex: 0, // 항상 첫 번째 탭부터 시작
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
              TextButton.icon(
                onPressed: () async {
                  ref.invalidate(tripFormProvider);
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateScreen()),
                  );
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
              GestureDetector(
                onTap: () => context.pushNamed(JRoutes.setting),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  radius: 20,
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
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
                Tab(text: '다녀온 여행'),
                Tab(text: '다가오는 여행'),
              ],
            ),
          ),
          body: tripListAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const BuildEmptyState();
              }
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
        _buildtripListView(pastList, isPast: true),
        _buildtripListView(upcomingList, isPast: false),
      ],
    );
  }

  Widget _buildtripListView(List<TripModel> items, {required bool isPast}) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          isPast ? '지난 여행 기록이 없습니다.' : '예정된 여행 일정이 없습니다.',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      );
    }
    int totalCount = items.length;

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

        double bottomMargin = (index == totalCount - 1) ? 40 : 16;

        return Card(
          color: Color(0xFFF4F6FA),
          margin: EdgeInsets.only(bottom: bottomMargin),
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
                _buildMainImage(trip),
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
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trip.place,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ),
                          if (!isPast)
                            Text(
                              dDayStr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: dDayStr == 'D-Day' || dDayStr == '여행 중'
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
        );
      },
    );
  }

  /// 🌟 [최적화 3] 로컬 주소와 원격지 파이어베이스 CDN 주소를 둘 다 지원하는 초고속 캐싱 빌더
  Widget _buildMainImage(TripModel trip) {
    final imagePath = trip.coverImagePath;

    if (imagePath == null || imagePath.isEmpty) {
      return _buildPlaceholderImage();
    }

    final isNetwork =
        imagePath.startsWith('http') || imagePath.startsWith('https');

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: isNetwork
          ? CachedNetworkImage(
              imageUrl: imagePath,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.indigo.shade50,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (ctx, url, err) => _buildPlaceholderImage(),
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => _buildPlaceholderImage(),
            ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
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
}
