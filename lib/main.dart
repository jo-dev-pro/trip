import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip/firebase_options.dart';

import 'common/provider/theme_provider.dart';
import 'common/route/app_routers.dart';

void main() async {
  // 1. Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // // App Check는 배포 환경에 맞춰 변경 필수
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: kDebugMode
  //       ? AndroidProvider.debug
  //       : AndroidProvider.playIntegrity,
  //   appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  // );
  // 4. 데이터 마이그레이션 실행
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      // darkTheme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.indigo,
      //     brightness: Brightness.dark,
      //   ),
      // ),
      themeMode: themeMode,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      routerConfig: JAppRoute.routes,
    );
  }
}
