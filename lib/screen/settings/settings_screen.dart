import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/provider/theme_provider.dart';
import '../../common/widget/section_title.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // final excelState = ref.watch(backupProvider);

    // // ── 상태 변경 리스너 스낵바 ──
    // ref.listen<BackupState>(backupProvider, (_, next) {
    //   // 1. 성공 또는 안내 메시지가 전달된 경우
    //   if (next.message != null) {
    //     final isCancel =
    //         next.message!.contains('취소') ||
    //         next.message!.contains('선택하지 않았습니다');

    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(next.message!),
    //         backgroundColor: isCancel
    //             ? Colors.orange.shade700
    //             : Theme.of(context).colorScheme.primary,
    //       ),
    //     );
    //   }

    //   // 2. 에러 메시지가 전달된 경우
    //   if (next.errorMessage != null) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('오류: ${next.errorMessage!}'),
    //         backgroundColor: Theme.of(context).colorScheme.error,
    //       ),
    //     );
    //   }
    // });

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Stack(
        // 💡 LoadingOverlay 대용 또는 간단한 스택 결합으로 로딩 화면 인디케이터 처리
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // ── 데이터 관리 섹션 ──
              const JSectionTitle(title: '화면 테마'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // 1. 다크 모드
                    ListTile(
                      leading: Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: themeMode == ThemeMode.dark
                            ? Colors.amber
                            : Colors.blue,
                      ),
                      title: const Text("다크 모드"),
                      trailing: Switch(
                        value: themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          // ref
                          //     .read(themeModeProvider.notifier)
                          //     .toggleTheme();
                        },
                      ),
                    ),
                    // 1. 엑셀 내보내기 (폴더 지정형 백업)
                    // ListTile(
                    //   leading: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.orange.shade50,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Icon(
                    //       Icons.upload_file_outlined,
                    //       color: Colors.orange.shade700,
                    //     ),
                    //   ),
                    //   title: const Text('여행 데이터 엑셀 내보내기'),
                    //   subtitle: const Text(
                    //     '원하는 폴더를 지정하여 여행, 메모, 이미지 세트를 백업합니다.',
                    //     style: TextStyle(fontSize: 12),
                    //   ),
                    //   trailing: const Icon(Icons.chevron_right),
                    //   onTap: () => _exportExcel(context, ref),
                    // ),
                    // const Divider(height: 1, indent: 16),

                    // // 2. 엑셀 가져오기 (파일 지정형 복원)
                    // ListTile(
                    //   leading: Container(
                    //     padding: const EdgeInsets.all(8),
                    //     decoration: BoxDecoration(
                    //       color: Colors.purple.shade50,
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //     child: Icon(
                    //       Icons.download_outlined,
                    //       color: Colors.purple.shade700,
                    //     ),
                    //   ),
                    //   title: const Text('백업 파일 불러오기 (복원)'),
                    //   subtitle: const Text(
                    //     '백업된 엑셀 파일을 선택하여 여행 기록과 이미지를 복원합니다.',
                    //     style: TextStyle(fontSize: 12),
                    //   ),
                    //   trailing: const Icon(Icons.chevron_right),
                    //   onTap: () => _importExcel(context, ref),
                    // ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 엑셀 사용 안내 섹션 ──
              const JSectionTitle(title: '엑셀 백업 및 이미지 보존 안내'),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GuideRow(
                        icon: Icons.table_chart_outlined,
                        title: '종합 여행 데이터 저장',
                        desc:
                            '지정한 폴더 내에 [trip_backup_일자.xlsx] 파일이 생성되며 여행 목록, 댓글, 데일리 노트 데이터가 시트별로 나뉘어 저장됩니다.',
                      ),
                      const SizedBox(height: 14),
                      _GuideRow(
                        icon: Icons.image_outlined,
                        title: '이미지 폴더 일괄 백업',
                        desc:
                            '선택하신 폴더 내부에 [trip_images] 폴더가 자동으로 함께 복사됩니다. 앱 삭제 후 재설치 대응을 위해 엑셀 파일과 이미지 폴더는 항상 같은 자리에 같이 두셔야 합니다.',
                      ),
                      const SizedBox(height: 14),
                      _GuideRow(
                        icon: Icons.refresh_outlined,
                        title: '데이터 복원 규칙',
                        desc:
                            '가져오기를 진행하면 스마트폰 내의 기존 여행 데이터가 엑셀 데이터 기준으로 동기화(초기화 후 재구성)됩니다.',
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.amber.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '엑셀 파일 내부의 ID 값 컬럼 구조를 임의로 편집할 경우 복원 시 매핑 오류가 발생할 수 있으니 주의해 주세요.',
                                style: TextStyle(fontSize: 12, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),

          // ── 전역 로딩 인디케이터 처리 ──
          // if (excelState is AsyncLoading)
          //   Container(
          //     color: Colors.black.withValues(alpha: 0.15),
          //     child: const Center(child: CircularProgressIndicator()),
          //   ),
        ],
      ),
    );
  }

  /// ── 💾 [내보내기] 다이얼로그 호출 트리거 ──
  // Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('여행 데이터 백업'),
  //       content: const Text('전체 데이터 및 이미지를 내보낼 저장 폴더를 선택합니다.\n계속하시겠습니까?'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('취소'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           child: const Text('폴더 선택 및 백업'),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (confirmed == true) {
  //     // 💡 프로바이더에 새로 구축한 폴더 지정형 매칭 호출 명칭 ('backup')
  //     await ref
  //         .read(backupProvider.notifier)
  //         .dbBackupRestore('backup', context);
  //   }
  // }

  // /// ── 📂 [가져오기] 다이얼로그 호출 트리거 ──
  // Future<void> _importExcel(BuildContext context, WidgetRef ref) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('백업 파일 가져오기'),
  //       content: const Text(
  //         '선택한 엑셀 파일 기점으로 데이터를 복원합니다.\n기존 기기의 데이터는 삭제되고 백업 시점으로 동기화됩니다.\n계속하시겠습니까?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(ctx, false),
  //           child: const Text('취소'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(ctx, true),
  //           child: const Text('파일 선택 및 복원'),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (confirmed == true) {
  //     // 💡 프로바이더에 새로 구축한 파일 지정형 매칭 호출 명칭 ('restoreFromExcel')
  //     await ref
  //         .read(backupProvider.notifier)
  //         .dbBackupRestore('restoreFromExcel', context);
  //   }
  // }
}

class _GuideRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _GuideRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
