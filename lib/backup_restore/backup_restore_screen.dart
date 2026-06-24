import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip/common/util/helper/helper_functions.dart';
import 'package:trip/provider/trip_provider.dart';

import 'backup_restore_provider.dart';


class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(backupRestoreProvider);
    final controllerNotifier = ref.read(backupRestoreProvider.notifier);

    final isDark = JHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── 상단 커스텀 앱바 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(), // 💡 GoRouter 방식 뒤로가기
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '백업 & 복원',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 안내 헤더 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DB를 선택해 주세요',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── DB 선택 목록 (Sliver 구조 완벽 통합 및 중첩 해제) ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final dbName = controller.showDbNameList[index].toUpperCase();
                  final isChecked = controller.checkedDbList[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CheckboxListTile(
                        title: Text(
                          dbName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        checkColor: Colors.white,
                        activeColor: const Color(
                          0xFF1A5CFF,
                        ), // 💡 테마 맞춤형 포인트 컬러
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        value: isChecked,
                        onChanged: (value) {
                          // 💡 Notifier를 통한 상태 변경 로직 실행
                          controllerNotifier.toggleCheck(index, value ?? false);
                        },
                      ),
                    ),
                  );
                }, childCount: controller.checkedDbNameList.length),
              ),
            ),

            // 하단 여백 확보
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── 하단 플로팅 버튼 바 ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          MediaQuery.of(context).padding.bottom + 10,
        ),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE0E4EF),
                  foregroundColor: const Color(0xFF4D7FFF),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  bool isSuccess = await ref
                      .read(backupRestoreProvider.notifier)
                      .dbBackupRestore('backup', context);
                  // 2. 작업이 성공(true)했고, 화면이 여전히 살아있는 상태라면 화면을 닫아줍니다.
                  // 💡 만약 위에서 선택된 DB가 없어 false가 반환되었다면 이 조건문을 건너뛰므로 화면이 닫히지 않습니다!
                  if (isSuccess && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  '백업',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A5CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  bool isSuccess = await ref
                      .read(backupRestoreProvider.notifier)
                      .dbBackupRestore('restore', context);

                  if (isSuccess && context.mounted) {
                    // 1. 화면을 먼저 닫아서 UI 트리 관계를 정리합니다.
                    Navigator.pop(context);

                    // 2. 아주 잠깐(10~50ms) 뒤에 부모 화면의 프로바이더를 새로고침합니다.
                    // 이렇게 하면 현재 화면의 dispose 사이클과 충돌하지 않습니다.
                    Future.delayed(const Duration(milliseconds: 50), () {
                      ref.invalidate(tripListProvider);
                    });
                  }
                },
                child: const Text(
                  '복원',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
