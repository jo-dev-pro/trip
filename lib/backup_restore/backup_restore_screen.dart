import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common/util/helper/helper_functions.dart';
import '../provider/trip_provider.dart';

import 'backup_restore_provider.dart';

// 💡 [개선]: 로딩 상태(_isLoading)를 화면 내부에서 제어하기 위해 
// ConsumerWidget에서 ConsumerStatefulWidget으로 변경합니다.
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false; // 🎯 화면 전역 로딩 상태 변수 추가

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(backupRestoreProvider);
    final controllerNotifier = ref.read(backupRestoreProvider.notifier);
    final isDark = JHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
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
                      // 💡 로딩 중에는 뒤로가기 버튼을 막아 오작동을 방지합니다.
                      onPressed: _isLoading ? null : () => context.pop(), 
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '백업 & 복원',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
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
                      _isLoading ? '데이터를 처리하는 중입니다...' : '백업/복원할 항목을 선택해 주세요',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),

            // ── DB 선택 목록 ──
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
                        // 💡 로딩 중에는 체크박스 조작을 비활성화합니다.
                        enabled: !_isLoading, 
                        title: Text(
                          dbName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        checkColor: Colors.white,
                        activeColor: const Color(0xFF1A5CFF),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        value: isChecked,
                        onChanged: (value) {
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
            // ── 백업 버튼 ──
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade200,
                  foregroundColor: Colors.indigo.shade500,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                // 💡 로딩 중에는 대기 및 클릭 유도 방지
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true); // 1. 로딩 시작

                  try {
                    bool isSuccess = await ref
                        .read(backupRestoreProvider.notifier)
                        .dbBackupRestore('backup', context);

                    if (!mounted) return;
                    setState(() => _isLoading = false); // 2. 로딩 종료

                    // 💡 [통일]: Navigator.pop 대신 프로젝트 스택에 맞춰 context.pop() 사용
                    if (isSuccess) {
                      context.pop(); 
                    }
                  } catch (_) {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: _isLoading 
                    ? SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.indigo.shade500, strokeWidth: 2)
                      )
                    : const Text('백업', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            
            // ── 복원 버튼 ──
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isLoading ? null : () async {
                  setState(() => _isLoading = true); // 1. 로딩 시작

                  try {
                    bool isSuccess = await ref
                        .read(backupRestoreProvider.notifier)
                        .dbBackupRestore('restore', context);

                    if (!mounted) return;
                    setState(() => _isLoading = false); // 2. 로딩 종료

                    if (isSuccess) {
                      context.pop(); // 💡 [통일]: 복원 성공 시 안전하게 뒤로가기

                      // 3. 부모 화면 리스트 갱신 연쇄 트리거
                      Future.delayed(const Duration(milliseconds: 50), () {
                        ref.invalidate(tripListProvider);
                      });
                    }
                  } catch (_) {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: _isLoading 
                    ? const SizedBox(
                        width: 24, 
                        height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('복원', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}