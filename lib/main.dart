import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MovieLogApp());

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  // MaterialApp.router: 앱 전역 설정(테마·제목)만 담당하고,
  // 어떤 화면을 보여줄지는 routerConfig로 넘긴 GoRouter가 결정한다.
  // 그래서 home 속성이 없고, 첫 화면은 GoRouter의 initialLocation이 정한다.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'MovieLog',
    theme: AppTheme.light,
    routerConfig: AppRouter.router, // static final → 앱 전체에서 라우터 1개 유지
  );
}
