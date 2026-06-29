import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/onpop_invoked_provider.dart';

class JPopScope extends ConsumerWidget {
  const JPopScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 중요: canPop 상태를 ref.watch로 '구독'해야 합니다.
    // Provider 내부에서 상태(state)가 true로 바뀌면 이 화면이 자동으로 리빌드되며 canPop에 적용됩니다.
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
      child: child,
    );
  }
}
