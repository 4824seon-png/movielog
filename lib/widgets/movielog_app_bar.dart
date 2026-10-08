import 'package:flutter/material.dart';

/// 모든 화면에서 재사용하는 공용 AppBar. 스타일은 AppBarTheme이 담당한다.
class MovieLogAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MovieLogAppBar({super.key, required this.title, this.actions});

  final String title;

  /// 제목 오른쪽에 놓을 버튼들. 없으면 null (기존 화면은 그대로 동작).
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
      AppBar(title: Text(title), actions: actions);
}
