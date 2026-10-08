import 'package:flutter/material.dart';

/// 영화 목록을 불러오지 못했을 때의 Error 상태 화면.
///
/// 내부 Exception·StackTrace 대신 고정된 안내 문구를 보여주고,
/// 사용자가 할 수 있는 행동(다시 시도)을 함께 제공한다.
/// 재시도 시 무엇을 할지는 부모가 정하므로 onRetry로 전달받는다.
class MovieListError extends StatelessWidget {
  const MovieListError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min, // Column이 세로 전체를 차지하지 않고 내용만큼만
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(height: 12),
          const Text('영화를 불러오지 못했습니다.'),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
