import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() {
    // 기본값은 시스템 설정에 따름
    return ThemeMode.system;
  }

  void toggleTheme() {
    // 해결책: state가 system일 때, 시스템 모드를 현재 밝기 기반으로 계산하여
    // 명시적인 light 혹은 dark로 즉시 변경해버립니다.
    if (state == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      // 시스템이 현재 라이트면 다크로, 다크면 라이트로 변경
      state = (brightness == Brightness.light) ? ThemeMode.dark : ThemeMode.light;
    } else {
      // 이미 명시적 모드(light/dark)라면 반전
      state = (state == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    }
  }
}