import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../util/loaders/loaders.dart';

part 'onpop_invoked_provider.g.dart';

@riverpod
class JOnPopInvoked extends _$JOnPopInvoked {
  // 뒤로가기 기록을 저장할 변수 (상태가 아닌 내부 변수로 활용 가능)
  DateTime? _backButtonPressedTime;

  @override
  bool build() {
    // 🔥 변경: 상태(state)의 타입을 bool로 설정합니다. (기본값은 false)
    return false;
  }

  void handlePopInvoked(BuildContext context) {
    final now = DateTime.now();

    if (_backButtonPressedTime == null ||
        now.difference(_backButtonPressedTime!) > const Duration(seconds: 2)) {
      // 1. 첫 번째 누름: 시간 기록 및 토스트/스낵바 표시
      _backButtonPressedTime = now;
      state = false; // 여전히 나갈 수 없음

      JLoaders.successSnackBar(
        context,
        title: '알림',
        message: '뒤로가기 버튼을 한 번 더 누르면 종료됩니다.',
      );
    } else {
      // 2. 시간 내에 두 번째 누름: canPop 상태를 true로 변경하여 탈출 허용
      state = true;
      // 의도적으로 아주 짧은 딜레이를 주어 UI가 true 상태를 인지하고
      // 시스템 팝(종료)이 부드럽게 동작하도록 처리합니다.
      Future.microtask(() async {
        await SystemNavigator.pop();
      });
    }
  }
}
