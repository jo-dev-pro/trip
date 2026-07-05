import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../provider/trip_detail_state.dart';
import '../../screen/settings/settings_screen.dart';
import '../../screen/edit/edit_screen.dart';
import '../../screen/home/detail/detail.dart';
import '../../screen/home/home_screen.dart';
import 'route.dart';

class JAppRoute {
  static final routes = GoRouter(
    initialLocation: JRoutes.home,
    // 이 기능은 사용자가 존재하지 않는 경로로 이동할 때 작동합니다.
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('Page Not Found'))),
    routes: [
      GoRoute(
        path: JRoutes.home,
        name: JRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: JRoutes.detail,
        name: JRoutes.detail,
        builder: (context, state) {
          final tripId = state.extra as int? ?? 0;
          return DetailScreen(id: tripId);
        },
      ),
      GoRoute(
        path: JRoutes.edit,
        name: JRoutes.edit,
        builder: (context, state) {
          // 💡 [수정]: state.extra의 타입을 TripModel에서 TripDetailState로 변경합니다.
          final tripState = state.extra as TripDetailState;

          // 💡 캐스팅한 객체를 생성자에 그대로 전달합니다.
          return EditScreen(tripState: tripState);
        },
      ),
      GoRoute(
        path: JRoutes.setting,
        name: JRoutes.setting,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
